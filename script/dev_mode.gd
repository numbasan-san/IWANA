extends Pantalla

@export var todas_las_zonas: Array[String]
@export var zonas: MenuButton
@export var escenas: MenuButton
@export var unidades: MenuButton

@onready var mundo = $/root/Juego.pantallas.pantalla_mundo.get_node("Mundo")
@onready var controlador_guion: ControladorGuion = $/root/Juego/ControladorGuion
@onready var parser_guion: ParserGuion = $/root/Juego/ParserGuion

var habilitado = false

func _process(_delta):
	if habilitado:
		if $"/root/Juego".personajes.jugador and $"/root/Juego".personajes.jugador.zona:
			zonas.disabled = false
			zonas.text = $"/root/Juego".personajes.jugador.zona.name
		else:
			zonas.disabled = true
			zonas.text = "Ninguna"
		var escena_actual = controlador_guion.escena_actual
		if escena_actual:
			escenas.text = escena_actual.nombre
			if escena_actual.unidad_actual:
				unidades.text = escena_actual.unidad_actual.nombre
			else:
				unidades.text = "Ninguna"
		else:
			escenas.text = "Ninguna"
			unidades.text = "Ninguna"
			
	if $"/root/Juego".pantallas.pantalla_dialogo.visible:
		var linea = controlador_guion.escena_actual.unidad_actual.linea_actual
		$Contenidos/DetallesDialogo/Linea.text = str(linea)
		$Contenidos/DetallesDialogo.show()
	else:
		$Contenidos/DetallesDialogo.hide()

func habilitar():
	print("Dev Mode On")
	activar()
	habilitado = true
	rellenar_lista_zonas()
	rellenar_lista_escenas()
	# Esta función solo busca las unidades de la escena actual, así que siempre
	# es seguro llamarla
	rellenar_lista_unidades()

func rellenar_lista_zonas():
	if not habilitado:
		return
	var popup: PopupMenu = zonas.get_popup()
	popup.clear()
	popup.add_theme_font_size_override("font_size", 30)
	# Esta variable es necesaria porque varias funciones del popup necesitan el
	# indice, pero al agregar un item no entrega el indice asignado, por lo que
	# hay que asignarle un id manualmente y obtener el indice a traves de el
	var item_id = 0
	for nombre_zona in todas_las_zonas:
		var zona = $"/root/Juego".zonas.cargar(nombre_zona)
		popup.add_item(zona.name, item_id)
		var indice = popup.get_item_index(item_id)
		item_id += 1
		popup.set_item_metadata(indice, zona)
		
	# Para conectar la señal asumimos que no esta señal nunca va a ser conectada
	# a otra función fuera de este script. Si en algun momento eso cambia, hay
	# que arreglar este código
	if popup.index_pressed.get_connections().size() == 0:
		popup.index_pressed.connect(func (index) -> void:
			var zona = popup.get_item_metadata(index)
			var jugador = $"/root/Juego".personajes.jugador
			mundo.spawn(jugador, zona, "Default", "down", mundo.SpawnFallback.FIRST)
		)

func rellenar_lista_escenas():
	if not habilitado:
		return
	var popup: PopupMenu = escenas.get_popup()
	popup.clear()
	popup.add_theme_font_size_override("font_size", 30)
	# Esta variable es necesaria porque varias funciones del popup necesitan el
	# indice, pero al agregar un item no entrega el indice asignado, por lo que
	# hay que asignarle un id manualmente y obtener el indice a traves de el
	var item_id = 0
	for nombre_escena in controlador_guion.escenas:
		popup.add_item(nombre_escena, item_id)
		item_id += 1
		
	# Para conectar la señal asumimos que no esta señal nunca va a ser conectada
	# a otra función fuera de este script. Si en algun momento eso cambia, hay
	# que arreglar este código
	if popup.index_pressed.get_connections().size() == 0:
		popup.index_pressed.connect(func (index) -> void:
			var nombre_escena = popup.get_item_text(index)
			controlador_guion.cargar(nombre_escena)
			rellenar_lista_unidades()
		)

func rellenar_lista_unidades():
	if not habilitado:
		return
	var popup: PopupMenu = unidades.get_popup()
	popup.clear()
	popup.add_theme_font_size_override("font_size", 30)
	# Esta variable es necesaria porque varias funciones del popup necesitan el
	# indice, pero al agregar un item no entrega el indice asignado, por lo que
	# hay que asignarle un id manualmente y obtener el indice a traves de el
	var item_id = 0
	for nombre_unidad in controlador_guion.escena_actual.unidades:
		popup.add_item(nombre_unidad, item_id)
		var indice = popup.get_item_index(item_id)
		item_id += 1
		
	# Para conectar la señal asumimos que no esta señal nunca va a ser conectada
	# a otra función fuera de este script. Si en algun momento eso cambia, hay
	# que arreglar este código
	if popup.index_pressed.get_connections().size() == 0:
		popup.index_pressed.connect(func (index) -> void:
			var nombre_unidad = popup.get_item_text(index)
			controlador_guion.escena_actual.cargar(nombre_unidad)
		)

func _on_recargar_guion():
	parser_guion.parse_all()
	controlador_guion.reiniciar()
	
