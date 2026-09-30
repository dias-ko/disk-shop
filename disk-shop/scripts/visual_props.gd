@tool
extends RefCounted
class_name ShopVisuals

const WOBBLE = preload("res://shaders/prop_wobble.gdshader")
const UI_FONT = preload("res://assets/fonts/SpaceGrotesk-Semibold.tres")
const MARKER_FONT = preload("res://assets/fonts/PermanentMarker-Regular.ttf")
const COLORS = [Color("b66740"), Color("65557f"), Color("849550"), Color("4e8b8c"), Color("a25271")]
static var materials: Dictionary = {}
static var junk_meshes: Dictionary = {}

static func material(color: Color, wobble := true) -> Material:
	var key := str(color) + str(wobble)
	if materials.has(key): return materials[key]
	var mat: Material
	if wobble:
		mat = ShaderMaterial.new()
		mat.shader = WOBBLE
		mat.set_shader_parameter("tint", color)
	else:
		mat = StandardMaterial3D.new()
		mat.albedo_color = color
		mat.roughness = 1.0
	materials[key] = mat
	return mat

static func box(parent: Node3D, pos: Vector3, size: Vector3, color: Color, wobble := true) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	node.mesh = mesh
	node.material_override = material(color, wobble)
	node.position = pos
	parent.add_child(node)
	return node

static func cylinder(parent: Node3D, pos: Vector3, radius: float, height: float, color: Color) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 12
	node.mesh = mesh
	node.material_override = material(color)
	node.position = pos
	parent.add_child(node)
	return node

static func sign_text(parent: Node3D, pos: Vector3, text: String, color: Color, font_size := 48, font: Font = UI_FONT) -> Label3D:
	var label := Label3D.new()
	label.font = font
	label.text = text
	label.position = pos
	label.font_size = font_size
	label.pixel_size = 0.009
	label.modulate = color
	label.outline_size = 10
	parent.add_child(label)
	return label

static func junk(parent: Node3D, p: Vector2i, tier: int) -> Node3D:
	var root := Node3D.new()
	parent.add_child(root)
	root.position = Vector3(p.x, 0, p.y)
	# Stable tile hash mixes silhouettes within each durability band.
	var hash_value := posmod((p.x * 73856093) ^ (p.y * 19349663), 2147483647)
	var variant := hash_value % 6
	if tier >= 3 and variant in [1, 2]: variant += 5
	var mesh_key := "%d/%d/%d" % [tier, variant, posmod(p.x, 5)]
	if junk_meshes.has(mesh_key):
		var cached := MeshInstance3D.new()
		cached.mesh = junk_meshes[mesh_key]
		cached.material_override = material(Color.WHITE)
		root.add_child(cached)
		root.rotation.y = (float(hash_value % 9) - 4.0) * 0.045
		return root
	# Alternate silhouettes share exactly the same logical tier, HP and reward.
	if variant >= 3:
		match tier:
			1:
				if variant == 3:
					for i in range(3):
						cylinder(root, Vector3(-0.22 + i * 0.21, 0.1, i * 0.09 - 0.1), 0.085, 0.2, Color("837a61"))
				elif variant == 4:
					for i in range(4):
						box(root, Vector3(-0.2 + i * 0.12, 0.035 + i * 0.025, 0), Vector3(0.3, 0.04, 0.38), COLORS[i]).rotation.y = i * 0.35
				else:
					box(root, Vector3(0, 0.09, 0), Vector3(0.52, 0.18, 0.4), Color("625b56"))
					for i in range(3):
						box(root, Vector3(-0.16 + i * 0.16, 0.19, 0), Vector3(0.06, 0.025, 0.2), Color("272730"))
			2:
				if variant == 3:
					box(root, Vector3(0, 0.15, 0), Vector3(0.72, 0.3, 0.6), Color("776146"))
					box(root, Vector3(0.13, 0.43, 0.06), Vector3(0.4, 0.26, 0.42), Color("947650"))
				elif variant == 4:
					box(root, Vector3(0, 0.25, 0), Vector3(0.58, 0.5, 0.55), Color("536462"))
					for i in range(4):
						box(root, Vector3(-0.2 + i * 0.14, 0.5, 0), Vector3(0.065, 0.04, 0.48), Color("293b3c"))
				else:
					box(root, Vector3(0, 0.23, 0), Vector3(0.69, 0.46, 0.62), Color("654f3e"))
					for x in [-0.27, 0.27]:
						box(root, Vector3(x, 0.24, 0.32), Vector3(0.07, 0.48, 0.035), Color("947d58"))
			3:
				if variant == 3:
					box(root, Vector3(0, 0.27, 0), Vector3(0.72, 0.54, 0.61), Color("373735"))
					for i in range(3):
						box(root, Vector3(0, 0.12 + i * 0.15, 0.32), Vector3(0.57, 0.07, 0.03), Color("716857"))
				elif variant == 4:
					for i in range(3):
						box(root, Vector3(0, 0.1 + i * 0.18, 0), Vector3(0.72 - i * 0.06, 0.17, 0.58), Color("41434b"))
					box(root, Vector3(0, 0.51, 0.31), Vector3(0.4, 0.035, 0.025), Color("8b815e"))
				elif variant == 6:
					for i in range(2):
						box(root, Vector3(0, 0.17 + i * 0.32, 0), Vector3(0.68, 0.3, 0.58), Color("594a45"))
						box(root, Vector3(0, 0.17 + i * 0.32, 0.3), Vector3(0.22, 0.055, 0.025), Color("968b71"))
				elif variant == 7:
					cylinder(root, Vector3(0, 0.33, 0), 0.32, 0.66, Color("535c58"))
					for y in [0.12, 0.54]:
						cylinder(root, Vector3(0, y, 0), 0.335, 0.04, Color("292c31"))
				else:
					box(root, Vector3(0, 0.29, 0), Vector3(0.65, 0.58, 0.62), Color("514332"))
					for y in [0.08, 0.48]:
						box(root, Vector3(0, y, 0.32), Vector3(0.68, 0.06, 0.035), Color("292d30"))
			4:
				if variant == 3:
					box(root, Vector3(-0.17, 0.46, 0), Vector3(0.38, 0.92, 0.64), Color("646264"))
					for y in range(5):
						box(root, Vector3(-0.17, 0.34 + y * 0.09, 0.33), Vector3(0.24, 0.025, 0.02), Color("24282b"))
					box(root, Vector3(0.25, 0.16, 0.12), Vector3(0.33, 0.32, 0.47), Color("424b46"))
				elif variant == 4:
					box(root, Vector3(0, 0.42, 0), Vector3(0.76, 0.84, 0.62), Color("5a5956"))
					for y in [0.22, 0.6]:
						box(root, Vector3(0, y, 0.32), Vector3(0.63, 0.28, 0.035), Color("292e31"))
						box(root, Vector3(0.21, y, 0.35), Vector3(0.12, 0.035, 0.025), Color("8f8169"))
				elif variant == 6:
					box(root, Vector3(0, 0.26, 0), Vector3(0.74, 0.52, 0.68), Color("777267"))
					box(root, Vector3(0, 0.56, -0.13), Vector3(0.64, 0.09, 0.42), Color("42494a"))
					box(root, Vector3(0, 0.28, 0.35), Vector3(0.52, 0.1, 0.025), Color("22282c"))
					box(root, Vector3(0.2, 0.55, 0.19), Vector3(0.16, 0.055, 0.14), Color("4e756d"))
				elif variant == 7:
					box(root, Vector3(0, 0.38, 0), Vector3(0.7, 0.76, 0.56), Color("4e4540"))
					for x in [-0.19, 0.19]:
						var reel := cylinder(root, Vector3(x, 0.53, 0.3), 0.16, 0.04, Color("8b877b"))
						reel.rotation.x = PI / 2
					box(root, Vector3(0, 0.2, 0.3), Vector3(0.41, 0.12, 0.03), Color("1f292a"))
				else:
					box(root, Vector3(0, 0.18, 0), Vector3(0.79, 0.36, 0.7), Color("44463e"))
					box(root, Vector3(-0.12, 0.55, 0), Vector3(0.47, 0.43, 0.49), Color("74716a")).rotation.z = 0.17
					cylinder(root, Vector3(0.22, 0.47, 0.15), 0.19, 0.22, Color("302f35"))
	if variant < 3:
		match tier:
			1:
				for i in range(3):
					var paper := box(root, Vector3(-0.22 + i * 0.22, 0.035 + i * 0.035, (i % 2) * 0.22 - 0.1), Vector3(0.36, 0.03, 0.34), COLORS[(p.x + i) % 5])
					paper.rotation.y = i * 0.8 + variant
				if variant == 0:
					var cup := cylinder(root, Vector3(0.22, 0.16, 0.1), 0.1, 0.28, Color("f9e8ba"))
					cup.rotation.z = 0.55
				else:
					cylinder(root, Vector3(0, 0.17, 0), 0.24, 0.045, Color("16132d"))
					cylinder(root, Vector3(0, 0.20, 0), 0.08, 0.01, COLORS[variant])
			2:
				if variant == 0:
					box(root, Vector3(0, 0.23, 0), Vector3(0.66, 0.46, 0.62), Color("b77948"))
					box(root, Vector3(0, 0.47, 0), Vector3(0.12, 0.025, 0.65), Color("ffdb94"))
					box(root, Vector3(-0.3, 0.5, 0), Vector3(0.35, 0.035, 0.62), Color("cf9860")).rotation.z = -0.5
				else:
					box(root, Vector3(0, 0.12, 0), Vector3(0.72, 0.24, 0.64), Color("554187"))
					for i in range(5):
						box(root, Vector3(0, 0.31, -0.24 + i * 0.12), Vector3(0.56, 0.4, 0.055), COLORS[(i + variant) % 5]).rotation.x = -0.2
			3:
				box(root, Vector3(0, 0.38, 0), Vector3(0.64, 0.76, 0.6), Color("28243c"))
				for y in [0.22, 0.57]:
					var cone := cylinder(root, Vector3(0, y, 0.315), 0.22 if y < 0.3 else 0.13, 0.035, Color("080911"))
					cone.rotation.x = PI / 2
					var cap := cylinder(root, Vector3(0, y, 0.34), 0.07, 0.04, COLORS[variant])
					cap.rotation.x = PI / 2
				box(root, Vector3(-0.24, 0.7, 0.33), Vector3(0.15, 0.04, 0.02), Color("f1d998")).rotation.z = 0.6
			4:
				box(root, Vector3(0, 0.18, 0), Vector3(0.8, 0.34, 0.73), Color("564764"))
				var crt := box(root, Vector3(0.04, 0.64, 0), Vector3(0.7, 0.59, 0.61), Color("817a8d"))
				crt.rotation.z = -0.09
				box(root, Vector3(0.04, 0.65, 0.32), Vector3(0.51, 0.38, 0.025), Color("22283b"))
				box(root, Vector3(0.04, 0.65, 0.34), Vector3(0.035, 0.38, 0.02), Color("57d9cc")).rotation.z = 0.55
				for i in range(3):
					box(root, Vector3(-0.32 + i * 0.3, 0.39, 0.39), Vector3(0.055, 0.07, 0.22), COLORS[i])
	# One draw per breakable; preserve the modeled silhouettes and per-face colors.
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for child in root.get_children():
		var arrays: Array = child.mesh.surface_get_arrays(0)
		var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
		var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
		var uvs: PackedVector2Array = arrays[Mesh.ARRAY_TEX_UV]
		var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
		var tint: Color = child.material_override.get_shader_parameter("tint")
		for index in indices:
			surface.set_normal(child.transform.basis * normals[index])
			surface.set_uv(uvs[index])
			surface.set_color(tint)
			surface.add_vertex(child.transform * vertices[index])
		root.remove_child(child)
		child.free()
	var combined := MeshInstance3D.new()
	combined.mesh = surface.commit()
	junk_meshes[mesh_key] = combined.mesh
	combined.material_override = material(Color.WHITE)
	root.add_child(combined)
	root.rotation.y = (float(hash_value % 9) - 4.0) * 0.045
	return root

static func batch_static(parent: Node3D, excluded: Array) -> void:
	var batches: Dictionary = {}
	for child in parent.get_children():
		if not child is MeshInstance3D or child in excluded or child.get_child_count() > 0: continue
		if not child.mesh is BoxMesh: continue
		var chunk := Vector2i(floori(child.position.x / 6), floori(child.position.z / 6))
		var key := str(chunk) + str(child.mesh.size) + str(child.material_override.get_rid())
		if not batches.has(key): batches[key] = []
		batches[key].append(child)
	for nodes in batches.values():
		if nodes.size() < 2: continue
		var batch := MultiMeshInstance3D.new()
		var multi := MultiMesh.new()
		multi.transform_format = MultiMesh.TRANSFORM_3D
		multi.mesh = nodes[0].mesh
		multi.instance_count = nodes.size()
		batch.multimesh = multi
		batch.material_override = nodes[0].material_override
		parent.add_child(batch)
		for i in range(nodes.size()):
			multi.set_instance_transform(i, nodes[i].transform)
			parent.remove_child(nodes[i])
			nodes[i].free()

static func disk_glow(disk: MeshInstance3D, color: Color) -> void:
	var hub := cylinder(disk, Vector3(0, 0.052, 0), 0.085, 0.015, Color("171a24"))
	var hub_mat := StandardMaterial3D.new()
	hub_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	hub_mat.albedo_color = Color("171a24")
	hub.material_override = hub_mat
	var halo := MeshInstance3D.new()
	var quad := QuadMesh.new()
	quad.size = Vector2(1.8, 1.8)
	halo.mesh = quad
	var mat := ShaderMaterial.new()
	mat.shader = preload("res://shaders/disk_halo.gdshader")
	mat.set_shader_parameter("glow_color", color)
	halo.material_override = mat
	disk.add_child(halo)
	# Cylinder face is local XZ; the halo sits just behind that face.
	halo.rotation.x = -PI / 2
	halo.position.y = -0.055
	halo.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var light := OmniLight3D.new()
	light.light_color = color
	light.light_energy = 0.8
	light.omni_range = 2.2
	light.position.y = 0.25
	disk.add_child(light)

static func elevator(parent: Node3D) -> Dictionary:
	var room := Node3D.new()
	room.name = "ElevatorRoom"
	room.position = Vector3(-14, 0, -10)
	parent.add_child(room)
	box(room, Vector3(0, -0.15, 0), Vector3(7, 0.3, 5.5), Color("362d58"), false)
	box(room, Vector3(0, 1.7, -2.65), Vector3(7, 3.4, 0.2), Color("29213d"), false)
	for side in [-1, 1]:
		box(room, Vector3(side * 3.45, 1.35, 0), Vector3(0.15, 2.7, 5.5), Color("433359"), false)
		box(room, Vector3(side * 3.3, 0.9, 0), Vector3(0.08, 0.07, 5), Color("ffae66"), false)
		box(room, Vector3(side * 2.4, 2.9, -2.48), Vector3(1.6, 0.07, 0.06), Color("53e8d4"), false)
	var doors: Array[Node3D] = []
	for side in [-1, 1]:
		var door := box(room, Vector3(side * 0.65, 1.3, -2.48), Vector3(1.27, 2.6, 0.15), Color("726585"), false)
		box(door, Vector3(0, 0, 0.09), Vector3(0.035, 2.45, 0.03), Color("b9ed55"), false)
		doors.append(door)
	sign_text(room, Vector3(0, 3.0, -2.42), "B1 / AFTER HOURS", Color("b9ed55"), 33)
	box(room, Vector3(2.2, 1.1, -1.6), Vector3(1.45, 2.2, 1.0), Color("ed6746"))
	box(room, Vector3(2.2, 1.38, -1.07), Vector3(1.16, 1.25, 0.07), Color("121a2c"))
	for i in range(3):
		box(room, Vector3(1.85 + i * 0.35, 1.4, -1.01), Vector3(0.26, 0.6, 0.025), COLORS[i])
	sign_text(room, Vector3(2.2, 2.07, -1.04), "TRACK-O-MATIC", Color("fff2c8"), 19)
	box(room, Vector3(2.2, 0.38, -1.07), Vector3(0.85, 0.25, 0.06), Color("161328"))
	sign_text(room, Vector3(-2.25, 1.7, -2.48), "MAKE\nSOME\nNOISE", Color("ee61bc"), 43, MARKER_FONT).rotation.z = -0.12
	return {"room": room, "doors": doors}
