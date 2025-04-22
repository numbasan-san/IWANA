## An effect that shows a box where the user can select another effect from a
## list.

class_name SelectionEffect extends Effect

## The list with all the effects from which one can select when this effect is
## applied.
@export var list: Array[Effect]

## The list of the selected effects.
var chosen: Array[Effect] = []:
	set(new_choice):
		for eff in new_choice:
			eff.caster = caster
			eff.target = target
		chosen = new_choice
	get:
		return chosen

## If true, the effect selection panel won't be shown and instead all effects
## will be chosen randomly.
@export var select_random: bool = false

## The amount of effects one can select.
@export var quantity: int = 1

func on_cast(caster: Character):
	for eff in chosen:
		await eff.cast(caster)

func on_send(target: Character):
	for eff in chosen:
		await eff.send(target)

func on_receive(caster: Character):
	for eff in chosen:
		await eff.receive(caster)

func on_apply(target: Character):
	for eff in chosen:
		await eff.apply(target)
		
func is_valid():
	return super.is_valid() and list.size() >= quantity and chosen.size() == quantity

func copy() -> Effect:
	var new_selector = super.copy() as SelectionEffect
	var list_copy: Array[Effect] = []
	var chosen_copy: Array[Effect] = []
	for eff in list:
		list_copy.append(eff.copy())
	for eff in chosen:
		chosen_copy.append(eff.copy())
	new_selector.list = list_copy
	new_selector.chosen = chosen_copy
	return new_selector

func process_effect(
		allies: Array[Character],
		enemies: Array[Character],
		combat: CombatScreenControl,
		parent_target: Character = null) -> Array[Effect]:
	
	var copies = super.process_effect(allies, enemies, combat, parent_target)
	
	var processed: Array[Effect] = []
	for copy in copies:
		var selection: Array[Effect] = []
		# This replaces chosen variable
		# Because the copies have the same values, we can get the effect lists
		# from the original, as they will be copied after processing anyways.
		if select_random:
			selection = _auto_select()
		else:
			selection = await _manual_select(combat)
		for eff in selection:
			eff.caster = caster
			processed.append_array(eff.process_effect(allies, enemies, combat, copy.target))
		
		# We only return the selected effects, not this effect itself.
	return processed

func _manual_select(combat: CombatScreenControl) -> Array[Effect]:
	# Show selection box
	return []

func _auto_select() -> Array[Effect]:
	# Select random or with algorithm
	return []

func _set_caster(_caster: Character):
	super._set_caster(_caster)
	for eff in list:
		eff.caster = _caster
	for eff in chosen:
		eff.caster = _caster

func _set_skill(_skill: Skill):
	super._set_skill(_skill)
	for eff in list:
		eff.skill = _skill
	for eff in chosen:
		eff.skill = _skill
