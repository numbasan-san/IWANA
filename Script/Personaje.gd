class_name Personaje extends Node

# TODO: cambiar esto por un sistema que no permita varios personajes controlados
# al mismo tiempo por el jugador
var control_jugador: bool = false

@onready var graficosNV = $GraficosNV
@onready var modeloMundo = $ModeloMundo
@onready var modeloCombate = $ModeloCombate

# Called when the node enters the scene tree for the first time.
func _ready():
	#modeloMundo.get_node("Cuerpo").personaje = self
	pass
