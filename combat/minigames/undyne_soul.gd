class_name UndyneSoul
extends Area2D

# Se emite cuando un proyectil no bloqueado llega a tocar el alma. El
# controlador del minijuego (undyne.gd) es quien decide qué hacer con la
# vida: aquí solo se avisa de que "esto golpeó" y cuánto daño trae.
signal hit(damage: int)

func _ready():
	add_to_group("undyne_soul")
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D):
	if area is UndyneProjectile:
		hit.emit(area.damage)
		area.queue_free()
