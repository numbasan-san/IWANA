class_name Quiromancy extends LastingEffect

@export var damage_per_turn: float = 1

func on_receive(target: Character):
	if target.combat_handler.lasting_effects.has(self):
		var damage = DamageEffect.new()
		damage.value = value
		damage.type == DamageEffect.DamageType.PHYSICAL
		damage.caster = caster
		target.combat_handler.remove_lasting_effect(self)
		target.combat_handler.receive(damage)
		is_nullified = true
	else:
		value = base_value
		_update_variable_info()
func after_turn(target: Character):
	value += damage_per_turn
	_update_variable_info()

func _update_variable_info():
	base_data.variable_info = "Damage: " + str(value)
