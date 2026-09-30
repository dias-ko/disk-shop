extends SceneTree

var failures := 0
var checks := 0

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("FAIL: " + message)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var p := ShopProgression.new()
	check(p.abilities.size() == 12, "12 abilities exist")
	check(p.odds() == [1.0, 0.0, 0.0, 0.0], "initial common-only odds")
	p.unlocked = [2]
	check(is_equal_approx(p.odds()[2], 1.0 / 7.0), "out-of-order gold unlock")
	p.unlocked = [1, 2, 3]
	p.rng.seed = 100
	var rolls := [0, 0, 0, 0]
	for i in range(3000):
		p.roll()
		for offer in p.offers: rolls[int(offer.tier)] += 1
	for i in range(4):
		check(absf(rolls[i] / 9000.0 - p.odds()[i]) < 0.025, "tier %d roll distribution" % i)
	p.wallet = 100
	p.offers = [{"id":"pierce", "kind":"ability", "tier":0, "price":15}]
	check(p.buy(0) and p.wallet == 85 and p.slots.size() == 2, "ability purchase")
	p.levels.pierce = 3
	p.offers = [{"id":"dash", "kind":"ability", "tier":1, "price":35}]
	check(not p.buy(0) and p.wallet == 85, "full slots require replacement")
	check(p.buy(0, 1) and p.wallet == 57 and p.level("pierce") == 3, "atomic 50 percent refund and retained level")
	p.offers = [{"id":"pierce", "kind":"ability", "tier":0, "price":15}]
	check(p.buy(0, 1) and p.level("pierce") == 3 and p.wallet == 59, "rebuy retains upgrades")
	check(not p.buy(0, 1) and p.wallet == 59, "sold purchase cannot repeat")
	p.wallet = 0
	p.offers = [{"id":"rush", "kind":"ability", "tier":3, "price":120}]
	check(not p.buy(0, 1) and p.wallet == 0, "failed transaction cannot refund")

	var scene := load("res://scenes/main.tscn") as PackedScene
	var game = scene.instantiate()
	root.add_child(game)
	await process_frame
	check(game.state == game.State.TITLE, "title initializes")
	check(not game.sound.music.playing, "music waits for start interaction")
	game.sound.music_rng.seed = 1729
	for mode in ["run", "elevator"]:
		var seen: Array = []
		var last: AudioStream
		var rotation_valid := true
		var resources_valid := true
		for i in range(game.sound.MUSIC_TRACKS[mode].size() * 20):
			var track: AudioStream = game.sound.next_track(mode)
			rotation_valid = rotation_valid and track != last and not track in seen
			resources_valid = resources_valid and track.get_length() > 0 and not track.loop
			seen.append(track)
			last = track
			if seen.size() == game.sound.MUSIC_TRACKS[mode].size(): seen.clear()
		check(rotation_valid, "%s soundtrack exhausts variations with no repeat at cycle boundaries" % mode)
		check(resources_valid, "%s uploaded tracks are valid and do not loop individually" % mode)
	var original_tiles: String = game.map.layout.tiles
	var rectangle := true
	for row in game.map.layout.rows():
		rectangle = rectangle and row.length() == 31 and not row.contains(" ") and row.begins_with("#") and row.ends_with("#")
	check(rectangle, "store has a rectangular footprint and solid side walls")
	var edited: String = game.map.layout.painted(Vector2i(15, 2), "2")
	check(edited != original_tiles, "editable layout supports painting")
	game.map.layout.tiles = edited
	game.map.reset_map([])
	check(game.map.junk.has(Vector2i(15, 2)), "map uses edited resource")
	game.map.layout.tiles = original_tiles
	game.map.reset_map([])
	var accessible: Array[Vector2i] = [game.map.spawn]
	var visited := {game.map.spawn: true}
	var cursor := 0
	while cursor < accessible.size():
		var pos := accessible[cursor]
		cursor += 1
		for dir in ShopMap.DIRS:
			var next: Vector2i = pos + dir
			if not visited.has(next) and not game.map.solid(next):
				visited[next] = true
				accessible.append(next)
	for stand in game.map.stands:
		check(visited.has(stand + Vector2i.UP), "disk approach connected: %s" % str(stand))
	game.start_session()
	check(game.sound.music_mode == "elevator" and game.sound.music.playing, "departure starts elevator soundtrack after interaction")
	check(game.state == game.State.REVEAL and game.progress.offers.is_empty() and game.ui.modal_kind != "shop", "first start bypasses shop")
	check(game.state == game.State.REVEAL and game.attempt == 0, "first reveal excludes run")
	game.camera_motion.kill()
	game.begin_run()
	check(game.sound.music_mode == "run", "run switches to sprint soundtrack")
	var first_track: AudioStream = game.sound.music.stream
	game.sound.music.finished.emit()
	check(game.sound.music.stream != first_track and game.sound.music.playing, "finished track advances to another variation")
	first_track = game.sound.music.stream
	game.sound.set_music_mode("run")
	check(game.sound.music.stream == first_track, "same phase preserves playing track")
	game.ui.update_hud(game)
	check(game.ui.tutorial.visible and game.ui.tutorial.text.contains("bat"), "first run shows persistent bat guidance")
	var original_count: int = game.map.junk.size()
	var box := Vector2i(15, 4)
	game.player.reset_to(box + Vector2i.UP)
	game.abilities.hit(box, 999)
	check(not game.map.junk.has(box) and game.map.cash.has(box) and game.progress.wallet == 0, "destruction drops cash without awarding")
	game.player.reset_to(box)
	game.collect_current()
	check(game.progress.wallet > 0 and not game.map.cash.has(box), "stepping collects cash")
	check(game.onboarding == "explore", "first collection advances onboarding")
	var wallet: int = game.progress.wallet
	game.enter_shop()
	check(game.sound.music_mode == "elevator", "shop switches to elevator soundtrack")
	check(game.map.junk.size() == original_count and game.progress.wallet == wallet, "map reset preserves wallet")
	game.progress.wallet = 20
	game.progress.offers.assign([{"id":"damage", "kind":"stat", "tier":0, "price":10}])
	game.buy_offer(0)
	check(game.onboarding == "done" and game.progress.stats.damage == 1, "first purchase completes shop introduction")
	game.progress.slots.assign(["bass", "pierce", "double", "feedback", "dash", "magnet", "hat", "sample", "sub", "remix", "rush", "encore"])
	game.begin_run()
	game.abilities.reset_run()
	game.player.reset_to(Vector2i(15, 3))
	var charges: int = game.abilities.charges.bass
	game.abilities.activate(0)
	check(game.abilities.charges.bass == charges - 1, "active consumes charge")
	game.abilities.activate(1)
	game.abilities.activate(2)
	check(game.abilities.boost_until > game.now(), "double time activates")
	game.abilities.activate(4)
	game.abilities.activate(9)
	game.abilities.activate(10)
	game.abilities.tick()
	await create_timer(0.3).timeout
	game.map.add_cash(game.player.tile, 10)
	var before: int = game.progress.wallet
	game.abilities.magnet(2)
	check(game.progress.wallet >= before + 10, "magnet collects reachable cash")
	game.player.reset_to(Vector2i(21, 19))
	game.collect_current()
	check(2 in game.progress.unlocked and not 1 in game.progress.unlocked, "gold collected before silver")
	game.enter_shop()
	check(game.map.cash.has(Vector2i(21, 19)), "unlocked disk replaced by cash next run")
	check(game.abilities.boost_until == 0 and game.abilities.marks.is_empty(), "transient effects reset")
	game.progress.slots.assign(["bass", "pierce"])
	game.progress.slot_count = 2
	game.progress.offers.assign([{"id":"dash", "kind":"ability", "tier":1, "price":35}])
	game.progress.wallet = 100
	game.buy_offer(0)
	check(game.pending == 0, "replacement opens")
	game.deadline = game.now() - 1
	game._process(0.01)
	check(game.state == game.State.REVEAL and game.pending == -1 and game.progress.wallet == 100, "shop expiry cancels without charge before elevator departure")
	await create_timer(0.8).timeout
	check(game.state == game.State.RUN and game.deadline - game.now() > 59, "elevator departure excludes run time")
	game.deadline = game.now() - 1
	game._process(0.01)
	check(game.state == game.State.RETURN and game.player.frozen, "run deadline disables gameplay for return transition")
	check(game.sound.music_mode == "elevator", "timeout switches music immediately without starting a brief extra run track")
	var return_wallet: int = game.progress.wallet
	game.buy_offer(0)
	check(game.progress.wallet == return_wallet, "return transition rejects purchases")
	await create_timer(1.2).timeout
	check(game.state == game.State.SHOP and game.deadline - game.now() > 29, "arrival starts full shop clock")
	check(game.ui.curtain.color.a == 0 and not game.ui.travel.visible, "return fade clears after arrival")
	game.focused = false
	game.deadline = game.now() - 100
	var attempts_before: int = game.attempt
	game._process(0.1)
	game._process(0.1)
	check(game.state == game.State.SHOP and game.attempt == attempts_before, "hidden tab cannot run unattended attempts")
	game.focused = true
	game._process(0.1)
	check(game.state == game.State.REVEAL and game.pending == -1, "focus return resolves expired shop once")
	await create_timer(0.8).timeout
	game.enter_shop()
	game.leave_shop()
	await create_timer(0.8).timeout
	game.player.reset_to(game.map.diamond)
	game.collect_current()
	check(game.state == game.State.VICTORY, "diamond wins")
	check(game.player.frozen and not game.player.trail.visible, "victory stops player animation and swing effects")
	current_scene = game
	game.ui.body.get_child(game.ui.body.get_child_count() - 1).pressed.emit()
	await create_timer(0.4).timeout
	check(current_scene.state == current_scene.State.TITLE, "restart button returns to title")
	check(current_scene.progress.wallet == 0 and current_scene.attempt == 0 and current_scene.progress.slots.size() == 1, "restart clears progression")
	current_scene.queue_free()
	await process_frame
	await create_timer(0.35).timeout
	print("REGRESSION: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
