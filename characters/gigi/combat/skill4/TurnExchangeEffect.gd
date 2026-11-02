
class_name TurnExchangeEffect extends Effect

var combat: CombatScreenControl


func process_effect(
		allies: Array[Character],
		enemies: Array[Character],
		handler: TurnHandler,
		parent_target: Character = null
) -> Array[Effect]:

	var copies: Array[Effect] = await super.process_effect(
		allies, enemies, handler, parent_target
	)

	if skill.status != skill.Status.NEW:
		return []

	# La habilidad debe seleccionar exactamente un aliado.
	if copies.size() != 1:
		skill.status = skill.Status.ERROR
		return []

	for eff in copies:
		var exchange = eff as TurnExchangeEffect

		if exchange == null:
			skill.status = skill.Status.ERROR
			return []

		exchange.combat = handler.combat

		# No puede seleccionarse a Gigi ni a un enemigo.
		if exchange.target == caster or not allies.has(exchange.target):
			push_warning("Debes seleccionar otro aliado.")
			skill.status = skill.Status.ERROR
			return []

		# El aliado debe estar consciente.
		if exchange.target.combat_handler.stats.unconscious:
			skill.status = skill.Status.ERROR
			return []

		# Solo permitimos adelantar aliados que aún
		# no hayan realizado su turno en esta ronda.
		if not handler.combat.actor_queue.has(exchange.target):
			push_warning("Este aliado ya realizó su turno.")
			skill.status = skill.Status.ERROR
			return []

	return copies


func on_cast(_caster: Character):
	if combat == null:
		is_nullified = true
		return

	var queue = combat.actor_queue

	# Verificamos que el aliado siga pendiente.
	if not queue.has(target):
		is_nullified = true
		return

	# 1. Retiramos al aliado de su posición original.
	queue.erase(target)

	# 2. Lo colocamos como siguiente personaje.
	queue.push_front(target)

	# 3. Gigi pasa al final de la ronda.
	queue.erase(caster)
	queue.push_back(caster)

	# 4. La habilidad queda deshabilitada.
	skill.enabled = false

	# No necesitamos enviar ni aplicar ningún
	# efecto convencional sobre el objetivo.
	is_nullified = true
