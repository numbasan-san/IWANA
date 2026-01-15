class_name Return extends Effect

@export var graphic_name: String

@export var offset: Vector2 = Vector2(0, 0)
@export var speed: int

func on_apply(target: Character):
	# TODO: replace this with something better
	caster.combat_model.current_container.combat_sprite.return_to_origin(offset, graphic_name, speed)
	await caster.combat_model.current_container.combat_sprite.finished_moving
