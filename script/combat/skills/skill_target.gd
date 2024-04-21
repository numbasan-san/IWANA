class_name SkillTarget

# A skill can have one of several target types:
# NONE: the skill affects its user directly. No target is chosen
# FRIEND: the skill affects a single member of the party. The target must be
#	chosen when using the skill
# ALL_FRIENDS: the skill affects all members of the party except for the user.
#	No target is chosen
# PARTY: the skill affects all members of the party. No target is chosen
# ENEMY: the skill affects a single enemy. The target must be chosen when using
# 	the skill
# ENEMY_PARTY: the skill affects all enemies. No target is chosen
# EVERYONE: the skill affects every character in combat. No target is chosen

enum { 
	NONE,
	FRIEND,
	ALL_FRIENDS,
	PARTY,
	ENEMY,
	ENEMY_PARTY,
	EVERYONE,
}
