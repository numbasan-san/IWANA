
class_name BurnReleaseEffect extends DamageEffect

# Bonus de daño por cada acumulación de Burnt consumida.
@export_range(0.0, 200.0, 1.0)
var bonus_per_burn: float = 25.0

# Bonus máximo de daño por vida faltante.
@export_range(0.0, 300.0, 1.0)
var missing_health_bonus: float = 100.0

# Nombre de la propiedad de vida máxima en Stats.
@export var max_health_property: StringName = &"max_health"


func on_apply(target: Character):
	# Obtener las estadísticas de Gigi.
	var caster_handler = caster.combat_handler
	var caster_stats = caster_handler.stats

	# 1. Obtener la vida máxima.
	var max_hp: float = 0.0

	for property in caster_stats.get_property_list():
		if StringName(property["name"]) == max_health_property:
			max_hp = float(caster_stats.get(max_health_property))
			break

	# 2. Calcular el porcentaje de vida faltante.
	var missing_health_ratio: float = 0.0

	if max_hp > 0.0:
		missing_health_ratio = clampf(
			(max_hp - float(caster_stats.health)) / max_hp,
			0.0,
			1.0
		)
	else:
		push_warning("No se encontró la propiedad de vida máxima")

	# 3. Consumir las acumulaciones de Burnt de Gigi.
	var burns_removed: int = 0

	for eff in caster_handler.lasting_effects.duplicate():
		if eff is Burnt:
			caster_handler.remove_lasting_effect(eff)
			burns_removed += 1

	# 4. Calcular las bonificaciones.
	var burn_bonus = burns_removed * bonus_per_burn / 100.0

	var health_bonus = (
		missing_health_ratio * missing_health_bonus / 100.0
	)

	# 5. Aumentar el daño.
	var multiplier = 1.0 + burn_bonus + health_bonus
	value *= multiplier

	# 6. Aplicar el daño al enemigo.
	super.on_apply(target)
