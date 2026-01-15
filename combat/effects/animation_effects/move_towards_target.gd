class_name MoveTowardsTarget extends Effect

@export var graphic_name: String

@export var offset: Vector2
@export var speed: int

func on_apply(target: Character):
	# TODO: replace this with something better
	caster.combat_model.current_container.combat_sprite.move_to_target(target, offset, graphic_name, speed)
	await caster.combat_model.current_container.combat_sprite.finished_moving
