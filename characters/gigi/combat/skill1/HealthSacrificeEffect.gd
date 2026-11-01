class_name HealthSacrificeEffect extends Effect

@export_range(0.0, 100.0, 1.0)
var health_percentage: float = 10.0

func on_apply(target: Character):
	var stats = target.combat_handler.stats

	# Calculamos un porcentaje de su vida actual.
	var cost = ceil(stats.health * health_percentage / 100.0)

	# Evitamos que el sacrificio reduzca la vida a menos de 1.
	cost = minf(cost, maxf(stats.health - 1.0, 0.0))

	value = cost
	stats.health -= cost
