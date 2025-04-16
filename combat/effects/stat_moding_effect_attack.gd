# This is a temporary solution to allow stat buffs and debuffs to intercept other
# effects to facilitate some skills where the buffs and debuffs are removed when
# the target performs or receives a physical attack.

class_name StatModingEffectOnAttack extends StatModingEffect

func on_character_hit(who: Character, effect: Effect):
	if effect is DamageEffect:
		if effect.type == DamageEffect.DamageType.PHYSICAL:
			hit = true

func on_incoming(effect: Effect):
	if effect is DamageEffect:
		if effect.type == DamageEffect.DamageType.PHYSICAL:
			incoming_intercepted = true
