extends Area2D

class_name ControlTransparencia

@export var valor_transparencia = 0.15

func activar_transparencia():
	$"../Sprite2D".modulate = Color(1, 1, 1, valor_transparencia)


func desactivar_transparencia():
	$"../Sprite2D".modulate = Color(1, 1, 1, 1)
