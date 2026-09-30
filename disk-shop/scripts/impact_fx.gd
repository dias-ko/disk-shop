extends Node3D

var age := 0.0
var duration := 0.32
var pieces: Array[Node3D] = []
var velocities: Array[Vector3] = []
var ring: MeshInstance3D
var strength := 1.0

func setup(p: Vector2i, color: Color, radius: float) -> void:
	position = Vector3(p.x, 0.18, p.y)
	strength = radius
	var mesh := TorusMesh.new()
	mesh.inner_radius = 0.36
	mesh.outer_radius = 0.43
	mesh.rings = 16
	mesh.ring_segments = 4
	ring = MeshInstance3D.new()
	ring.mesh = mesh
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = color
	ring.material_override = mat
	add_child(ring)
	for i in range(6):
		var angle := i * TAU / 6.0
		var piece := ShopVisuals.box(self, Vector3.ZERO, Vector3(0.06, 0.05, 0.17), color, false)
		pieces.append(piece)
		velocities.append(Vector3(cos(angle) * 3, 2.0 + (i % 3), sin(angle) * 3) * minf(radius + 0.5, 2.0))

func _process(delta: float) -> void:
	age += delta
	var t := age / duration
	if t >= 1:
		queue_free()
		return
	ring.scale = Vector3.ONE * (0.2 + t * strength * 2.8)
	ring.scale.y = 0.15
	ring.position.y = 0.12 * (1.0 - t)
	for i in range(pieces.size()):
		pieces[i].position += velocities[i] * delta
		velocities[i].y -= delta * 15
		pieces[i].rotation += Vector3(5, 3, 1) * delta
		pieces[i].scale = Vector3.ONE * (1 - t)
