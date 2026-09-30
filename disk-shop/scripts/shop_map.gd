@tool
extends Node3D
class_name ShopMap

const WOBBLE = preload("res://shaders/prop_wobble.gdshader")
const DIRS = [Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP]
const TIER_COLORS = [Color("b8c9cd"), Color("ffcd65"), Color("ac9aff"), Color("70fff2")]
@export var layout: ShopLayout:
	set(value):
		if layout != null and layout.changed.is_connected(_layout_changed):
			layout.changed.disconnect(_layout_changed)
		layout = value
		if layout != null:
			layout.changed.connect(_layout_changed)
		_layout_changed()

var junk: Dictionary = {}
var cash: Dictionary = {}
var visuals: Dictionary = {}
var coins: Dictionary = {}
var stands: Dictionary = {}
var spawn := Vector2i(15, 1)
var diamond := Vector2i(15, 36)
var root: Node3D
var balance: Dictionary = {}
var rebuild_queued := false

func _ready() -> void:
	reset_map([])

func _layout_changed() -> void:
	if is_inside_tree() and Engine.is_editor_hint() and not rebuild_queued:
		rebuild_queued = true
		call_deferred("_editor_rebuild")

func _editor_rebuild() -> void:
	rebuild_queued = false
	reset_map([])

func reset_map(unlocked: Array) -> void:
	if root != null:
		remove_child(root)
		root.queue_free()
	root = Node3D.new()
	root.name = "GeneratedPreview"
	add_child(root)
	junk.clear()
	cash.clear()
	visuals.clear()
	coins.clear()
	stands.clear()
	if layout == null:
		return
	if balance.is_empty():
		balance = JSON.parse_string(FileAccess.get_file_as_string("res://data/balance.json"))
	var lines := layout.rows()
	var floor_dark := material(Color("353039"), false)
	var floor_light := material(Color("403a41"), false)
	var wall_mat := ShaderMaterial.new()
	wall_mat.shader = preload("res://shaders/brick_wall.gdshader")
	for z in range(lines.size()):
		for x in range(lines[z].length()):
			var p := Vector2i(x, z)
			var symbol := layout.cell(p)
			if symbol == " ":
				continue
			box(Vector3(x, -0.11, z), Vector3(0.98, 0.18, 0.98), floor_dark if (x + z) % 2 == 0 else floor_light)
			if symbol == "#":
				box(Vector3(x, 0.86, z), Vector3(1, 1.8, 1), wall_mat)
			elif symbol in ["1", "2", "3", "4"]:
				var data: Dictionary = balance.junk[int(symbol) - 1]
				junk[p] = {"hp": float(data.hp), "max": float(data.hp), "cash": int(data.cash), "kind": int(symbol)}
				visuals[p] = ShopVisuals.junk(root, p, int(symbol))
			elif symbol == "E":
				spawn = p
				box(Vector3(x, 0.01, z), Vector3(0.92, 0.04, 0.92), material(Color("ffb95b"), false))
			elif symbol == "$":
				add_cash(p, 8)
			elif symbol in ["S", "G", "P", "D"]:
				var tier: int = ["S", "G", "P", "D"].find(symbol) + 1
				stands[p] = tier
				box(Vector3(x, 0.3, z), Vector3(0.65, 0.6, 0.65), material(Color("455666")))
				if tier == 4:
					diamond = p + Vector2i.UP
				if tier in unlocked:
					add_cash(p + Vector2i.UP, tier * 15)
				else:
					var disk := MeshInstance3D.new()
					var mesh := CylinderMesh.new()
					mesh.top_radius = 0.33
					mesh.bottom_radius = 0.33
					mesh.height = 0.09
					mesh.radial_segments = 16
					disk.mesh = mesh
					var glow_mat := StandardMaterial3D.new()
					glow_mat.albedo_color = TIER_COLORS[tier - 1]
					glow_mat.emission_enabled = true
					glow_mat.emission = TIER_COLORS[tier - 1]
					glow_mat.emission_energy_multiplier = 0.5
					disk.material_override = glow_mat
					disk.position = Vector3(x, 2.05, z)
					disk.rotation_degrees.x = 65
					root.add_child(disk)
					ShopVisuals.disk_glow(disk, TIER_COLORS[tier - 1])
					visuals[p] = disk
					var label := Label3D.new()
					label.text = ["SILVER", "GOLD", "PLATINUM", "DIAMOND"][tier - 1]
					label.font_size = 36
					label.pixel_size = 0.009
					label.position = Vector3(x, 2.65, z)
					label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
					label.modulate = TIER_COLORS[tier - 1]
					root.add_child(label)
	ShopVisuals.batch_static(root, visuals.values() + coins.values())

func material(color: Color, wobbling: bool = true) -> Material:
	return ShopVisuals.material(color, wobbling)

func box(pos: Vector3, size: Vector3, mat: Material) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	node.mesh = mesh
	node.material_override = mat
	node.position = pos
	root.add_child(node)
	return node

func solid(p: Vector2i) -> bool:
	return layout.cell(p) in [" ", "#", "S", "G", "P", "D"]

func walkable(p: Vector2i) -> bool:
	return not solid(p) and not junk.has(p)

func damage(p: Vector2i, amount: float) -> bool:
	if not junk.has(p):
		return false
	junk[p].hp -= amount
	if junk[p].hp <= 0:
		var value: int = junk[p].cash
		junk.erase(p)
		if visuals.has(p):
			visuals[p].queue_free()
			visuals.erase(p)
		add_cash(p, value)
		return true
	var node: Node3D = visuals[p]
	if float(junk[p].hp) < float(junk[p].max) * 0.5 and not node.has_meta("damaged"):
		node.set_meta("damaged", true)
		for i in range(2):
			var crack := ShopVisuals.box(node, Vector3(-0.1 + i * 0.16, 0.24, 0.37), Vector3(0.035, 0.4, 0.02), Color("fff1b8"))
			crack.rotation.z = -0.5 + i * 1.0
	node.scale = Vector3(1.06, 0.84, 1.06)
	create_tween().tween_property(node, "scale", Vector3.ONE, 0.13)
	return false

func add_cash(p: Vector2i, amount: int) -> void:
	cash[p] = int(cash.get(p, 0)) + amount
	if not coins.has(p):
		coins[p] = box(Vector3(p.x, 0.13, p.y), Vector3(0.32, 0.2, 0.25), material(Color("a8ed80")))

func take_cash(p: Vector2i) -> int:
	var amount := int(cash.get(p, 0))
	cash.erase(p)
	if coins.has(p):
		coins[p].queue_free()
		coins.erase(p)
	return amount

func take_disk(p: Vector2i) -> void:
	if visuals.has(p):
		visuals[p].queue_free()
		visuals.erase(p)

func reachable(origin: Vector2i, radius: int) -> Array[Vector2i]:
	var found: Array[Vector2i] = [origin]
	var distances := {origin: 0}
	var index := 0
	while index < found.size():
		var p := found[index]
		index += 1
		if distances[p] >= radius:
			continue
		for direction in DIRS:
			var next: Vector2i = p + direction
			if not distances.has(next) and walkable(next):
				distances[next] = distances[p] + 1
				found.append(next)
	return found

