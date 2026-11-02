class_name GigiLimitBuff extends LastingEffect

@export var base_critical_bonus: float = 10.0
@export var critical_bonus_low_hp: float = 30.0
@export var critical_per_burn: float = 5.0

@export var base_precision_bonus: int = 10
@export var precision_bonus_low_hp: int = 20
@export var precision_per_burn: int = 5

var applied_precision: int = 0
var critical_bonus: float = 0.0


func on_apply(_target: Character):
	_refresh_bonuses()


func _refresh_bonuses():
	var stats = target.combat_handler.stats

	var hp_ratio = clampf(
		float(stats.health) / maxf(float(stats.max_health), 1.0),
		0.0,
		1.0
	)

	var new_critical: float = 0.0
	var new_precision: int = 0

	if hp_ratio <= 0.5:
		# Cuánto ha bajado la vida desde el 50%.
		var low_hp = clampf(
			(0.5 - hp_ratio) / 0.5,
			0.0,
			1.0
		)

		# Contar las quemaduras activas de Gigi.
		var burns: int = 0

		for eff in target.combat_handler.lasting_effects:
			if eff is Burnt and eff.duration > 0:
				burns += 1

		new_critical = (
			base_critical_bonus
			+ critical_bonus_low_hp * low_hp
			+ critical_per_burn * burns
		)

		new_precision = roundi(
			base_precision_bonus
			+ precision_bonus_low_hp * low_hp
			+ precision_per_burn * burns
		)

	# Actualizar únicamente la diferencia de precisión.
	stats.precision += new_precision - applied_precision

	applied_precision = new_precision
	critical_bonus = new_critical


func on_outgoing(effect: Effect):
	if not effect is DamageEffect:
		return

	if effect.caster != target:
		return

	# Actualizar según la vida y quemaduras actuales.
	_refresh_bonuses()

	if effect.is_critical:
		return

	var base_chance = clampf(
		float(target.combat_handler.stats.critical),
		0.0,
		100.0
	)

	# DamageEffect.on_cast() ya hizo la tirada normal.
	# Esta segunda tirada añade la bonificación restante.
	var remaining = 100.0 - base_chance

	if remaining <= 0.0:
		return

	var extra_chance = clampf(
		critical_bonus / remaining,
		0.0,
		1.0
	)

	if randf() < extra_chance:
		effect.is_critical = true
		outgoing_intercepted = true


func on_unapply(_target: Character):
	var stats = target.combat_handler.stats
	stats.precision -= applied_precision

	applied_precision = 0
	critical_bonus = 0.0
