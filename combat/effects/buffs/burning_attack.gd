## When hitting an enemy apply the burning debuff.
class_name BurningAttack extends ChainedEffect

func on_character_hit(who: Character, effect: Effect):
	if effect is DamageEffect:
		character_hit_effect.caster = effect.caster
		hit = true
