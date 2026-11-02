class_name BleedingBoostPoison extends Poison

# Aumento porcentual del daño de veneno
# cuando el objetivo tiene Bleeding.
@export_range(0.0, 300.0, 1.0)
var bleeding_damage_bonus: float = 50.0

# Guarda los valores originales del daño periódico.
# Así evitamos que el bonus se acumule cada turno.
var original_values: Array[float] = []


func after_turn(target: Character):
	super.after_turn(target)

	# Guardar los valores originales una sola vez.
	if original_values.size() != after_turn_effects.size():
		original_values.clear()

		for eff in after_turn_effects:
			original_values.append(eff.value)

	# Comprobar si el enemigo tiene sangrado.
	var has_bleeding: bool = false

	for eff in target.combat_handler.lasting_effects:
		if eff is Bleeding and eff.duration > 0 \
				and not eff.is_nullified:
			has_bleeding = true
			break

	# Calcular el multiplicador.
	var multiplier: float = 1.0

	if has_bleeding:
		multiplier += bleeding_damage_bonus / 100.0

	# Modificar solamente los daños de tipo POISON.
	for i in range(after_turn_effects.size()):
		var eff = after_turn_effects[i]

		if eff is DamageEffect:
			if eff.type == DamageEffect.DamageType.POISON:
				eff.value = original_values[i] * multiplier
