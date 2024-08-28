# This is intended only for playing an animation on the caster, so it should be
# nullified before calling send.
class_name PlayAnimation extends Effect

@export var graphic_name: String

func on_apply(target: Character):
	caster.combat_model.set_sprite(graphic_name)
	if not caster.combat_model.combat_animation.sprite_frames.get_animation_loop(graphic_name):
		await caster.combat_model.sprite_animation_ended

	is_nullified = true
