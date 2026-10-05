class_name UndyneProjectileSpawner
extends Node2D

# Escena de proyectil a instanciar (combat/minigames/undyne_projectile.tscn)
@export var projectile_scene: PackedScene

# "up", "down", "left" o "right" — de qué lado nace este spawner. Se guarda
# en el proyectil solo a título informativo/depuración.
@export var direction_name: String = ""

@export var base_speed: float = 220.0
@export var speed_variance: float = 80.0
@export var damage: int = 1

# Crea un proyectil en la posición de este spawner, viajando en línea recta
# hacia el centro de la arena (0, 0), y lo añade como hermano del spawner
# (hijo del nodo "undyne"), para que se mueva en el mismo espacio local que
# las barreras y el alma.
func spawn_projectile() -> UndyneProjectile:
	if not projectile_scene:
		push_error("UndyneProjectileSpawner | No hay projectile_scene asignada en " + name)
		return null
	
	var proj: UndyneProjectile = projectile_scene.instantiate()
	proj.position = position
	proj.direction = (Vector2.ZERO - position).normalized()
	# proj.rotation = proj.direction.angle() + 90
	proj.speed = base_speed + randf_range(-speed_variance, speed_variance)
	proj.damage = damage
	proj.origin_direction = direction_name
	
	if direction_name == "left":
		proj.rotation_degrees = 90
	if direction_name == "up":
		proj.rotation_degrees = 180
	if direction_name == "right":
		proj.rotation_degrees = 270

	get_parent().add_child(proj)
	return proj
