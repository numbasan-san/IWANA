class_name DamageNumbers extends Panel

@export var number_animator: AnimationPlayer
@export var damage_label: Label

func damage_received(value: int):
	number_animator.play("RESET")
	damage_label.text = str(value)
	number_animator.play("number_up")
	await number_animator.animation_finished
	number_animator.seek(0)
	
