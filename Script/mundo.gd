extends Node2D


func _ready():
	pass
	# TODO: cambiar esto por un sistema que no permita varios personajes controlados
	# al mismo tiempo por el jugador
	#p.control_jugador = true
	# root.cargar(p)
	#var z = root.cargarZona("sala_p1n1") as Zona
	#var z = $Escuela/SalaP1N1 as Zona
	#root.cargar(z)
	#add_child(z)
	#moverPersonajeAZona(p, z, Vector2(200, 80), "d")

# Remueve el personaje de la zona en la que está actualmente y lo coloca
# en la zona nueva
func recolocar_personaje(
		personaje: Personaje,
		zona: Zona,
		posicion: Vector2 = Vector2(0, 0),
		direccion: String = 'd'):
	
	# Si el personaje está controlado por el jugador, la zona en la que está
	# es la zona hija del nodo mundo, y hay que cambiarla
	if personaje.control_jugador:
		
		# Si Mundo tiene una zona hija, y esta es distinta a la nueva zona,
		# Debe removerse y devolverse al contenedor Zonas
		if (get_child_count() > 0) and (get_child(0) != zona):
			var zona_actual = get_child(0)
			zona_actual.desactivar()
			remove_child(zona_actual)
			$/root/Juego/Zonas.add_child(zona_actual)
		
		# Si Mundo no tiene hijos o tiene pero es distinto a la zona nueva,
		# esta se debe sacar del contenedor Zonas
		if get_child_count() == 0 or get_child(0) != zona:
			$/root/Juego/Zonas.remove_child(zona)
			add_child(zona)
			zona.activar()
		
		# Si no, se está moviendo al personaje dentro
		# de la misma zona, no hay que cambiar nada
		
	# En cualquier caso, el personaje debe recolocarse
	personaje.recolocar(zona, posicion, direccion)
	
	
