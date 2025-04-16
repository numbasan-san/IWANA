class_name ThrowBackpack extends SpawnProjectile

func on_apply(target: Character):
	var combat_sprite = caster.combat_model.current_container.combat_sprite
	var proj = combat_sprite.spawn_projectile(projectile, speed, target, target_offset)
	await proj.finished_moving
	proj.sprite.animation = "landing"
	proj.sprite.play()
	await proj.sprite.animation_finished
	combat_sprite.destroy_projectile(proj)
