class_name Return extends Effect

@export var graphic_name: String

func on_apply(target: Character):
	# TODO: replace this with something better
	caster.combat_model.current_container.combat_sprite.return_to_origin()
	await caster.combat_model.current_container.combat_sprite.finished_moving
