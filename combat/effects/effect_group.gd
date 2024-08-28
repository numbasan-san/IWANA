## Groups effects together to handle them as one.
##
## When sending the group to a target, only the targets defined in the group
## will be considered, while the targets in the individual effects will be ignored.
class_name EffectGroup extends Effect

# TODO: currently, for intercepting effects they can only intercept individual
# effects, this includes an effect group as a whole, but they can't intercept an
# effect inside the group. For example if a group has a debuff and a damage effect,
# an effect that can intercept damage won't recognize it, but it should be able
# to block it while leaving the debuff untouched.

## The list of effects of this group.
##
## All of these effects will be applied to each of the selected targets
@export var effects: Array[Effect]

func on_cast(caster: Character):
	for eff in effects:
		await eff.cast(caster)

func on_send(target: Character):
	for eff in effects:
		await eff.send(target)

func on_receive(caster: Character):
	for eff in effects:
		await eff.receive(caster)

func on_apply(target: Character):
	for eff in effects:
		await eff.apply(target)

func copy() -> Effect:
	var new_group = super.copy() as EffectGroup
	var effects_copy: Array[Effect] = []
	for eff in effects:
		effects_copy.append(eff.copy())
	new_group.effects = effects_copy
	return new_group

func _set_caster(_caster: Character):
	super._set_caster(_caster)
	for eff in effects:
		eff.caster = _caster

func _set_skill_targets(_targets: Array[Character]):
	super._set_skill_targets(_targets)
	for eff in effects:
		eff.skill_targets = _targets
