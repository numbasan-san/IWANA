extends Node2D

class_name ModeloDialogo
# Al crear una nueva escena para un personaje con graficos NV, el sprite
# inicialmente debe ir mirando hacia la izquierda

@export var escala = 0.3

@onready var personaje: Personaje = get_parent()

var posicion: ContenidosDialogo.Posicion = ContenidosDialogo.Posicion.NINGUNA

var imagen_activa: Sprite2D

# El sprite se refleja para que mire hacia la izquierda.

func _ready():
	scale = Vector2(escala, escala)
	
	for child in get_children():
		child.hide()
	# Este código asume que todos los nodos hijos (o al menos el primero) son
	# de tipo Sprite2D. Si en el futuro esto cambia, hay que reescribir este código
	if get_child_count() > 0:
		imagen_activa = get_child(0)
		imagen_activa.show()

func mirar_izquierda():
	if scale.x > 0:
		apply_scale(Vector2(-1, 1))

# El sprite se refleja para que mire hacia la derecha.
func mirar_derecha():
	if scale.x < 0:
		apply_scale(Vector2(-1, 1))

func cambiar_imagen(nombre_imagen: String):
	nombre_imagen = nombre_imagen.to_pascal_case()
	var node = get_node(nombre_imagen)
	if node:
		imagen_activa.hide()
		imagen_activa = node
		imagen_activa.show()
