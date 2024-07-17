class_name EffectGroup extends Effect

## The list of effects of this group.
##
## All of these effects will be applied to each of the selected targets
@export var effects: Array[Effect]

func on_cast(caster: Character):
	for eff in effects:
		eff.on_cast(caster)

func on_send(target: Character):
	for eff in effects:
		eff.on_send(target)

func on_receive(caster: Character):
	for eff in effects:
		eff.on_receive(caster)

func on_apply(target: Character):
	for eff in effects:
		eff.on_apply(target)
