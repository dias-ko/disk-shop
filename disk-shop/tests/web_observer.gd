extends RefCounted

# Read-only instrumentation for explicit debug browser playtests. Never mutates a session.
static func sample(game: Node) -> void:
	var buttons: Array = []
	for node in game.ui.root.find_children("*", "Button", true, false):
		if node.is_visible_in_tree():
			var rect: Rect2 = node.get_global_rect()
			buttons.append({"text": node.text, "disabled": node.disabled, "x": rect.get_center().x, "y": rect.get_center().y})
	var junk: Array = []
	for p in game.map.junk:
		junk.append([p.x, p.y, game.map.junk[p].hp])
	var screen: Array = []
	for dir in ShopMap.DIRS:
		var p: Vector2i = game.player.tile + dir
		var pos: Vector2 = game.camera.unproject_position(Vector3(p.x, 0, p.y))
		screen.append([dir.x, dir.y, pos.x, pos.y])
	var data := {"state": game.state, "tile": [game.player.tile.x, game.player.tile.y], "seconds": game.deadline - game.now(), "wallet": game.progress.wallet, "attempt": game.attempt, "offers": game.progress.offers, "slots": game.progress.slots, "charges": game.abilities.charges, "buttons": buttons, "junk": junk, "adjacent": screen, "damage": game.progress.damage(), "interval": game.progress.attack_interval(), "fps": Engine.get_frames_per_second(), "ui": game.ui.modal_kind, "size": [game.get_viewport().get_visible_rect().size.x, game.get_viewport().get_visible_rect().size.y]}
	data["music"] = {"mode": game.sound.music_mode, "track": game.sound.music.stream.resource_path if game.sound.music.stream != null else "", "playing": game.sound.music.playing}
	JavaScriptBridge.eval("window.diskShopSnapshot = " + JSON.stringify(data))
