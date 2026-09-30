extends Node3D

enum State { TITLE, SHOP, REVEAL, RUN, VICTORY, RETURN }
var state := State.TITLE
var progress := ShopProgression.new()
var deadline := 0.0
var session_start := 0.0
var attempt := 0
var pending := -1
var first_exit := true
var attack_ready := 0.0
var holding := false
var warning_played := false
var revealed := false
var camera_offset := Vector3(3.5, 12, 10)
var last_hover := Vector2i(-999, -999)
var camera_motion: Tween
var elevator: Dictionary
var door_motion: Tween
var kick := 0.0
var focused := true
var web_focus_callback
var onboarding := "smash"
var return_motion: Tween
var print_mat: ShaderMaterial
const IMPACT = preload("res://scripts/impact_fx.gd")
@onready var map: ShopMap = $ShopMap
@onready var player: DiskPlayer = $Player
@onready var camera: Camera3D = $Camera3D
@onready var ui: DiskUI = $UI
@onready var abilities: DiskAbilities = $Abilities
@onready var sound = $Sound
@onready var target: MeshInstance3D = $Target

func now() -> float:
	return Time.get_ticks_msec() / 1000.0

func _ready() -> void:
	if OS.has_feature("web"):
		web_focus_callback = JavaScriptBridge.create_callback(_web_focus_changed)
		JavaScriptBridge.eval("""
		window.diskShopInstallFocus = function(callback) {
			if (window.diskShopRemoveFocus) window.diskShopRemoveFocus();
			const blur = () => callback(false);
			const focus = () => callback(!document.hidden);
			const visibility = () => callback(!document.hidden && document.hasFocus());
			window.addEventListener('blur', blur);
			window.addEventListener('focus', focus);
			document.addEventListener('visibilitychange', visibility);
			window.diskShopRemoveFocus = function() {
				window.removeEventListener('blur', blur);
				window.removeEventListener('focus', focus);
				document.removeEventListener('visibilitychange', visibility);
			};
		};
		""")
		JavaScriptBridge.get_interface("window").diskShopInstallFocus(web_focus_callback)
	abilities.game = self
	elevator = ShopVisuals.elevator(self)
	var finish := CanvasLayer.new()
	finish.layer = 0
	add_child(finish)
	var screen := ColorRect.new()
	screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	print_mat = ShaderMaterial.new()
	print_mat.shader = preload("res://shaders/print_finish.gdshader")
	screen.material = print_mat
	finish.add_child(screen)
	ui.ui_feedback.connect(func(): sound.play_sound("ui"))
	ui.start_requested.connect(start_session)
	ui.leave_requested.connect(leave_shop)
	ui.reroll_requested.connect(func():
		if valid_shop() and pending < 0 and progress.reroll():
			sound.play_sound("shop")
			ui.shop(progress, pending, attempt == 1 and onboarding != "done"))
	ui.slot_requested.connect(func():
		if valid_shop() and pending < 0 and progress.unlock_slot(): ui.shop(progress, pending, attempt == 1 and onboarding != "done"))
	ui.buy_requested.connect(buy_offer)
	ui.replace_requested.connect(replace_ability)
	ui.cancel_requested.connect(func():
		if valid_shop():
			pending = -1
			ui.shop(progress, pending, attempt == 1 and onboarding != "done"))
	ui.restart_requested.connect(func(): get_tree().reload_current_scene())
	player.reset_to(map.spawn)
	camera.position = player.position + camera_offset
	camera.look_at(player.position)
	show_elevator()
	ui.title()

func start_session() -> void:
	if state != State.TITLE: return
	session_start = now()
	sound.start_music()
	map.reset_map(progress.unlocked)
	abilities.reset_run()
	state = State.SHOP # Use the normal departure without opening or rolling a shop.
	leave_shop()
	announce("NEXT STOP: DIAMOND STATUS.")

func enter_shop() -> void:
	state = State.SHOP
	sound.set_music_mode("elevator")
	holding = false
	pending = -1
	map.reset_map(progress.unlocked)
	player.reset_to(map.spawn)
	abilities.reset_run()
	show_elevator()
	progress.roll()
	deadline = now() + float(progress.balance.shop_seconds)
	target.hide()
	ui.shop(progress, pending, attempt == 1 and onboarding != "done")
	if attempt == 1:
		announce("FIRST PRESSING! Spend your cash on upgrades, then OPEN DOORS.")
	elif attempt > 1:
		var lines := ["BACK IN THE BOOTH! The boxes have requested a rematch.", "Your debut album: Nevermind the Boxes.", "Cash on the floor is not a savings account, kid.", "Abbey Load is still blocking aisle three."]
		announce(lines[(attempt - 1) % lines.size()])

func return_to_elevator() -> void:
	if state != State.RUN: return
	state = State.RETURN
	sound.set_music_mode("elevator")
	holding = false
	target.hide()
	ui.tutorial.hide()
	abilities.generation += 1
	player.finish()
	camera.h_offset = 0
	announce("TIME'S UP! Back to the elevator.")
	ui.travel.text = "SET COMPLETE / RETURNING TO ELEVATOR"
	ui.travel.show()
	return_motion = create_tween()
	return_motion.tween_property(ui.curtain, "color:a", 1.0, 0.4)
	return_motion.tween_callback(func():
		show_elevator()
		player.reset_to(map.spawn)
		player.position = elevator.room.position + Vector3(-1.0, 0, 0.7)
		for i in range(2): elevator.doors[i].position.x = -1.8 if i == 0 else 1.8
		sound.play_sound("door")
		door_motion = create_tween().set_parallel(true)
		for i in range(2):
			door_motion.tween_property(elevator.doors[i], "position:x", -0.65 if i == 0 else 0.65, 0.5))
	return_motion.tween_property(ui.curtain, "color:a", 0.0, 0.4)
	return_motion.tween_interval(0.2)
	return_motion.tween_callback(func():
		ui.travel.hide()
		enter_shop())

func show_elevator() -> void:
	map.hide()
	elevator.room.show()
	player.position = elevator.room.position + Vector3(-1.0, 0, 0.7)
	camera.position = elevator.room.position + Vector3(5.2, 0, 0) + camera_offset
	camera.h_offset = 0.0
	kick = 0.0
	if door_motion != null: door_motion.kill()
	for i in range(2): elevator.doors[i].position.x = -0.65 if i == 0 else 0.65

func open_doors() -> void:
	sound.play_sound("door")
	door_motion = create_tween().set_parallel(true)
	for i in range(2):
		door_motion.tween_property(elevator.doors[i], "position:x", -1.8 if i == 0 else 1.8, 0.45)
	door_motion.tween_property(player, "position:z", elevator.room.position.z - 1.5, 0.6)

func valid_shop() -> bool:
	if state != State.SHOP: return false
	if now() >= deadline:
		leave_shop()
		return false
	return true

func leave_shop() -> void:
	if state != State.SHOP: return
	pending = -1
	ui.modal.hide()
	ui.modal_kind = ""
	holding = false
	abilities.reset_run()
	state = State.REVEAL
	open_doors()
	camera_motion = create_tween()
	camera_motion.tween_interval(0.65)
	camera_motion.tween_callback(func():
		map.show()
		elevator.room.hide()
		player.reset_to(map.spawn)
		camera.position = player.position + camera_offset)
	if first_exit:
		first_exit = false
		announce("DIAMOND STATUS. Go get it.")
		camera_motion.tween_property(camera, "position", Vector3(map.diamond.x, 0, map.diamond.y) + camera_offset, 1.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
		camera_motion.tween_interval(0.8)
		camera_motion.tween_property(camera, "position", Vector3(map.spawn.x, 0, map.spawn.y) + camera_offset, 1.1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	camera_motion.tween_callback(begin_run)
func begin_run() -> void:
	map.show()
	elevator.room.hide()
	player.reset_to(map.spawn)
	state = State.RUN
	sound.set_music_mode("run")
	attempt += 1
	deadline = now() + float(progress.balance.run_seconds)
	attack_ready = 0
	warning_played = false
	announce("Swing that bat! Click adjacent trash to clear the aisle." if attempt == 1 else "SET %d! Pick a route. Make some noise." % attempt)

func _process(delta: float) -> void:
	if not is_node_ready(): return
	var viewport_size := get_viewport().get_visible_rect().size
	print_mat.set_shader_parameter("player_uv", camera.unproject_position(player.position) / viewport_size)
	print_mat.set_shader_parameter("darkness_enabled", 1.0 if state == State.RUN else 0.0)
	# Preserve the deadline while hidden, resolving only the current phase on return.
	if not focused: return
	if state in [State.RUN, State.SHOP] and now() >= deadline:
		if state == State.RUN: return_to_elevator()
		else: leave_shop()
	if state == State.RUN and focused:
		var direction := player.input_direction()
		if direction != Vector2i.ZERO:
			player.facing = direction
			player.update_facing()
			if now() >= player.move_ready:
				var interval := progress.move_interval()
				if now() < abilities.boost_until: interval = maxf(float(progress.balance.move_floor), interval / 1.35)
				player.move_ready = now() + interval
				if map.walkable(player.tile + direction):
					player.move_to(player.tile + direction, interval * 0.9)
					collect_current()
		if state == State.RUN:
			abilities.tick()
			if holding and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and get_viewport().gui_get_hovered_control() == null:
				attack_mouse()
			update_target()
			camera.position = camera.position.lerp(player.position + camera_offset, 1 - exp(-delta * 9))
			kick = maxf(0, kick - delta * 2.5)
			camera.h_offset = sin(now() * 65) * kick * 0.07
			if deadline - now() < 10 and not warning_played:
				warning_played = true
				announce("TEN SECONDS! This is not the extended edition!")
	ui.update_hud(self)

func _input(event: InputEvent) -> void:
	if not focused: return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		holding = false
	if event is InputEventKey and event.pressed and not event.echo and state == State.RUN:
		if now() >= deadline: return
		var index: int = [KEY_1, KEY_2, KEY_3, KEY_4].find(event.physical_keycode)
		if index >= 0: abilities.activate(index)

func _unhandled_input(event: InputEvent) -> void:
	if state != State.RUN: return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		holding = true
		attack_mouse()

func mouse_tile() -> Vector2i:
	var mouse := get_viewport().get_mouse_position()
	var ray_from := camera.project_ray_origin(mouse)
	var direction := camera.project_ray_normal(mouse)
	var point = Plane(Vector3.UP, 0).intersects_ray(ray_from, direction)
	if point == null: return Vector2i(-999, -999)
	return Vector2i(roundi(point.x), roundi(point.z))

func attack_mouse() -> void:
	if state != State.RUN or now() >= deadline or now() < attack_ready: return
	var p := mouse_tile()
	var difference := p - player.tile
	if absi(difference.x) + absi(difference.y) != 1 or not map.junk.has(p): return
	var interval := progress.attack_interval()
	if now() < abilities.boost_until: interval = maxf(float(progress.balance.attack_floor), interval / 1.35)
	attack_ready = now() + interval
	player.swing(difference)
	sound.play_sound("hit%d" % int(map.junk[p].kind))
	abilities.basic_hit(p)
	if attempt == 1 and onboarding == "smash": onboarding = "cash"
	kick = 0.35

func update_target() -> void:
	var p := mouse_tile()
	var offset := p - player.tile
	target.visible = map.junk.has(p) and absi(offset.x) + absi(offset.y) == 1 and get_viewport().gui_get_hovered_control() == null
	if target.visible:
		target.position = Vector3(p.x, 0.92, p.y)
		ui.hint.text = "%d / %d" % [ceili(map.junk[p].hp), int(map.junk[p].max)]
	else:
		ui.hint.text = ""

func collect_current() -> void:
	if state != State.RUN: return
	var amount := map.take_cash(player.tile)
	if amount > 0:
		progress.wallet += amount
		if attempt == 1: onboarding = "explore"
		player.celebrate()
		sound.play_sound("coin")
	var stand: Vector2i = player.tile + Vector2i.DOWN
	if not map.stands.has(stand): return
	var tier := int(map.stands[stand])
	if tier == 4:
		win()
	elif not tier in progress.unlocked:
		progress.unlocked.append(tier)
		map.take_disk(stand)
		sound.play_sound("ability")
		announce("%s DISK! Your next shop just got louder." % DiskUI.TIERS[tier])

func buy_offer(index: int) -> void:
	if not valid_shop() or pending >= 0 or index >= progress.offers.size() or progress.offers[index].is_empty(): return
	var offer: Dictionary = progress.offers[index]
	if offer.kind == "ability" and progress.slots.size() >= progress.slot_count:
		pending = index
	elif progress.buy(index):
		sound.play_sound("shop")
		if attempt == 1: onboarding = "done"
	ui.shop(progress, pending, attempt == 1 and onboarding != "done")

func replace_ability(index: int) -> void:
	if not valid_shop() or pending < 0: return
	if progress.buy(pending, index):
		pending = -1
		if attempt == 1: onboarding = "done"
		sound.play_sound("shop")
	ui.shop(progress, pending, attempt == 1 and onboarding != "done")

func announce(text: String) -> void:
	ui.say(text)
	sound.play_sound("host")

func win() -> void:
	if state != State.RUN: return
	state = State.VICTORY
	player.finish()
	camera.h_offset = 0
	for child in map.root.get_children():
		if child.get_script() == IMPACT: child.queue_free()
	holding = false
	target.hide()
	abilities.generation += 1
	sound.play_sound("win")
	announce("DIAMOND STATUS! Somebody get this kid a microphone!")
	ui.victory(attempt, now() - session_start)

func effect(p: Vector2i, color: Color, radius: float) -> void:
	if state != State.RUN: return
	# Bound simultaneous bursts during chain reactions.
	if get_tree().get_nodes_in_group("impact").size() >= 24: return
	var burst := Node3D.new()
	burst.set_script(IMPACT)
	map.root.add_child(burst)
	burst.add_to_group("impact")
	burst.setup(p, color, radius)
	kick = maxf(kick, minf(radius * 0.15, 0.7))

func _notification(what: int) -> void:
	if what in [NOTIFICATION_APPLICATION_FOCUS_OUT, NOTIFICATION_WM_WINDOW_FOCUS_OUT]:
		focused = false
		holding = false
	elif what in [NOTIFICATION_APPLICATION_FOCUS_IN, NOTIFICATION_WM_WINDOW_FOCUS_IN]:
		focused = true
		holding = false

func _web_focus_changed(args: Array) -> void:
	focused = bool(args[0])
	holding = false

func _exit_tree() -> void:
	if OS.has_feature("web"):
		JavaScriptBridge.eval("if (window.diskShopRemoveFocus) window.diskShopRemoveFocus();")
