extends Control
class_name RecordIcon

var id := "bass"
var accent := Color("b9ed55")
var progress := 1.0
var colored_disk := false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)

func _draw() -> void:
	var center := size * 0.5
	var r := minf(size.x, size.y) * 0.43
	draw_circle(center + Vector2(3, 4), r, Color("080711"))
	draw_circle(center, r, accent.darkened(0.4) if colored_disk else Color("242039"))
	for f in [0.62, 0.78, 0.92]: draw_arc(center, r * f, 0, TAU, 48, accent if colored_disk else Color("514361"), 1.0, true)
	draw_circle(center, r * 0.48, accent)
	draw_circle(center, 3, Color("151120"))
	var ink := Color("fff0c7")
	match id:
		"locked":
			draw_arc(center + Vector2(0, -r * 0.12), r * 0.25, PI, TAU, 16, ink, 3, true)
			draw_rect(Rect2(center + Vector2(-r * 0.35, -r * 0.08), Vector2(r * 0.7, r * 0.5)), ink)
		"empty":
			draw_line(center - Vector2(r * 0.35, 0), center + Vector2(r * 0.35, 0), ink, 3)
			draw_line(center - Vector2(0, r * 0.35), center + Vector2(0, r * 0.35), ink, 3)
		"bass", "sub":
			for i in range(3): draw_arc(center, r * (0.54 + i * 0.18), -0.7, 0.7, 12, ink, 3.0, true)
		"pierce", "rush", "attack":
			var points := PackedVector2Array([center + Vector2(-r * 0.5, r * 0.15), center + Vector2(r * 0.1, -r * 0.65), center + Vector2(0, -r * 0.06), center + Vector2(r * 0.5, -r * 0.15), center + Vector2(-r * 0.1, r * 0.65), center + Vector2(0, r * 0.06)])
			draw_colored_polygon(points, ink)
		"move", "dash":
			for i in range(3):
				var start := center + Vector2(-r * 0.55 + i * r * 0.4, 0)
				draw_polyline(PackedVector2Array([start + Vector2(-r * 0.15, -r * 0.35), start + Vector2(r * 0.15, 0), start + Vector2(-r * 0.15, r * 0.35)]), ink, 4, true)
		"magnet", "remix":
			draw_arc(center, r * 0.5, 0, PI, 18, ink, 7.0, true)
			draw_line(center + Vector2(-r * 0.5, 0), center + Vector2(-r * 0.5, -r * 0.45), ink, 7)
			draw_line(center + Vector2(r * 0.5, 0), center + Vector2(r * 0.5, -r * 0.45), ink, 7)
		"damage":
			draw_line(center + Vector2(-r * 0.5, r * 0.6), center + Vector2(r * 0.4, -r * 0.5), ink, 8, true)
		"feedback":
			for i in range(8):
				var d := Vector2.from_angle(i * TAU / 8)
				draw_line(center + d * r * 0.4, center + d * r * 0.85, ink, 3, true)
		"hat":
			draw_line(center + Vector2(-r * 0.65, -r * 0.1), center + Vector2(r * 0.65, -r * 0.1), ink, 5)
			draw_line(center + Vector2(0, -r * 0.5), center + Vector2(0, r * 0.65), ink, 4)
		"double":
			for x in [-0.3, 0.3]:
				var c := center + Vector2(x * r, 0)
				draw_colored_polygon(PackedVector2Array([c + Vector2(-r * 0.2, -r * 0.42), c + Vector2(r * 0.28, 0), c + Vector2(-r * 0.2, r * 0.42)]), ink)
		_:
			draw_arc(center, r * 0.63, -2.4, 2.4, 24, ink, 4, true)
			draw_line(center + Vector2(-r * 0.5, -r * 0.44), center + Vector2(-r * 0.12, -r * 0.55), ink, 4)
	if progress < 1.0:
		draw_arc(center, r + 3, -PI / 2, -PI / 2 + TAU * progress, 48, accent, 4.0, true)
