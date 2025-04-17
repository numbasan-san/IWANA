class_name Frightening extends ChainedEffect

func on_character_hit(who: Character, effect: Effect):
	if effect is DamageEffect:
		character_hit_effect.caster = effect.caster
		character_hit_effect.target = effect.target
		hit = true
