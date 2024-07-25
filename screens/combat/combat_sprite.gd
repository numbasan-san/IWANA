class_name CombatSprite extends Node2D

var sprite: AnimatedSprite2D

var actual_position: Vector2 = Vector2(0, 0)
var target_position: Vector2
# TODO: Should this be here or in the effects? 
@export var speed: int = 600

signal finished_moving

func _process(delta):
	if sprite and not actual_position.is_equal_approx(target_position):
		var actual_speed = speed * delta
		actual_position = actual_position.move_toward(target_position, actual_speed)
		sprite.position = actual_position
		if actual_position.is_equal_approx(target_position):
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
		sprite.animation = new_sprite.animation
		sprite.play()
		var current_anim = sprite.animation
		if current_anim != "Idle" and not sprite.sprite_frames.get_animation_loop(current_anim):
			await sprite.animation_finished
			

func move_to(position: Vector2):
	if sprite:
		target_position = position * scale.sign()
		sprite.play("Moving")

func return_to_origin():
	move_to(Vector2(0, 0))
