class_name SpawnProjectile extends Effect

@export var projectile: Projectile
@export var speed: float
@export var target_offset: Vector2

func on_apply(target: Character):
	var combat_sprite = caster.combat_model.current_container.combat_sprite
	var proj = combat_sprite.spawn_projectile(projectile, speed, target, target_offset)
	await proj.finished_moving
	combat_sprite.destroy_projectile(proj)

