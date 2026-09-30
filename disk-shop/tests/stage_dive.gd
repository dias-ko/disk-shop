extends SceneTree

var failures := 0
var checks := 0
const ROOM = "#######\n#.....#\n#..3..#\n#E244.#\n#..3..#\n#.....#\n#######"

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("FAIL: " + message)

func _initialize() -> void:
	call_deferred("run")

func prepare(game: Node, tiles := ROOM) -> void:
	game.state = game.State.RUN
	game.deadline = game.now() + 60
	game.map.layout.tiles = tiles
	game.map.reset_map([])
	game.progress.wallet = 0
	game.progress.slots.assign(["dash", "encore"])
	game.progress.levels.dash = 1
	game.abilities.reset_run()
	game.player.reset_to(Vector2i(1, 3))
	game.player.facing = Vector2i.RIGHT

func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	prepare(game)
	game.map.add_cash(Vector2i(2, 3), 7)
	game.player.move_to(Vector2i(1, 3), 0.5)
	game.abilities.activate(0)
	check(game.player.tile == Vector2i(4, 3) and game.player.position == Vector3(4, 0, 3), "teleport commits logical and visual landing immediately")
	check(game.player.facing == Vector2i.RIGHT, "teleport preserves facing")
	check(not game.map.junk.has(Vector2i(4, 3)) and game.progress.wallet == 18, "36 HP landing junk breaks instantly and its cash is collected once")
	check(game.map.junk[Vector2i(2, 3)].hp == 6 and game.map.junk[Vector2i(3, 3)].hp == 36, "intermediate junk is skipped without damage")
	check(game.map.cash.get(Vector2i(2, 3)) == 7, "intermediate cash stays uncollected")
	check(game.abilities.charges.dash == 2, "successful teleport spends one charge")
	check(game.abilities.ready_at.encore == 0, "instant break cannot trigger Encore")
	await create_timer(0.3).timeout
	check(game.player.position == Vector3(4, 0, 3) and game.progress.wallet == 18, "old movement tween and delayed echoes cannot undo teleport or duplicate payout")
	prepare(game, ROOM.replace("#E244.#", "#E24..#"))
	game.map.add_cash(Vector2i(4, 3), 5)
	game.abilities.activate(0)
	check(game.player.tile == Vector2i(4, 3) and game.progress.wallet == 5 and game.abilities.charges.dash == 2, "empty landing teleports and collects only its existing cash")
	prepare(game, ROOM.replace("#E244.#", "#E2#4.#"))
	game.abilities.activate(0)
	check(game.player.tile == Vector2i(1, 3) and game.abilities.charges.dash == 3 and game.map.junk.has(Vector2i(4, 3)), "intermediate wall cancels without charge or destruction")
	prepare(game, ROOM.replace("#E244.#", "#E24S.#"))
	game.abilities.activate(0)
	check(game.player.tile == Vector2i(1, 3) and game.abilities.charges.dash == 3, "stand cannot be a landing destination")
	prepare(game)
	game.player.facing = Vector2i.LEFT
	game.abilities.activate(0)
	check(game.player.tile == Vector2i(1, 3) and game.abilities.charges.dash == 3, "edge cannot shorten or send teleport outside the map")
	for direction in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT]:
		prepare(game)
		var origin := Vector2i(3, 5) if direction == Vector2i.UP else Vector2i(3, 1) if direction == Vector2i.DOWN else Vector2i(5, 3)
		game.player.reset_to(origin)
		game.player.facing = direction
		game.abilities.activate(0)
		check(game.player.tile == origin + direction * 3 and game.player.facing == direction, "cardinal teleport: %s" % str(direction))
	prepare(game)
	game.abilities.marks[Vector2i(4, 3)] = {"until": game.now() + 6, "damage": 8.0}
	game.abilities.activate(0)
	check(not game.abilities.marks.has(Vector2i(4, 3)) and game.map.junk[Vector2i(3, 3)].hp == 28, "landing break uses normal Feedback explosion once")
	for level in [2, 3]:
		prepare(game)
		game.progress.levels.dash = level
		game.abilities.reset_run()
		check(game.abilities.charges.dash == 2 + level, "upgrade refills extra charges at level %d" % level)
		game.abilities.activate(0)
		check(game.player.tile == Vector2i(4, 3), "upgrades preserve the three-tile distance")
	prepare(game)
	game.abilities.charges.dash = 0
	game.abilities.activate(0)
	check(game.player.tile == Vector2i(1, 3) and game.map.junk.has(Vector2i(4, 3)), "no charges means no teleport or destruction")
	prepare(game)
	game.state = game.State.SHOP
	game.abilities.activate(0)
	check(game.player.tile == Vector2i(1, 3) and game.abilities.charges.dash == 3, "shop input cannot activate teleport")
	prepare(game, ROOM.replace("#..3..#\n#.....#\n#######", "#..4..#\n#..D..#\n#######"))
	game.player.reset_to(Vector2i(3, 1))
	game.abilities.activate(0)
	check(game.player.tile == Vector2i(3, 4) and game.state == game.State.VICTORY and game.player.frozen, "teleport onto diamond approach wins immediately")
	game.queue_free()
	await process_frame
	await create_timer(0.35).timeout
	print("STAGE DIVE: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
