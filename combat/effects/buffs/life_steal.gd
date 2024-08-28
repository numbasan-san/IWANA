## Recovers health to the character based on the damage done to an enemy.
##
## 
class_name LifeSteal extends LastingEffect

func on_character_hit(who: Character, effect: Effect):
	if effect is DamageEffect:
		if effect.type == DamageEffect.DamageType.PHYSICAL:
			var damage = effect.value
			target.combat_handler.stats.health += damage * value / 100
			hit = true
