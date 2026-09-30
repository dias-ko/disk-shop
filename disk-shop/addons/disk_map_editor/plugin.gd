@tool
extends EditorPlugin

var dock: VBoxContainer
var palette: OptionButton
var paint_enabled: CheckBox
var map: ShopMap
var status: Label
var symbols := [".", "#", "1", "2", "3", "4", "S", "G", "P", "D", "E", "$", " "]

func _enter_tree() -> void:
	dock = VBoxContainer.new()
	dock.name = "Disk Map"
	var title := Label.new()
	title.text = "DISK SHOP / MAP PAINTER"
	dock.add_child(title)
	var help := Label.new()
	help.text = "Open scenes/shop_map.tscn.\nSelect ShopMap, enable painting.\nLeft-click tiles in the 3D view.\nCtrl+Z undoes; save the resource.\nDisk approach = tile above stand."
	help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	help.custom_minimum_size.x = 220
	dock.add_child(help)
	paint_enabled = CheckBox.new()
	paint_enabled.text = "Enable tile painting"
	dock.add_child(paint_enabled)
	palette = OptionButton.new()
	for text in ["Floor", "Wall", "Litter", "Box", "Crate", "Heavy scrap", "Silver stand", "Gold stand", "Platinum stand", "Diamond stand", "Elevator spawn", "Cash", "Void"]:
		palette.add_item(text)
	dock.add_child(palette)
	var save := Button.new()
	save.text = "Save layout resource"
	save.pressed.connect(_save)
	dock.add_child(save)
	status = Label.new()
	status.text = "Select ShopMap to begin."
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dock.add_child(status)
	add_control_to_dock(DOCK_SLOT_RIGHT_UL, dock)

func _exit_tree() -> void:
	remove_control_from_docks(dock)
	dock.queue_free()

func _handles(object: Object) -> bool:
	return object is ShopMap

func _edit(object: Object) -> void:
	map = object as ShopMap
	if map != null:
		status.text = "Painting: " + map.layout.resource_path

func _forward_3d_gui_input(camera: Camera3D, event: InputEvent) -> int:
	if not is_instance_valid(map) or not paint_enabled.button_pressed:
		return EditorPlugin.AFTER_GUI_INPUT_PASS
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var origin := camera.project_ray_origin(event.position)
		var ray := camera.project_ray_normal(event.position)
		var point = Plane(Vector3.UP, map.global_position.y).intersects_ray(origin, ray)
		if point == null: return EditorPlugin.AFTER_GUI_INPUT_PASS
		point = map.to_local(point)
		var cell := Vector2i(roundi(point.x), roundi(point.z))
		var before := map.layout.tiles
		var after := map.layout.painted(cell, symbols[palette.selected])
		if before != after:
			var undo := get_undo_redo()
			undo.create_action("Paint Disk Shop tile", UndoRedo.MERGE_DISABLE, map.layout)
			undo.add_do_property(map.layout, "tiles", after)
			undo.add_undo_property(map.layout, "tiles", before)
			undo.commit_action()
			status.text = "Tile %d, %d changed. Save layout when done." % [cell.x, cell.y]
		return EditorPlugin.AFTER_GUI_INPUT_STOP
	return EditorPlugin.AFTER_GUI_INPUT_PASS

func _save() -> void:
	if not is_instance_valid(map) or map.layout == null: return
	var error := ResourceSaver.save(map.layout)
	status.text = "Layout saved." if error == OK else "Save failed: %s" % error_string(error)
