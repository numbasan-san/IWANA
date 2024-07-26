class_name SpawnProjectile extends Effect

@export var projectile: Projectile
@export var speed: float
@export var target_offset: Vector2

func on_apply(target: Character):
	var combat_sprite = caster.combat_model.current_container.combat_sprite
	combat_sprite.spawn_projectile(projectile, speed, target, target_offset)
	await combat_sprite.projectile_destroyed
