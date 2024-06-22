class_name PartyPath
extends Path2D

# Represents a path that the party of the player will follow.
# The player controlled character will add new points to this path as
# it moves through a zone, and the other member of the party will follow
# it to replicate the movement of the player.

# If a new point is added when this path has this number of points, the
# oldest point (the tail of the path) is removed
var max_length: int

# The minimum distance (in a straight line) that must be between a newly
# added point and the previous one for it to be actually added
var min_distance: float

# The head of the path is the last added point (roughly where the player is)
var head: Vector2

func _init(start: Vector2, min_distance: float = 50, max_length: int = 10):
	self.max_length = max_length
	self.min_distance = min_distance
	position = Vector2(0, 0)
	curve = Curve2D.new()
	curve.add_point(start)
	head = Vector2(0, 0)

# Adds a new point to the path. 
func add_point(point: Vector2):
	if head.distance_to(point) >= min_distance:
		curve.add_point(point)
		head = point
		if curve.point_count > max_length:
			curve.remove_point(0)

func remove_tail():
	self.curve.remove_point(0)
