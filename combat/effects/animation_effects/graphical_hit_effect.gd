## Shows a small impact graphic when the target has been hit.
class_name GraphicalHitEffect extends LastingEffect

@export var graphic_name: String

func on_intercept(effect: Effect):
	if effect is DamageEffect:
		if effect.type == DamageEffect.DamageType.PHYSICAL:
			target.combat_handler.showing_graphic.emit(graphic_name)
			interception = true
