extends CanvasLayer
class_name DiskUI

signal start_requested
signal leave_requested
signal reroll_requested
signal buy_requested(index: int)
signal replace_requested(index: int)
signal cancel_requested
signal slot_requested
signal restart_requested

const INK = Color("181124")
const CREAM = Color("fff0cf")
const MINT = Color("b9ed55")
const GOLD = Color("ff784b")
const DISPLAY_FONT = preload("res://assets/fonts/Bungee-Regular.ttf")
const UI_FONT = preload("res://assets/fonts/SpaceGrotesk-Medium.tres")
const BUTTON_FONT = preload("res://assets/fonts/SpaceGrotesk-Semibold.tres")
const MARKER_FONT = preload("res://assets/fonts/PermanentMarker-Regular.ttf")
const TIERS = ["COMMON", "SILVER", "GOLD", "PLATINUM"]
const TIER_FILLS = [Color("303b30"), Color("344855"), Color("66502b"), Color("59436f")]
const TIER_EDGES = [Color("b9ed55"), Color("c3dfeb"), Color("ffd36f"), Color("dfb5ff")]
const DISK_COLORS = {"stat": Color("b9ed55"), "upgrade": Color("64d9ed"), "ability": Color("ec66b6")}
var root: Control
var top: Label
var clock_label: Label
var host: Label
var hint: Label
var slots_box: HBoxContainer
var slot_labels: Array[Label] = []
var modal: PanelContainer
var body: VBoxContainer
var shop_clock: Label
var odds_label: Label
var cards: HBoxContainer
var pending_box: VBoxContainer
var modal_kind := ""
var slot_icons: Array[RecordIcon] = []
var host_motion: Tween
var menu_records: Array[RecordIcon] = []
var tutorial: Label
var curtain: ColorRect
var travel: Label
signal ui_feedback

func _ready() -> void:
	root = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	var theme := Theme.new()
	theme.default_font = UI_FONT
	theme.set_font("font", "Button", BUTTON_FONT)
	theme.default_font_size = 19
	theme.set_color("font_color", "Label", CREAM)
	theme.set_color("font_color", "Button", INK)
	theme.set_color("font_hover_color", "Button", INK)
	theme.set_color("font_pressed_color", "Button", INK)
	theme.set_color("font_disabled_color", "Button", Color("7c8c8d"))
	theme.set_stylebox("normal", "Button", style(MINT, 9))
	theme.set_stylebox("hover", "Button", style(Color("d3ffe3"), 9))
	theme.set_stylebox("pressed", "Button", style(GOLD, 9))
	theme.set_stylebox("disabled", "Button", style(Color("293d44"), 9))
	root.theme = theme
	top = label("SMASH THE RECORD", 22)
	top.position = Vector2(28, 22)
	top.add_theme_stylebox_override("normal", hud_panel())
	top.custom_minimum_size = Vector2(250, 58)
	top.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	top.mouse_filter = Control.MOUSE_FILTER_STOP
	root.add_child(top)
	clock_label = label("60", 48)
	clock_label.add_theme_font_override("font", DISPLAY_FONT)
	clock_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	clock_label.position = Vector2(-126, 18)
	clock_label.size = Vector2(102, 76)
	clock_label.add_theme_stylebox_override("normal", hud_panel())
	clock_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	clock_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	clock_label.mouse_filter = Control.MOUSE_FILTER_STOP
	root.add_child(clock_label)
	host = label("", 19)
	host.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	host.position = Vector2(-330, 18)
	host.size = Vector2(660, 62)
	host.add_theme_stylebox_override("normal", hud_panel())
	host.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	host.mouse_filter = Control.MOUSE_FILTER_STOP
	host.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	host.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(host)
	host.hide()
	hint = label("", 15)
	hint.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	hint.position = Vector2(28, -34)
	root.add_child(hint)
	slots_box = HBoxContainer.new()
	slots_box.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	slots_box.position = Vector2(-212, -116)
	slots_box.add_theme_constant_override("separation", 10)
	slots_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(slots_box)
	for i in range(4):
		var panel := PanelContainer.new()
		panel.add_theme_stylebox_override("panel", style(INK, 8))
		panel.custom_minimum_size = Vector2(98, 90)
		panel.mouse_filter = Control.MOUSE_FILTER_STOP
		slots_box.add_child(panel)
		var column := VBoxContainer.new()
		panel.add_child(column)
		var icon := RecordIcon.new()
		icon.custom_minimum_size = Vector2(52, 52)
		column.add_child(icon)
		slot_icons.append(icon)
		var text := label("", 14)
		text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		column.add_child(text)
		slot_labels.append(text)
	modal = PanelContainer.new()
	modal.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	modal.position = Vector2(-350, -255)
	modal.custom_minimum_size = Vector2(700, 490)
	modal.add_theme_stylebox_override("panel", style(INK, 18))
	root.add_child(modal)
	body = VBoxContainer.new()
	body.add_theme_constant_override("separation", 14)
	modal.add_child(body)
	modal.hide()
	tutorial = label("", 18)
	tutorial.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	tutorial.position = Vector2(-450, -196)
	tutorial.size = Vector2(900, 64)
	tutorial.add_theme_stylebox_override("normal", style(INK, 8))
	tutorial.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tutorial.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tutorial.add_theme_color_override("font_color", MINT)
	root.add_child(tutorial)
	tutorial.hide()
	curtain = ColorRect.new()
	curtain.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	curtain.color = Color(0, 0, 0, 0)
	curtain.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(curtain)
	travel = label("", 26)
	travel.add_theme_font_override("font", DISPLAY_FONT)
	travel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	travel.position = Vector2(-400, -30)
	travel.size = Vector2(800, 60)
	travel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(travel)
	travel.hide()

func hud_panel() -> StyleBoxFlat:
	var panel := style(Color("181124ed"), 8)
	panel.content_margin_left = 14
	panel.content_margin_right = 14
	panel.content_margin_top = 8
	panel.content_margin_bottom = 8
	return panel

func style(color: Color, radius: int) -> StyleBoxFlat:
	var result := StyleBoxFlat.new()
	result.bg_color = color
	result.set_corner_radius_all(mini(radius, 3))
	result.border_color = Color("695281")
	result.set_border_width_all(2)
	result.shadow_color = Color(0, 0, 0, 0.65)
	result.shadow_size = 7
	result.content_margin_left = 18
	result.content_margin_right = 18
	result.content_margin_top = 12
	result.content_margin_bottom = 12
	return result

func label(text: String, font_size: int = 20) -> Label:
	var result := Label.new()
	result.text = text
	result.add_theme_font_size_override("font_size", font_size)
	result.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return result

func button(text: String, action: Callable) -> Button:
	var result := Button.new()
	result.text = text
	result.custom_minimum_size.y = 42
	result.focus_mode = Control.FOCUS_NONE
	result.pressed.connect(func(): ui_feedback.emit())
	result.pressed.connect(action)
	result.mouse_entered.connect(func():
		if not result.is_inside_tree(): return
		result.pivot_offset = result.size * 0.5
		result.create_tween().tween_property(result, "scale", Vector2(1.035, 1.035), 0.12).set_trans(Tween.TRANS_BACK))
	result.mouse_exited.connect(func():
		if result.is_inside_tree(): result.create_tween().tween_property(result, "scale", Vector2.ONE, 0.12))
	return result

func heading(text: String, font_size: int) -> Label:
	var result := label(text, font_size)
	result.add_theme_font_override("font", DISPLAY_FONT)
	return result

func accent(text: String, font_size: int) -> Label:
	var result := label(text, font_size)
	result.add_theme_font_override("font", MARKER_FONT)
	return result

func clear_body(kind: String) -> void:
	menu_records.clear()
	body.add_theme_constant_override("separation", 14)
	for child in body.get_children():
		body.remove_child(child)
		child.queue_free()
	modal_kind = kind
	modal.show()
	modal.modulate.a = 0
	create_tween().tween_property(modal, "modulate:a", 1.0, 0.16)

func title() -> void:
	clear_body("title")
	modal.position = Vector2(550, 100)
	body.add_child(label("B1 / UNDERGROUND RECORDS", 17))
	var logo := heading("SMASH THE\nRECORD", 54)
	logo.add_theme_color_override("font_color", CREAM)
	logo.add_theme_color_override("font_outline_color", INK)
	logo.add_theme_constant_override("outline_size", 8)
	logo.add_theme_color_override("font_shadow_color", GOLD)
	logo.add_theme_constant_override("shadow_offset_x", 5)
	logo.add_theme_constant_override("shadow_offset_y", 5)
	logo.rotation = -0.035
	body.add_child(logo)
	var deck := HBoxContainer.new()
	deck.alignment = BoxContainer.ALIGNMENT_CENTER
	deck.add_theme_constant_override("separation", 30)
	body.add_child(deck)
	for i in range(3):
		var art := RecordIcon.new()
		art.id = ["bass", "damage", "feedback"][i]
		art.accent = [Color("ec66b6"), MINT, Color("64d9ed")][i]
		art.custom_minimum_size = Vector2(140, 140)
		deck.add_child(art)
		menu_records.append(art)
	body.add_child(accent("SMASH. DIG. GET LOUD.", 25))
	var start_button := button("DROP IN", func(): start_requested.emit())
	start_button.add_theme_font_override("font", DISPLAY_FONT)
	body.add_child(start_button)
	body.add_child(button("HOW TO PLAY", show_controls))

func _process(_delta: float) -> void:
	for i in range(menu_records.size()):
		var art := menu_records[i]
		art.pivot_offset = art.size * 0.5
		art.rotation = sin(Time.get_ticks_msec() * 0.0015 + i) * 0.14
		art.scale = Vector2.ONE * (1.0 + sin(Time.get_ticks_msec() * 0.006 + i) * 0.025)

func show_controls() -> void:
	clear_body("controls")
	body.add_child(heading("THE FIRST PRESSING", 32))
	body.add_child(label("WASD   Move / face\nCLICK + HOLD   Smash adjacent junk\n1 / 2 / 3 / 4   Active records\n\nCollect the cash. Upgrade in the elevator.\nReach the diamond record. Every run: 60 seconds.", 22))
	body.add_child(button("BACK", title))
func shop(progress: ShopProgression, pending: int, first_visit: bool = false) -> void:
	clear_body("shop")
	body.add_theme_constant_override("separation", 10)
	modal.position = Vector2(550, 85)
	shop_clock = heading("ELEVATOR / NEXT SET", 25)
	body.add_child(shop_clock)
	var guide := label("BUY YOUR FIRST UPGRADE / Purchases last all session." if first_visit else "STATS  /  ABILITY UPGRADES  /  NEW ABILITIES", 15)
	body.add_child(guide)
	var legend := HBoxContainer.new()
	legend.add_theme_constant_override("separation", 18)
	body.add_child(legend)
	for kind in ["stat", "upgrade", "ability"]:
		var key := label({"stat": "STATS", "upgrade": "UPGRADES", "ability": "ABILITIES"}[kind], 14)
		key.add_theme_color_override("font_color", DISK_COLORS[kind])
		legend.add_child(key)
	
	odds_label = label("", 15)
	var weights := progress.odds()
	var odds_text: Array[String] = []
	for i in range(4): odds_text.append("%s %.1f%%" % [TIERS[i], weights[i] * 100])
	odds_label.text = "  /  ".join(odds_text)
	body.add_child(odds_label)
	cards = HBoxContainer.new()
	cards.add_theme_constant_override("separation", 12)
	body.add_child(cards)
	for i in range(progress.offers.size()):
		var offer: Dictionary = progress.offers[i]
		var panel := PanelContainer.new()
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		panel.custom_minimum_size = Vector2(198, 210)
		var tier: int = int(offer.get("tier", 0))
		var card_style := style(TIER_FILLS[tier] if not offer.is_empty() else INK, 8)
		card_style.border_color = TIER_EDGES[tier] if not offer.is_empty() else Color("695281")
		panel.add_theme_stylebox_override("panel", card_style)
		cards.add_child(panel)
		var column := VBoxContainer.new()
		column.add_theme_constant_override("separation", 8)
		panel.add_child(column)
		if offer.is_empty():
			column.add_child(label("SOLD", 22))
			continue
		var id: String = offer.id
		column.add_child(label(TIERS[int(offer.tier)] + " / " + str(offer.kind).to_upper(), 13))
		var title_text: String
		var description: String
		if offer.kind == "stat":
			title_text = {"damage": "Heavy Hands", "attack": "Quick Cuts", "move": "Fresh Sneakers"}[id]
			description = {"damage": "+1 smash damage.", "attack": "Smash 10% faster.", "move": "Move 8% faster."}[id]
		else:
			title_text = progress.abilities[id].name
			if offer.kind == "upgrade": title_text += " / L%d" % (progress.level(id) + 1)
			description = progress.abilities[id].description
		var icon := RecordIcon.new()
		icon.id = id
		icon.accent = DISK_COLORS[offer.kind]
		icon.colored_disk = true
		icon.custom_minimum_size = Vector2(120, 108 if pending < 0 else 80)
		column.add_child(icon)
		column.add_child(label(title_text, 18))
		panel.tooltip_text = description
		var buy := button("$%d  /  BUY" % offer.price, func(): buy_requested.emit(i))
		var credit := 0
		if offer.kind == "ability" and progress.slots.size() >= progress.slot_count:
			for s in range(progress.slots.size()): credit = maxi(credit, progress.refund(s))
		buy.disabled = progress.wallet + credit < int(offer.price) or pending >= 0
		column.add_child(buy)
	var controls := HBoxContainer.new()
	controls.add_theme_constant_override("separation", 12)
	body.add_child(controls)
	var reroll := button("REROLL / $%d" % progress.balance.reroll_price, func(): reroll_requested.emit())
	reroll.disabled = progress.wallet < int(progress.balance.reroll_price) or pending >= 0
	controls.add_child(reroll)
	if progress.slot_count < 4:
		var price := int(progress.balance.slot_prices[progress.slot_count - 2])
		var unlock := button("SLOT %d / $%d" % [progress.slot_count + 1, price], func(): slot_requested.emit())
		unlock.disabled = progress.wallet < price or pending >= 0
		controls.add_child(unlock)
	controls.add_child(button("OPEN DOORS", func(): leave_requested.emit()))
	if pending >= 0:
		body.add_child(label("REPLACE / 50% refund / upgrades retained", 15))
		var replacements := GridContainer.new()
		replacements.columns = 3
		replacements.add_theme_constant_override("separation", 8)
		body.add_child(replacements)
		for i in range(progress.slots.size()):
			var replace := button("%d: %s\n+$%d" % [i + 1, progress.abilities[progress.slots[i]].name, progress.refund(i)], func(): replace_requested.emit(i))
			replace.add_theme_font_size_override("font_size", 14)
			replace.disabled = progress.wallet + progress.refund(i) < int(progress.offers[pending].price)
			replacements.add_child(replace)
		replacements.add_child(button("CANCEL", func(): cancel_requested.emit()))

func victory(attempts: int, seconds: float) -> void:
	clear_body("victory")
	modal.position = Vector2(290, 120)
	body.add_child(heading("DIAMOND STATUS", 42))
	body.add_child(accent("From stockroom to headline act.", 27))
	body.add_child(label("%d SETS  /  %02d:%02d TOTAL" % [attempts, int(seconds) / 60, int(seconds) % 60], 25))
	body.add_child(label("The mall is closed. Your career is open.", 20))
	body.add_child(button("FRESH SESSION", func(): restart_requested.emit()))

func update_hud(game: Node) -> void:
	host.visible = not host.text.is_empty() and host.modulate.a > 0.01
	var progress: ShopProgression = game.progress
	var running: bool = game.state == game.State.RUN
	tutorial.visible = running and game.attempt == 1
	if game.state == game.State.SHOP:
		tutorial.text = "Buy a colored disk to upgrade. OPEN DOORS starts your next round."
	else:
		tutorial.text = {"smash": "WASD to the trash. CLICK adjacent trash to swing your bat; HOLD to keep swinging.", "cash": "Keep smashing, then WALK over the green cash to collect it.", "explore": "Follow the aisles to the diamond. Press 1 for Bass Drop; spend cash after the round.", "done": ""}[game.onboarding]
	top.visible = game.state in [game.State.RUN, game.State.SHOP]
	clock_label.visible = running
	slots_box.visible = running
	hint.visible = running
	top.text = "$%d   /   %d LP" % [progress.wallet, progress.unlocked.size()]
	var remaining := maxi(0, ceili(game.deadline - game.now()))
	clock_label.text = "%02d" % remaining
	clock_label.modulate = GOLD if remaining <= 10 else CREAM
	clock_label.scale = Vector2.ONE * (1.0 + 0.04 * sin(game.now() * 10.0)) if running and remaining <= 10 else Vector2.ONE
	if modal_kind == "shop" and is_instance_valid(shop_clock):
		shop_clock.text = "TRACK-O-MATIC   /   %02ds" % remaining
	for i in range(4):
		var text := "" if i >= progress.slot_count else str(i + 1)
		var icon := slot_icons[i]
		icon.visible = true
		icon.id = "locked" if i >= progress.slot_count else "empty"
		icon.colored_disk = false
		icon.modulate.a = 0.35
		icon.progress = 1.0
		icon.get_parent().get_parent().tooltip_text = "Buy another slot in the elevator." if i >= progress.slot_count else "An empty record slot."
		if i < progress.slots.size():
			var id: String = progress.slots[i]
			var data: Dictionary = progress.abilities[id]
			icon.id = id
			icon.accent = DISK_COLORS.ability
			icon.colored_disk = true
			icon.tooltip_text = data.name + " / " + data.description
			icon.get_parent().get_parent().tooltip_text = icon.tooltip_text
			if data.active:
				text = str(i + 1) + "  " + "|".repeat(int(game.abilities.charges.get(id, data.charges)))
				icon.progress = 1.0
				icon.modulate.a = 1.0 if int(game.abilities.charges.get(id, 0)) > 0 else 0.35
			else:
				var wait := maxf(0, float(game.abilities.ready_at.get(id, 0)) - game.now())
				text = "AUTO" if wait <= 0 else "%.1f" % wait
				icon.progress = 1.0 - clampf(wait / game.abilities.cooldown(id), 0, 1)
				icon.modulate.a = 1.0 if wait <= 0 else 0.55
		icon.queue_redraw()
		slot_labels[i].text = text

func say(text: String) -> void:
	if host_motion != null: host_motion.kill()
	host.show()
	host.text = text
	host.modulate = GOLD
	host_motion = create_tween()
	host_motion.tween_property(host, "modulate", CREAM, 0.2)
	host_motion.tween_interval(3.0)
	host_motion.tween_property(host, "modulate:a", 0.0, 0.4)
