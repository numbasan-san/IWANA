class_name ComboDamageEffect extends DamageEffect

@export_range(0.0, 200.0, 1.0)
var bonus_per_use: float = 25.0

@export var tracker_template: SkillStreakTracker

func on_cast(caster: Character):
	super.on_cast(caster)

	var handler = caster.combat_handler
	var tracker: SkillStreakTracker = null

	# Buscar el contador del personaje.
	for eff in handler.lasting_effects:
		if eff is SkillStreakTracker:
			tracker = eff
			break

	# Si no existe, crearlo.
	if tracker == null:
		if tracker_template == null:
			push_error("Falta configurar tracker_template")
			return

		tracker = tracker_template.copy() as SkillStreakTracker
		tracker.caster = caster
		tracker.target = caster
		tracker.skill = skill

		tracker.decrease_duration = LastingEffect.Decrease.NEVER
		tracker.duration = 999999

		tracker.last_used_skill = skill
		tracker.streak = 1

		handler.add_lasting_effect(tracker)

	# Calcular el aumento de daño.
	var bonus = maxi(tracker.streak - 1, 0) * bonus_per_use / 100.0

	value *= 1.0 + bonus
