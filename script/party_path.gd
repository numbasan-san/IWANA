class_name PartyPath
extends Path2D

# Represents a path that the party of the player will follow.
# The player controlled character will add new points to this path as
# it moves through a zone, and the other member of the party will follow
# it to replicate the movement of the player.

# The minimum distance (in a straight line) that must be between a newly
# added point and the previous one for it to be actually added
var min_point_distance: float

# The head of the path is the last added point (roughly where the player is)
var head: Vector2

# The distance each party member should keep from the next one
var member_distance: float

# The party asociated to this path
var party: Party

func _init(party: Party, start: Vector2, min_point_distance: float = 50):
	self.party = party
	self.min_point_distance = min_point_distance
	position = Vector2(0, 0)
	curve = Curve2D.new()
	curve.add_point(start)
	head = start
	y_sort_enabled = true

# Adds a new point to the path. 
func add_point(point: Vector2):
	if head.distance_to(point) >= min_point_distance:
		curve.add_point(point)
		head = point
