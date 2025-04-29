class_name OverlayCellsControl extends GridContainer

var combat_area: CombatPartyArea:
	set(value):
		combat_area = value
		combat_grid = combat_area.combat_grid
		_grid_resized(combat_grid._grid_size)
		combat_grid.size_changed.connect(_grid_resized)

var combat_grid: CombatGrid

signal cell_selected(cell: CellOverlay)

# The underlaying grid makes sure to handle its resizing correctly and handle
# contents removal, so we can safely change this one.
func _grid_resized(new_size: Vector2i):
	var columns = new_size.x
	var total = new_size.x * new_size.y
	var actual = get_child_count()
	var delta = total - actual
	if delta > 0:
		var i = 0
		while i < delta:
			var cell = CellOverlay._create()
			add_child(cell)
			i += 1
	elif delta < 0:
		var i = 0
		while i > delta:
			remove_child(get_child(-1))
			i -= 1
	
	if delta != 0:
		_sync_cells()

func _sync_cells():
	# We assume that the order in which we find the children is from left to right,
	# top to bottom.
	var i = 0
	for cell in get_children():
		cell = cell as CellOverlay
		var coords = Vector2i((i % columns) + 1, (i / columns) + 1)
		cell.cell_coords = coords
		i += 1

func _get_cell_with_coords(coords: Vector2i) -> CellOverlay:
	var index = (coords.y - 1) * columns + coords.x - 1
	return get_child(index)
