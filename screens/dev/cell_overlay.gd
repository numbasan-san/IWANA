class_name CellOverlay extends Button

var cell_coords: Vector2i
var is_selected: bool = false
	
static var scene: PackedScene = preload("res://screens/dev/cell_overlay.tscn")
	
signal cell_selected(coords: Vector2i)

static func _create() -> CellOverlay:
	return scene.instantiate()

func _on_toggled(button_pressed: bool) -> void:
	is_selected = button_pressed
	if is_selected:
		cell_selected.emit(cell_coords)
