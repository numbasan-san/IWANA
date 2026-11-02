
class_name GigiScalingLifeSteal extends LifeSteal

@export_range(0.0, 1.0, 0.01)
var min_lifesteal: float = 0.10

@export_range(0.0, 1.0, 0.01)
var max_lifesteal: float = 0.30


func on_character_hit(who: Character, effect: Effect):
	var damage_effect = effect as DamageEffect

	if damage_effect == null:
		return

	if damage_effect.type != DamageEffect.DamageType.PHYSICAL:
		return

	if damage_effect.caster != target or who == target:
		return

	var stats = target.combat_handler.stats

	var hp_ratio = clampf(
		float(stats.health) / maxf(float(stats.max_health), 1.0),
		0.0,
		1.0
	)

	# El robo de vida solo funciona por encima del 50%.
	if hp_ratio <= 0.5:
		return

	# Escalar el robo de vida según el HP de Gigi.
	var factor = (hp_ratio - 0.5) / 0.5

	var lifesteal = lerpf(
		min_lifesteal,
		max_lifesteal,
		factor
	)

	# Usar el daño realmente infligido.
	var healing = maxf(damage_effect.value, 0.0) * lifesteal

	if healing <= 0.0:
		return

	# Preparar los efectos de curación asociados.
	for heal_effect in character_hit_effects:
		heal_effect.value = healing
		heal_effect.caster = damage_effect.caster

	hit = not character_hit_effects.is_empty()
