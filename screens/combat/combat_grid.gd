class_name CombatGrid extends Panel

@export var grid_size: Vector2i:
	set(value):
		resize(value)
	get:
		return _grid_size
var _grid_size: Vector2i

## A dictionary where the key is a Vector2i and the value is a Panel.
##
## The posible values start on (1, 1) for the top-left cell, and increase from
## left to right and from top to bottom.
## Only non empty panels, that is SpriteContainers, are added to the dictionary.
var contents: Dictionary

## The horizontal distance between each element's anchor.
var _h_offset: float
## The vertical distance between each element's anchor.
var _v_offset: float

signal size_changed(new_size: Vector2i)

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	gui_input

## Adds the panel in the specified position inside the grid.
func add(panel: SpriteContainer, position: Vector2i):
	if !panel:
		printerr("CombatGrid | Can't add a null panel")
		return
	if !in_grid(position):
		printerr("CombatGrid | The target position " + str(position) + \
			" is outside the grid limits " + str(grid_size))
		return
	
	var old_panel = contents.get(position)
	if old_panel == panel:
		return
	# We don't support directly replacing an panel in the same position. It has to
	# be manually removed first.
	if old_panel and old_panel != panel:
		printerr("CombatGrid | The target position " + str(position) + \
			" already has another object.")
		return
	# If we reach this point, the position was empty.
	contents[position] = panel
	add_child(panel)
	_recalculate_element_anchors(panel)
	
	# TODO: we probably also have to adjust the control position.

func add_in_next_available(container: SpriteContainer, positions: Array[Vector2i]):
	for next in positions:
		if !contents.has(next):
			add(container, next)
			return
	
	printerr("CombatGrid | No available positions to add new panel.")

## Returns the position the element occupies in the grid, or (-1, -1) if it wasn't
## found.
func find_position(panel: SpriteContainer) -> Vector2i:
	var position: Vector2i = contents.find_key(panel)
	if !position:
		position = Vector2i(0, 0)
	return position

## If the element exists in the grid, and the target position is empty, this
## function moves that element to its new position.
func move(panel: SpriteContainer, position: Vector2i):
	if !panel:
		printerr("CombatGrid | Can't move a null panel")
		return
	if !contents.keys().has(position) and contents.values().has(panel):
		contents.erase(find_position(panel))
		contents[position] = panel
		_recalculate_element_anchors(panel)

## If both elements exist in the grid, their positions are switched.
func switch_elements(panel1: SpriteContainer, panel2: SpriteContainer):
	if !panel1 or !panel2:
		printerr("CombatGrid | Can't switch a null panel")
		return
	var pos1 = find_position(panel1)
	var pos2 = find_position(panel2)
	if pos1 and pos2:
		contents.erase(pos1)
		contents.erase(pos2)
		contents[pos2] = panel1
		contents[pos1] = panel2
		_recalculate_element_anchors(panel1)
		_recalculate_element_anchors(panel2)

## Switches the contents of the two given positions.
##
## Note that this function works correctly even if one or both positions are
## empty, as long as they fall inside the grid.
func switch_positions(pos1: Vector2i, pos2: Vector2i):
	if in_grid(pos1) and in_grid(pos2):
		var panel1 = contents.get(pos1)
		var panel2 = contents.get(pos2)
		contents.erase(pos1)
		contents.erase(pos2)
		if panel1:
			contents[pos2] = panel1
			_recalculate_element_anchors(panel1)
		if panel2:
			contents[pos1] = panel2
			_recalculate_element_anchors(panel2)

## Deletes an element from the grid if it was already in there.
##
## If the remove_node argument is true, it also deletes the child node from this
## node. It is used as false to temporary remove the panels from the dictionary
## in order to move them to a different position.
func remove_element(element: SpriteContainer) -> bool:
	if !element:
		printerr("CombatGrid | Can't remove a null panel")
		return false
	if !contents.values().has(element):
		return false
	for child in get_children():
		if child == element:
			child.queue_free()
			break
	var position = contents.find_key(element)
	return contents.erase(position)

## Deletes the element in a given position from the grid.
func remove_position(position: Vector2i) -> bool:
	if contents.has(position):
		return remove_element(contents[position])
	else:
		return false

## Changes the size of the grid.
##
## If there are elements outside of the new size, if the remove_elements is true,
## all those elements will be removed. If it's false, the function will do nothing.
## This only counts as element a non empty panel, that is a SpriteContainer
func resize(new_size: Vector2i, remove_elements: bool = false):
	if new_size.x < 1 or new_size.y < 1:
		printerr("CombatGrid | Couldn't resize to " + str(new_size) + \
			" because it is less than (1, 1).")
		return
	# In these two cases we can potentially find elements that'll be left outside
	# of the new limits.
	if new_size.x < _grid_size.x or new_size.y < _grid_size.y:
		for position in contents.keys():
			if position.x > new_size.x or position.y > new_size.y:
				if !remove_elements:
					printerr("CombatGrid | Couldn't resize to " + str(new_size) + \
						" because there are elements outside that range.")
					return
				else:
					remove_position(position)
			
	# If we get here, either there were no elements outside the new size, they
	# were dealt with, or the function failed and returned.
	_grid_size = new_size
	
	_h_offset = 1.0/_grid_size.x
	_v_offset = 1.0/_grid_size.y
	_recalculate_all_anchors()
	size_changed.emit(new_size)

## Checks if the given vector falls within the grid.
func in_grid(position: Vector2i) -> bool:
	# We must compare them like that because the boolean operators in Vector only
	# compare the y coordinate if the x are equals, so we could end up in a situation
	# where x is in the correct range but y is not, and the comparators will still
	# say it's a valid position.
	var valid_x = position.x >= 1 and position.x <= _grid_size.x
	var valid_y = position.y >= 1 and position.y <= _grid_size.y
	return valid_x and valid_y

func _set_element_anchors(element: SpriteContainer, position: Vector2i):
	# We place the element's anchor in the middle of its cell.
	# Because the vectors start from (1, 1) we must substract 1 to get the correct
	# offset.
	element.anchor_left = _h_offset*(position.x - 0.5)
	element.anchor_right = element.anchor_left
	element.anchor_top = _v_offset*(position.y - 0.5)
	element.anchor_bottom = element.anchor_top

func _recalculate_element_anchors(element: SpriteContainer):
	_set_element_anchors(element, find_position(element))

# When changing the size of the grid, we must adjust the positions of its elements.
func _recalculate_all_anchors():
	for element in contents.values():
		_recalculate_element_anchors(element)

# TODO: move this to the dev mode combat control.
func _position_from_click(event: InputEvent):
	if event.is_action_pressed("combat_grid_cell_selected"):
		pass
	
