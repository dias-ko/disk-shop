extends Node
class_name DiskAbilities

var game: Node
var charges: Dictionary = {}
var ready_at: Dictionary = {}
var marks: Dictionary = {}
var boost_until := 0.0
var generation := 0

func reset_run() -> void:
	generation += 1
	charges.clear()
	ready_at.clear()
	marks.clear()
	boost_until = 0
	for id in game.progress.slots:
		var data: Dictionary = game.progress.abilities[id]
		if data.active:
			charges[id] = int(data.charges) + int(data.get("charges_per_level", 0)) * (game.progress.level(id) - 1)
		ready_at[id] = 0.0

func cooldown(id: String) -> float:
	return maxf(1.0, float(game.progress.abilities[id].get("cooldown", 0)) - (game.progress.level(id) - 1) * 0.8)

func ready(id: String) -> bool:
	return id in game.progress.slots and game.now() >= float(ready_at.get(id, 0))

func consume_cooldown(id: String) -> void:
	ready_at[id] = game.now() + cooldown(id)

func targets(origin: Vector2i, radius: int, facing: Vector2i) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for d in range(1, radius + 1):
		var front := origin + facing * d
		if game.map.junk.has(front): result.append(front)
		for y in range(-d, d + 1):
			for x in range(-d, d + 1):
				var p := origin + Vector2i(x, y)
				if absi(x) + absi(y) == d and p != front and game.map.junk.has(p):
					result.append(p)
	return result

func hit(p: Vector2i, amount: float) -> void:
	if game.state != game.State.RUN or not game.map.junk.has(p): return
	var destroyed: bool = game.map.damage(p, amount)
	if destroyed: game.sound.play_sound("break")
	game.effect(p, Color("ffd18a"), 0.24)
	if destroyed and marks.has(p):
		var mark: Dictionary = marks[p]
		marks.erase(p)
		if float(mark.until) >= game.now():
			for direction in ShopMap.DIRS:
				hit(p + direction, float(mark.damage))
	game.collect_current()

func basic_hit(p: Vector2i) -> void:
	var amount: float = game.progress.damage()
	hit(p, amount)
	if ready("sample") and game.map.junk.has(p):
		consume_cooldown("sample")
		hit(p, amount * (1.0 + 0.3 * (game.progress.level("sample") - 1)))

func magnet(radius: int) -> bool:
	var collected := 0
	for p in game.map.reachable(game.player.tile, radius):
		collected += game.map.take_cash(p)
	if collected > 0:
		game.progress.wallet += collected
		game.sound.play_sound("coin")
		game.effect(game.player.tile, Color("acff84"), float(radius))
	return collected > 0

func tick() -> void:
	for p in marks.keys():
		if float(marks[p].until) < game.now() or not game.map.junk.has(p):
			marks.erase(p)
	for id in game.progress.slots:
		if not ready(id): continue
		var data: Dictionary = game.progress.abilities[id]
		if data.active: continue
		var lv: int = game.progress.level(id)
		var nearby := targets(game.player.tile, int(data.get("range", 1)), game.player.facing)
		var triggered := false
		match id:
			"magnet":
				triggered = magnet(int(data.radius) + lv - 1)
			"feedback":
				for p in nearby:
					if not marks.has(p):
						marks[p] = {"until": game.now() + float(data.duration) + lv - 1, "damage": float(data.damage) * (1 + 0.5 * (lv - 1))}
						game.effect(p, Color("d3a0ff"), 0.6)
						triggered = true
						break
			"hat":
				if not nearby.is_empty():
					hit(nearby[0], float(data.damage) * lv)
					triggered = true
			"sub":
				if not nearby.is_empty():
					for p in nearby: hit(p, float(data.damage) * (1 + 0.5 * (lv - 1)))
					triggered = true
		if triggered:
			consume_cooldown(id)
			game.sound.play_sound(id)

func activate(slot: int) -> void:
	if game.state != game.State.RUN or slot >= game.progress.slots.size(): return
	var id: String = game.progress.slots[slot]
	var data: Dictionary = game.progress.abilities[id]
	if not data.active or int(charges.get(id, 0)) <= 0: return
	var lv: int = game.progress.level(id)
	var origin: Vector2i = game.player.tile
	var facing: Vector2i = game.player.facing
	var damage := float(data.get("damage", 0)) * (1 + 0.5 * (lv - 1))
	var impacted: Array[Vector2i] = []
	match id:
		"bass", "remix":
			if id == "remix": magnet(int(data.range) + lv - 1)
			var radius := int(data.radius) + (1 if id == "bass" and lv == 3 else 0)
			impacted = targets(origin, radius, facing)
			game.effect(origin, Color("ffbf65"), float(radius) + 0.4)
		"pierce":
			for distance in range(1, int(data.range) + lv):
				var p := origin + facing * distance
				if game.map.solid(p): break
				impacted.append(p)
		"double":
			boost_until = game.now() + float(data.duration) + (lv - 1) * 2
		"dash":
			# Hop over junk, but never cross a wall/stand or shorten the jump.
			for distance in range(1, int(data.range) + 1):
				if game.map.solid(origin + facing * distance): return
			var destination := origin + facing * int(data.range)
			if game.map.junk.has(destination):
				hit(destination, float(game.map.junk[destination].hp))
			if game.state == game.State.RUN:
				game.player.teleport_to(destination)
				game.player.move_ready = game.now() + 0.18
				game.effect(destination, Color("b68aff"), 0.8)
				game.collect_current()
		"rush":
			var distance := int(data.range) + lv - 1
			for i in range(distance):
				var p: Vector2i = game.player.tile + facing
				if game.map.solid(p): break
				if id == "rush" and game.map.junk.has(p):
					impacted.append(p)
					hit(p, damage)
				if not game.map.walkable(p): break
				game.player.move_to(p, 0.08)
				game.collect_current()
				if game.state != game.State.RUN: break
			game.player.move_ready = game.now() + 0.18
	charges[id] = int(charges[id]) - 1
	if game.state != game.State.RUN: return
	if id != "rush":
		for p in impacted: hit(p, damage)
	game.sound.play_sound(id)
	game.player.swing(facing)
	game.effect(origin, Color("b68aff") if id in ["double", "remix"] else Color("ff8050"), 0.8)
	if damage > 0 and not impacted.is_empty() and ready("encore"):
		consume_cooldown("encore")
		echo_later(impacted, damage * (0.5 + 0.2 * (game.progress.level("encore") - 1)), generation)

func echo_later(positions: Array[Vector2i], damage: float, run_id: int) -> void:
	await get_tree().create_timer(0.25).timeout
	if run_id != generation or game.state != game.State.RUN: return
	for p in positions: hit(p, damage)
