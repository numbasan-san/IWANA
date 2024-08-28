class_name ProjectileSpawner extends Node2D

signal projectile_destroyed(projectile: CombatSprite)

func spawn(
		proj: Projectile,
		speed: float,
		target: Character,
		target_offset: Vector2) -> CombatSprite:
			
	var proj_sprite: CombatSprite = CombatSprite.new()
	proj_sprite.speed = speed
	proj_sprite.sprite = AnimatedSprite2D.new()
	proj_sprite.sprite.sprite_frames = proj.sprite
	add_child(proj_sprite)
	proj_sprite.add_child(proj_sprite.sprite)
	proj_sprite.move_to_target(target, target_offset)
	return proj_sprite

func destroy(projectile: CombatSprite):
	projectile.queue_free()
	projectile_destroyed.emit(projectile)
