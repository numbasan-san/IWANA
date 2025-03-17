## Recovers health to the character based on the damage done to an enemy.
##
## 
class_name LifeSteal extends ChainedEffect

func on_character_hit(who: Character, effect: Effect):
	if effect is DamageEffect:
		if effect.type == DamageEffect.DamageType.PHYSICAL:
			var damage = effect.value
			character_hit_effect.value = damage * value
			# We are assuming that the caster of the intercepted effect is going
			# to receive the heal
			character_hit_effect.caster = effect.caster
			hit = true
