## When hitting an enemy apply the burning debuff.
class_name BurningAttack extends ChainedEffect

func on_character_hit(who: Character, effect: Effect):
	if effect is DamageEffect:
		for char_hit in character_hit_effects:
			char_hit.caster = effect.caster
		hit = true
