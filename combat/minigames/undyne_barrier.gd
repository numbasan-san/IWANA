class_name UndyneBarrier
extends Area2D

# "up", "down", "left" o "right" — de qué lado protege esta barrera. Se usa
# solo a título informativo/depuración; el bloqueo real de proyectiles no
# depende de que coincidan las direcciones, sino simplemente de que la
# barrera que el proyectil toca esté activa.
@export var direction_name: String = ""

@onready var _collision: CollisionShape2D = $CollisionShape2D

# Arranca en "true" a propósito: así, la primera llamada a set_active(false)
# desde _ready() (más abajo) se considera un cambio de verdad (true != false)
# y sí llega a deshabilitar la colisión. Si arrancara ya en "false", esa
# primera llamada se saltaría por el guardia de abajo (false == false) y la
# barrera se quedaría con la colisión activada por defecto — que es
# exactamente el bug que hacía que todas las barreras bloquearan desde el
# arranque.
var _active: bool = true

func _ready():
	add_to_group("undyne_barrier")
	monitoring = true
	monitorable = true
	set_active(false)

# Muestra u oculta la barrera Y activa/desactiva su colisión a la vez.
# IMPORTANTE: se asigna "disabled" directamente (nada de set_deferred). En
# la primera versión usaba set_deferred, y como undyne.gd llama a esta
# función en CADA frame (no solo cuando cambia la dirección), eso metía la
# activación en la cola de llamadas diferidas continuamente; asignar la
# propiedad directamente es lo normal fuera de un callback de física y evita
# esa complicación innecesaria.
func set_active(value: bool):
	if value == _active:
		return
	_active = value
	visible = value
	if _collision:
		_collision.disabled = not value
	# --- DEBUG: quita este print cuando confirmes que ya bloquea bien ---
	print("UndyneBarrier(", direction_name, ") activa=", value, " colision.disabled=", _collision.disabled if _collision else "sin CollisionShape2D")
