class_name RunTowardsTarget extends Effect

@export var graphic_name: String

@export var offset: Vector2

func on_apply(target: Character):
	# TODO: replace this with something better
	var this_position: Vector2 = caster.combat_model.current_container.combat_sprite.global_position
	var other_position: Vector2 = target.combat_model.current_container.combat_sprite.global_position
	var diff = other_position - this_position + offset
	caster.combat_model.current_container.combat_sprite.move_to(diff)
	await caster.combat_model.current_container.combat_sprite.finished_moving
