## An effect that shows a box where the user can select a skill from a list.
# TODO: it extends a lasting effect only because the only effect that uses skill
# selection is Control, a debuff, and it is easier to use it if it extends this
# effect. We need to implement a way to pass information between different effects
# so that it can be made more generic.
class_name SkillSelectionEffect extends LastingEffect

## The list with all the skills from which one can select when this effect is
## applied.
var list: Array[Skill]:
	get:
		if target:
			# We use this to only allow the selection of enabled skills, so that the
			# target can at least use one. If later we decide to allow selection of
			# disabled skills and for the target to skip its turn, we must change this.
			var enabled_skills = target.combat_handler.skills.filter(func(skill):
				return skill.enabled
			)
			return enabled_skills
		else:
			return []

## The list of the selected skills.
var chosen: Array[Skill] = []:
	set(new_choice):
		chosen = new_choice
	get:
		return chosen

## If true, the skill selection panel won't be shown and instead all skills
## will be chosen randomly.
@export var select_random: bool = false

## The maximum amount of skills one can select.
@export var quantity: int = 1

func is_valid():
	return super.is_valid() and chosen.size() <= quantity

func _manual_select(combat: CombatScreenControl) -> Array[Skill]:
	# Show selection box
	return []

func _auto_select() -> Array[Skill]:
	# Select random or with algorithm
	return []
