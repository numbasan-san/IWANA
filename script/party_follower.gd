class_name PartyFollower
extends PathFollow2D

# An object of this class should be added to a PartyPath, and a regerence
# to it should be stored in a member of the player's party so that they can
# follow the main character

# The character associated with this follower. The follower var of this
# character must also point to this object
var character: Character

func _init(character: Character):
	self.character = character
	rotates = false
	y_sort_enabled = true
