extends Node2D

class_name ModeloDialogo
# Al crear una nueva escena para un personaje con graficos NV, el sprite
# inicialmente debe ir mirando hacia la izquierda

@onready var personaje: Personaje = get_parent()

var posicion: ContenidosDialogo.Posicion = ContenidosDialogo.Posicion.NINGUNA

# El sprite se refleja para que mire hacia la izquierda.

func mirar_izquierda():
	if scale.x > 0:
		apply_scale(Vector2(-1, 1))

# El sprite se refleja para que mire hacia la derecha.
func mirar_derecha():
	if scale.x < 0:
		apply_scale(Vector2(-1, 1))
