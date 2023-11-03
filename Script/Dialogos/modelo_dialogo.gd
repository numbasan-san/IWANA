extends Node2D

# Al crear una nueva escena para un personaje con graficos NV, el sprite
# inicialmente debe ir mirando hacia la izquierda

# El sprite se refleja para que mire hacia la izquierda.

func mirarIzquierda():
	if scale.x > 0:
		apply_scale(Vector2(-1, 1))

# El sprite se refleja para que mire hacia la derecha.
func mirarDerecha():
	if scale.x < 0:
		apply_scale(Vector2(-1, 1))
