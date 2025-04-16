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
			eff.skill_targets = skill_targets
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

func _set_caster(_caster: Character):
	super._set_caster(_caster)
	for eff in list:
		eff.caster = _caster
	for eff in chosen:
		eff.caster = _caster

func _set_target(_target: Character):
	super._set_target(_target)
	for eff in list:
		eff.target = _target
	for eff in chosen:
		eff.target = _target

func _set_skill_targets(_targets: Array[Character]):
	super._set_skill_targets(_targets)
	for eff in list:
		eff.skill_targets = _targets
	for eff in chosen:
		eff.skill_targets = _targets

func _set_skill(_skill: Skill):
	super._set_skill(_skill)
	for eff in list:
		eff.skill = _skill
	for eff in chosen:
		eff.skill = _skill

func _flatten() -> Array[Effect]:
	var result: Array[Effect] = []
	for eff in chosen:
		result.append_array(eff._flatten())
	return result
