extends Node3D
class_name DiskPlayer

var tile := Vector2i.ZERO
var facing := Vector2i.DOWN
var move_ready := 0.0
var motion: Tween
var pose_time := 0.0
var walking_until := 0.0
var swing_until := 0.0
var celebrate_until := 0.0
var bat: Node3D
var trail: MeshInstance3D
var illustrated_frames := false
var frozen := false
@onready var sprite: Sprite3D = $Sprite
@onready var arrow: MeshInstance3D = $Facing

func _ready() -> void:
	# Optional production sheet: 4 columns x 2 rows, equal cells.
	if ResourceLoader.exists("res://assets/character/boy_states.png"):
		sprite.texture = load("res://assets/character/boy_states.png")
		sprite.hframes = 4
		sprite.vframes = 2
		sprite.pixel_size = 1.45 / (sprite.texture.get_height() / 2.0)
		illustrated_frames = true
	bat = Node3D.new()
	add_child(bat)
	bat.position = Vector3(0.27, 0.62, 0.12)
	var wood := ShopVisuals.cylinder(bat, Vector3(0, 0.38, 0), 0.085, 0.62, Color("e8b578"))
	wood.rotation.z = -0.3
	ShopVisuals.cylinder(bat, Vector3(0, 0.01, 0), 0.043, 0.25, Color("392847"))
	ShopVisuals.box(bat, Vector3(0.05, 0.42, 0.07), Vector3(0.1, 0.14, 0.02), Color("b9ed55"))
	bat.rotation.z = -0.45
	# Match the sprite's overlay pass, with the bat drawn after the character.
	for part in bat.get_children():
		var front_mat := part.material_override.duplicate() as ShaderMaterial
		front_mat.shader = preload("res://shaders/bat_front.gdshader")
		front_mat.render_priority = 127
		part.material_override = front_mat
		part.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	bat.visible = not illustrated_frames
	trail = MeshInstance3D.new()
	var sweep := SurfaceTool.new()
	sweep.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(12):
		var a := -1.0 + i / 6.0
		var b := -1.0 + (i + 1) / 6.0
		for point in [Vector2(sin(a), cos(a)) * 0.65, Vector2(sin(a), cos(a)) * 1.05, Vector2(sin(b), cos(b)) * 1.05, Vector2(sin(a), cos(a)) * 0.65, Vector2(sin(b), cos(b)) * 1.05, Vector2(sin(b), cos(b)) * 0.65]:
			sweep.add_vertex(Vector3(point.x, 0.42, point.y))
	trail.mesh = sweep.commit()
	var trail_mat := StandardMaterial3D.new()
	trail_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	trail_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	trail_mat.albedo_color = Color("ffdc70")
	trail.material_override = trail_mat
	add_child(trail)
	trail.hide()

func _process(delta: float) -> void:
	if frozen: return
	pose_time += delta
	var time := Time.get_ticks_msec() / 1000.0
	var walking := time < walking_until
	var swing := time < swing_until
	var celebrate := time < celebrate_until
	trail.visible = swing and swing_until - time < 0.14
	trail.scale = Vector3.ONE * (0.6 + (0.22 - maxf(0, swing_until - time)) * 2.0)
	sprite.position.y = 0.61 + absf(sin(pose_time * (22 if walking else 5))) * (0.09 if walking else 0.025)
	sprite.rotation.z = sin(pose_time * 15) * 0.06 if walking else sin(pose_time * 3) * 0.018
	sprite.scale = Vector3.ONE * (1.08 if celebrate else 1.0)
	bat.rotation.z = lerpf(-1.8, 1.6, 1.0 - (swing_until - time) / 0.22) if swing else -0.45 + sin(pose_time * 5) * 0.05
	if illustrated_frames:
		sprite.frame = (4 if swing_until - time > 0.14 else 5) if swing else 6 if celebrate else (2 + int(pose_time * 12) % 2) if walking else int(pose_time * 3) % 2

func swing(direction: Vector2i) -> void:
	swing_until = Time.get_ticks_msec() / 1000.0 + 0.22
	sprite.flip_h = direction.x < 0
	bat.position.x = -0.27 if direction.x < 0 else 0.27
	trail.rotation.y = atan2(direction.x, direction.y)

func celebrate() -> void:
	celebrate_until = Time.get_ticks_msec() / 1000.0 + 0.35

func finish() -> void:
	frozen = true
	trail.hide()
	if motion != null: motion.kill()
	if illustrated_frames: sprite.frame = 7
	bat.rotation.z = 0.3

func reset_to(at: Vector2i) -> void:
	if motion != null:
		motion.kill()
	tile = at
	facing = Vector2i.DOWN
	position = Vector3(at.x, 0, at.y)
	move_ready = 0.0
	frozen = false
	walking_until = 0.0
	swing_until = 0.0
	celebrate_until = 0.0
	update_facing()

func update_facing() -> void:
	arrow.position = Vector3(facing.x * 0.42, 0.07, facing.y * 0.42)
	sprite.flip_h = facing.x < 0

func teleport_to(at: Vector2i) -> void:
	if motion != null:
		motion.kill()
	tile = at
	position = Vector3(at.x, 0, at.y)
	walking_until = 0.0
	update_facing()

func move_to(at: Vector2i, duration: float) -> void:
	walking_until = Time.get_ticks_msec() / 1000.0 + duration + 0.06
	tile = at
	if motion != null:
		motion.kill()
	motion = create_tween()
	motion.tween_property(self, "position", Vector3(at.x, 0, at.y), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func input_direction() -> Vector2i:
	if Input.is_physical_key_pressed(KEY_W): return Vector2i.UP
	if Input.is_physical_key_pressed(KEY_S): return Vector2i.DOWN
	if Input.is_physical_key_pressed(KEY_A): return Vector2i.LEFT
	if Input.is_physical_key_pressed(KEY_D): return Vector2i.RIGHT
	return Vector2i.ZERO
