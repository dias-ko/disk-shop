extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func capture(name: String) -> void:
	await create_timer(0.5).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://../.checks/" + name + ".png")

func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await capture("menu")
	game.start_session()
	await create_timer(4.2).timeout
	await capture("run")
	# Clear a small valid patch before positioning the presentation camera.
	for x in range(14, 17):
		for y in range(11, 14): game.map.damage(Vector2i(x, y), 1000)
	game.player.reset_to(Vector2i(15, 12))
	await capture("aisles")
	game.player.reset_to(game.map.diamond)
	await capture("disk_glow")
	game.return_to_elevator()
	await create_timer(0.2).timeout
	await capture("return")
	await create_timer(0.8).timeout
	await capture("elevator")
	game.progress.wallet = 300
	game.enter_shop()
	game.progress.unlocked = [1, 2, 3]
	game.progress.offers.assign([{"id":"damage", "kind":"stat", "tier":0, "price":10}, {"id":"feedback", "kind":"upgrade", "tier":1, "price":21}, {"id":"sub", "kind":"ability", "tier":2, "price":70}])
	game.ui.shop(game.progress, -1)
	await capture("disk_colors")
	game.progress.slots.assign(["bass", "pierce", "double", "dash"])
	game.progress.slot_count = 4
	game.progress.offers.assign([{"id":"rush", "kind":"ability", "tier":3, "price":120}, {}, {}])
	game.buy_offer(0)
	await capture("replacement")
	game.queue_free()
	await process_frame
	quit()
