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

#TODO: implement process_effect

func process_effect(
		allies: Array[Character],
		enemies: Array[Character],
		handler: TurnHandler,
		parent_target: Character = null) -> Array[Effect]:
	
	var copies = await super.process_effect(allies, enemies, handler, parent_target)
	# Before processing the skill is set to NEW unless it failed some check.
	# During processing it should still be NEW unless it was manually cancelled
	# or something failed.
	if skill.status != skill.Status.NEW:
		return []
	
	for copy in copies:
		var selection: Array[Skill] = []
		# Because the copies have the same values, we can get the effect lists
		# from the original, as they will be copied after processing anyways.
		if quantity >= list.size():
			selection = list
		elif select_random:
			selection = _auto_select()
		else:
			selection = await _manual_select(handler)
		
		if selection.size() == 0:
			skill.status = skill.Status.CANCELLED
			return []
		
		copy.chosen = selection
		
	return copies

func _manual_select(handler: TurnHandler) -> Array[Skill]:
	handler.skill_selection_panel.start_selection(self)
	return await handler.skill_selection_panel.selection_ended

func _auto_select() -> Array[Skill]:
	var n = quantity
	var selection: Array[Skill]
	var list_copy = list.duplicate()
	
	while n > 0:
		var skill = list_copy.pick_random()
		list_copy.erase(skill)
		selection.append(skill)
		n -= 1
		
	return selection
