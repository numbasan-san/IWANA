class_name GraphicEffects extends Node2D

@export var sprite: AnimatedSprite2D

func play(anim: String):
	if sprite.sprite_frames.has_animation(anim):
		sprite.show()
		sprite.play(anim)
		await sprite.animation_finished
		sprite.hide()
