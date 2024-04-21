extends Node2D

@export var zone : String
@export var spawn: String
@export var spawn_direction: String

# If this door is going to be placed in the south wall, so it
# should be shown transparent to not block other objects
@export var transparent: bool = false
@export var transparency_value = 0.15
# If this door will show it's front sprite (the side pointing
# outside the room) or it's back. If the door has only one sprite
# for both sides, this should be left as true
@export var front: bool = true

# We assume that all doors are in the same file, and that the back
# sprite is at a constant distance above the front one, so the y
# coordinate will be always set to a constant value known beforehand.
# If the files change, we have to change these values
var y_front = 560
var y_back = 155

# We assume that every base door scene will have its region set
# to the front side. When the door is loaded we will check the
# front variable to decide if we leave this or switch it
func _ready():
	if front:
		set_front()
	else:
		set_back()
	if transparent:
		enable_transparency()
	else:
		disable_transparency()

func set_front():
	if not front:
		front = true
		# In the current sprite file, 405 is the distance between
		# the 2 sides of the same door. This will have to change if
		# the files change
		$Sprite2D.region_rect.position.y = y_front
		
func set_back():
	if front:
		front = false
		# In the current sprite file, 405 is the distance between
		# the 2 sides of the same door. This will have to change if
		# the files change
		$Sprite2D.region_rect.position.y = y_back
		
func switch_side():
	if front:
		set_back()
	else:
		set_front()

func enable_transparency():
	transparent = true
	$Sprite2D.modulate = Color(1, 1, 1, transparency_value)

func disable_transparency():
	transparent = false
	$Sprite2D.modulate = Color(1, 1, 1, 1)

func switch_transparency():
	if transparent:
		disable_transparency()
	else:
		enable_transparency()
