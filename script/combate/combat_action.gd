class_name CombatAction

# Encapsulates an action that can be performed on combat, like using a skill,
# defending or fleeing. This is done in its own class so that we don't repeat
# code constructing callables in the combat script.

var callable: Callable

# Determines the position of this action in the queue. Higher numbers should go
# first 
var order: int

# Creates a new action that encapsulates a callable with the user and the target
# of the action, which can be executed later. 
func _init(action, user: Character, target: Character):
	# TODO: Change this later to add more types
	order = user.stats.speed
	if action is Skill:
		callable = Callable(action.execute).bind(user, target)
	else:
		printerr("CombatAction | Tried to build an action that wasn't a skill," \
			+ " defense or flee command. Argument was " + str(action))

func execute():
	if callable:
		callable.call()
	else:
		printerr("CombatAction | Executing an action that failed construction")
