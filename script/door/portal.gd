extends Node2D

@export var zone : String
@export var spawn: String
@export var spawn_direction: String

# If this door is going to be placed in the south wall, so it
# should be shown transparent to not block other objects
@export var transparent: bool = false:
	set(value):
		if value != transparent:
			transparent = value
			var tv = transparency_value if value else 1
			$Sprite2D.modulate = Color(1, 1, 1, tv)
			
@export var transparency_value = 0.15
# If this door will show it's front sprite (the side pointing
# outside the room) or it's back. If the door has only one sprite
# for both sides, this should be left as true
@export var front: bool = true:
	set(value):
		if front != value:
			front = value
			# In the current sprite file, 405 is the distance between
			# the 2 sides of the same door. This will have to change if
			# the files change
			var side = y_front if value else y_back
			$Sprite2D.region_rect.position.y = side

# If this door can be interacted with to change zones.
@export var enabled: bool = true:
	set(value):
		enabled = value
		$ZoneChange.is_active = value

# We assume that all doors are in the same file, and that the back
# sprite is at a constant distance above the front one, so the y
# coordinate will be always set to a constant value known beforehand.
# If the files change, we have to change these values
var y_front = 560
var y_back = 155
