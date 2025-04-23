## An effect that shows a box where the user can select another effect from a
## list.

class_name SelectionEffect extends Effect

## The list with all the effects from which one can select when this effect is
## applied.
@export var list: Array[Effect]

## If true, the effect selection panel won't be shown and instead all effects
## will be chosen randomly.
@export var select_random: bool = false

## The amount of effects one can select.
@export var quantity: int = 1

func copy() -> Effect:
	var new_selector = super.copy() as SelectionEffect
	var list_copy: Array[Effect] = []
	for eff in list:
		list_copy.append(eff.copy())
	
	new_selector.list = list_copy
	return new_selector

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
	
	var processed: Array[Effect] = []
	for copy in copies:
		var selection: Array[Effect] = []
		# This replaces chosen variable
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
		for eff in selection:
			processed.append_array(await eff.process_effect(allies, enemies, handler, copy.target))
		
	# We only return the selected effects, not this effect itself.
	return processed

func _manual_select(handler: TurnHandler) -> Array[Effect]:
	handler.effect_selection_panel.start_selection(self)
	return await handler.effect_selection_panel.selection_ended

func _auto_select() -> Array[Effect]:
	var n = quantity
	var selection: Array[Effect]
	var list_copy = list.duplicate()
	
	while n > 0:
		var eff = list_copy.pick_random()
		list_copy.erase(eff)
		selection.append(eff)
		n -= 1
		
	return selection

func _set_caster(_caster: Character):
	super._set_caster(_caster)
	for eff in list:
		eff.caster = _caster

func _set_skill(_skill: Skill):
	super._set_skill(_skill)
	for eff in list:
		eff.skill = _skill
