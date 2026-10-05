class_name UndyneProjectile
extends Area2D

# Dirección de viaje (debe venir ya normalizada). Normalmente apunta desde
# el spawner que lo creó hacia el centro de la arena (0, 0).
var direction: Vector2 = Vector2.ZERO
var speed: float = 220.0
var damage: int = 1

# Nombre del spawner que lo lanzó ("up"/"down"/"left"/"right"), solo a
# título informativo/depuración — el bloqueo no depende de esto.
var origin_direction: String = ""

# Si el proyectil se aleja más de esta distancia del centro sin haber sido
# bloqueado ni haber golpeado el alma, se considera "fallado" y se destruye,
# para que no se queden proyectiles viajando para siempre fuera de pantalla.
const DESPAWN_DISTANCE := 400.0

func _ready():
	monitoring = true
	monitorable = true
	area_entered.connect(_on_area_entered)

func _physics_process(delta):
	position += direction * speed * delta
	if position.length() > DESPAWN_DISTANCE:
		queue_free()

func _on_area_entered(area: Area2D):
	# --- DEBUG: esto te dice si el proyectil detecta ALGO al pasar, sea lo
	# que sea. Si nunca aparece nada de esto en consola, el problema es de
	# capas/máscaras de colisión, no de la lógica de bloqueo. Quita este
	# print cuando confirmes que ya funciona. ---
	print("UndyneProjectile(", origin_direction, ") tocó: ", area.name, " (", area.get_class(), ")")
	
	if area is UndyneBarrier:
		print("  -> era una barrera, se bloquea")
		queue_free()
	# El golpe contra el alma lo gestiona UndyneSoul (se destruye a sí misma
	# desde ahí), así que aquí no hace falta hacer nada más con ella.
