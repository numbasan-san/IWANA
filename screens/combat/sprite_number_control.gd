class_name SpriteNumberControl extends Panel

@export var number_animator: AnimationPlayer
@export var number: Label

func heal(value: int):
	show_number("health+", value)

func damage(value: int):
	show_number("health-", value)

func gain_energy(value: int):
	show_number("energy+", value)

func lose_energy(value: int):
	show_number("energy-", value)
	
func show_number(type: String, value: int):
	number_animator.play("RESET")
	number_animator.play(type)
	await number_animator.animation_finished
	number.text = str(value)
	number_animator.play("number_up")
	await number_animator.animation_finished
	number_animator.seek(0)
