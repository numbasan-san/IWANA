class_name CombatAreaOverlay extends Panel

@export var grid_control: Panel
@export var move_overlay: OverlayMover
@export var top_overlay: OverlayResizer
@export var left_overlay: OverlayResizer
@export var bottom_overlay: OverlayResizer
@export var right_overlay: OverlayResizer
@export var cells_overlay: OverlayCellsControl

var combat_area: CombatPartyArea:
	set(value):
		combat_area = value
		cells_overlay.combat_area = value

enum SizeChange {
	TOP,
	LEFT,
	BOTTOM,
	RIGHT
}

func _ready():
	top_overlay.moved.connect(_size_change.bind(SizeChange.TOP))
	left_overlay.moved.connect(_size_change.bind(SizeChange.LEFT))
	bottom_overlay.moved.connect(_size_change.bind(SizeChange.BOTTOM))
	right_overlay.moved.connect(_size_change.bind(SizeChange.RIGHT))
	move_overlay.moved.connect(_panel_moved)

func _sync_area_controls():
	var sync = func(controller: Control, controlled: Control):
		controlled.global_position = controller.global_position
		controlled.size = controller.size
		
	sync.call(combat_area, grid_control)
	grid_control.item_rect_changed.connect(sync.bind(grid_control, combat_area))
	
# The size changers are children of the panel that's been resized so they move
# with it when it changes, and we change the size of a child of this panel instead
# of this panel itself because when we tried resizing self, it immediately reverted
# to its original value.
func _size_change(delta: float, side: SizeChange):
	if side == SizeChange.TOP:
		# For the top side, a negative delta means increasing the size upwards.
		grid_control.size.y -= delta
		grid_control.position.y += delta
	elif side == SizeChange.LEFT:
		# For the left side, a negative delta means increasing the size to the left.
		grid_control.size.x -= delta
		grid_control.position.x += delta
	elif side == SizeChange.BOTTOM:
		# For the bottom side, a positive delta means increasing the size downwards.
		# As the position is the top left corner, it doesn't move.
		grid_control.size.y += delta
	elif side == SizeChange.RIGHT:
		# For the right side, a positive delta means increasing the size to the left.
		# As the position is the top left corner, it doesn't move.
		grid_control.size.x += delta
		
func _panel_moved(delta: Vector2):
	grid_control.position += delta
