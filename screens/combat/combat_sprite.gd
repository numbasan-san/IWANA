class_name CombatSprite extends Node2D

# TODO: Should this be here or in the effects? 
@export var default_speed: int = 1000
@export var projectiles: ProjectileSpawner

var sprite: AnimatedSprite2D

var actual_position: Vector2 = Vector2(0, 0)
var target_position: Vector2
var speed: int = default_speed

# This should be set to true when the sprite is returning to its original
# position to indicate it should be flipped. When it reaches its destination it
# should be set to false and flipped again to be left in its default state.
var returning: bool = false

signal sprite_animation_ended
signal finished_moving

# TODO: considering moving this to a separate projectile class
signal projectile_destroyed

func _process(delta):
	if sprite and not actual_position.is_equal_approx(target_position):
		var actual_speed = speed * delta
		actual_position = actual_position.move_toward(target_position, actual_speed)
		sprite.position = actual_position
		if actual_position.is_equal_approx(target_position):
			if returning:
				sprite.apply_scale(Vector2(-1, 1))
				returning = false
			speed = default_speed
			finished_moving.emit()
	

func set_sprite(new_sprite: AnimatedSprite2D = null):
	if sprite and not new_sprite:
		sprite.free()
		sprite = null
	if not sprite and new_sprite:
		var copy = new_sprite.duplicate()
		add_child(copy)
		sprite = copy
	if new_sprite:
		var anim = new_sprite.animation
		sprite.animation = anim
		sprite.play()
		if not sprite.sprite_frames.get_animation_loop(anim):
			await sprite.animation_finished
			sprite_animation_ended.emit()

func move_to_target(target: Character, offset: Vector2, graphic: String = "", effect_speed: int = 0):
	var target_position = target.combat_model.current_container.combat_sprite.global_position
	# If going from left to right, the offset should be subtracted
	if global_position.x < target_position.x:
		offset = offset * Vector2(-1, 1)
	var diff = target_position - global_position + offset
	move_to(diff, graphic, effect_speed)

func move_to(position: Vector2, graphic: String, effect_speed: int = 0):
	if sprite:
		if effect_speed == 0:
			effect_speed = default_speed
		speed = effect_speed
		target_position = position * scale.sign()
		sprite.play(graphic)

func return_to_origin(offset: Vector2 = Vector2(0, 0), graphic: String = "", effect_speed: int = 0):
	if not returning:
		returning = true
		sprite.apply_scale(Vector2(-1, 1))
		if global_position.x < 0:
			offset = offset * Vector2(-1, 1)
		move_to(offset, graphic, effect_speed)
	
func spawn_projectile(
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

func destroy_projectile(projectile: CombatSprite):
	projectile.queue_free()
	projectile_destroyed.emit(projectile)
