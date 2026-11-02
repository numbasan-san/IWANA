
class_name BocajarroEffect extends DamageEffect

# Número máximo de ataques con la vida completa.
@export_range(1, 12, 1)
var max_hits: int = 5

# Efecto de reducción de defensa.
@export var defense_debuff: BocajarroDefenseDebuff


func process_effect(
		allies: Array[Character],
		enemies: Array[Character],
		handler: TurnHandler,
		parent_target: Character = null
) -> Array[Effect]:

	# Seleccionamos el objetivo usando el sistema existente.
	var selected: Array[Effect] = await super.process_effect(
		allies, enemies, handler, parent_target
	)

	if skill.status != skill.Status.NEW:
		return []

	var stats = caster.combat_handler.stats

	# Porcentaje de vida de Gigi entre 0 y 1.
	var health_ratio = clampf(
		float(stats.health) / maxf(float(stats.max_health), 1.0),
		0.0,
		1.0
	)

	# Calculamos la cantidad de ataques.
	var hits = maxi(1, ceili(health_ratio * max_hits))

	var result: Array[Effect] = []

	# Creamos un ataque individual por cada golpe.
	for selected_effect in selected:
		for i in range(hits):
			var hit = selected_effect.copy() as BocajarroEffect

			hit.skill = skill
			hit.caster = caster
			hit.target = selected_effect.target

			result.append(hit)

	return result


func on_apply(target: Character):
	# Aplicar el daño normal.
	super.on_apply(target)

	if defense_debuff == null:
		return

	# No aplicamos el debuff a un enemigo derrotado.
	if target.combat_handler.stats.unconscious:
		return

	# Crear una instancia independiente del debuff.
	var debuff = defense_debuff.copy() as BocajarroDefenseDebuff

	debuff.skill = skill
	debuff.caster = caster
	debuff.target = target

	# El golpe ya acertó, por lo que agregamos
	# directamente su efecto secundario.
	target.combat_handler.add_lasting_effect(debuff)
	debuff.apply(target)


func copy() -> Effect:
	var new_effect = super.copy() as BocajarroEffect

	if defense_debuff != null:
		new_effect.defense_debuff = (
			defense_debuff.copy() as BocajarroDefenseDebuff
		)

	return new_effect
