class_name PartyFollower
extends PathFollow2D

# An object of this class should be added to a PartyPath, and a regerence
# to it should be stored in a member of the player's party so that they can
# follow the main character

# The character associated with this follower. The follower var of this
# character must also point to this object
var character: Character

# The speed at which this follower will try to move along its path
var speed: float

# The minimum distance this follower will keep from the next in line
var distance: float

# Inner variable to calculate the direction where the model should look
var _PI_QRT = PI/4

func _init(character: Character, speed: float = 800, distance: float = 200):
	self.character = character
	self.speed = speed
	self.distance = distance
	rotates = false
	y_sort_enabled = true
	loop = false

func _process(delta):
	var effective_speed = speed * delta
	if character.is_leader and not character.is_following:
		if progress_ratio < 1:
			progress += effective_speed
	if not character.is_leader:
		var prev_pos = position
		var index = character.party.index(character)
		var next = character.party.members[index - 1]
		var next_follower = next.follower_node
		if next_follower.progress - progress > distance:
			progress += effective_speed
		
		if character.rpg_model and position != prev_pos:
			var vect = position - prev_pos
			# atan2 returns a number between -PI and PI (with 0 = +x direction)
			var angle = atan2(vect.y, vect.x)
			# We add or remove 0.1 from angle so there is some area between the
			# edges that will be ignored, so that when the angle falls in that
			# area the direction won't change, preventing jittering
			if angle > -3*_PI_QRT + 0.1 and angle < -1*_PI_QRT - 0.1:
				character.rpg_model.direction = "up"
			elif angle > -1*_PI_QRT + 0.1 and angle < _PI_QRT - 0.1:
				character.rpg_model.direction = "right"
			elif angle > _PI_QRT + 0.1 and angle < 3*_PI_QRT - 0.1:
				character.rpg_model.direction = "down"
			elif angle > 3*_PI_QRT + 0.1 or angle < -3*_PI_QRT - 0.1:
				character.rpg_model.direction = "left"
			
