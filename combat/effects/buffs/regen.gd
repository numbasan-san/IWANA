
class_name Regen extends ChainedEffect


# Crea una regeneración para cada aliado.
func process_effect(
		allies: Array[Character],
		_enemies: Array[Character],
		_handler: TurnHandler,
		_parent_target: Character = null
) -> Array[Effect]:

	var result: Array[Effect] = []

	for ally in allies:
		if ally.combat_handler.stats.unconscious:
			continue

		var regen_copy = copy() as Regen

		regen_copy.caster = caster
		regen_copy.skill = skill
		regen_copy.target = ally

		result.append(regen_copy)

	return result


# Cura al personaje al terminar su turno.
func after_turn(target: Character):
	var stats = target.combat_handler.stats

	if stats.unconscious:
		return

	# Porcentaje de regeneración.
	var heal_percent = maxf(value, 0.0)

	# Calcula la curación según la vida máxima.
	var healing = stats.max_health * heal_percent / 100.0

	# Evita superar la vida máxima.
	healing = minf(
		healing,
		maxf(stats.max_health - stats.health, 0.0)
	)

	# Aplica la regeneración.
	if healing > 0.0:
		stats.health += healing

