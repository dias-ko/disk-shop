@tool
extends Resource
class_name ShopLayout
## One character per tile. Edit with the Disk Shop dock or edit these rows directly.
@export_multiline var tiles: String = "" :
	set(value):
		tiles = value
		emit_changed()

func rows() -> PackedStringArray:
	return tiles.split("\n", false)

func cell(at: Vector2i) -> String:
	var lines := rows()
	if at.y < 0 or at.y >= lines.size() or at.x < 0 or at.x >= lines[at.y].length():
		return " "
	return lines[at.y][at.x]

func painted(at: Vector2i, symbol: String) -> String:
	var lines := rows()
	if at.y < 0 or at.y >= lines.size() or at.x < 0 or at.x >= lines[at.y].length():
		return tiles
	var line := lines[at.y]
	lines[at.y] = line.substr(0, at.x) + symbol + line.substr(at.x + 1)
	return "\n".join(lines)
