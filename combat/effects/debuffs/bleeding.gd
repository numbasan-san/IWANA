class_name Bleeding extends ChainedEffect

func on_incoming(effect: Effect):
	if effect is Heal:
		effect.value -= value
