extends Control

enum Posicion { IZQUIERDA, CENTRO, DERECHA }

@export var ruta_fondos: String

@onready var fondo: TextureRect = $EscenaNV/Fondo
@onready var areaPersonajes = $EscenaNV/AreaPersonajes
@onready var areaIzquierda: Control = areaPersonajes.get_node("Izquierda")
@onready var areaCentro: Control = areaPersonajes.get_node("Centro")
@onready var areaDerecha: Control = areaPersonajes.get_node("Derecha")

@onready var label_nombre = $"CuadroDiálogo/PanelNombre/LabelNombre"
@onready var label_texto = $"CuadroDiálogo/Texto"


# Agrega el grafico asociado a un personaje a la izquierda, centro o derecha
# del area de personajes.
# Si el personaje ya había sido agregado en ese lado, no hace nada
# Si el personaje ya había sido agregado en otro lado, lo cambia de lugar
func agregarPersonaje(personaje, pos: Posicion):
	var grafico: Node2D = personaje.modeloDialogo
	
	# Si el personaje no tiene un gráfico de diálogo, en general porque no debe
	# aparecer en diálogos, no se hace nada
	if not grafico:
		return
	
	# Considerar mover el gráfico sin duplicarlo
	var copiaGrafico = grafico.duplicate() as Node2D
	
	# Si el personaje ya ha sido agregado, solo uno de estas 3 variables debe
	# ser distinta de null
	var graficoIzquierda = areaIzquierda.find_child(grafico.name)
	var graficoCentro = areaCentro.find_child(grafico.name)
	var graficoDerecha = areaDerecha.find_child(grafico.name)
	
	# TODO: agregar código para manejar transiciones
	match pos:
		Posicion.IZQUIERDA:
			if graficoCentro:
				areaCentro.remove_child(graficoCentro)
			if graficoDerecha:
				areaDerecha.remove_child(graficoDerecha)
			if not graficoIzquierda:
				copiaGrafico.show()
				copiaGrafico.mirarDerecha()
				areaIzquierda.add_child(copiaGrafico)
				copiaGrafico.position.x = 2 * areaIzquierda.size.x / 3
				copiaGrafico.position.y = areaIzquierda.size.y
		Posicion.CENTRO:
			if graficoIzquierda:
				areaIzquierda.remove_child(graficoIzquierda)
			if graficoDerecha:
				areaDerecha.remove_child(graficoDerecha)
			if not graficoCentro:
				copiaGrafico.show()
				copiaGrafico.mirarDerecha()
				areaCentro.add_child(copiaGrafico)
				copiaGrafico.position.x = areaIzquierda.size.x / 2
				copiaGrafico.position.y = areaIzquierda.size.y
		Posicion.DERECHA:
			if graficoIzquierda:
				areaIzquierda.remove_child(graficoIzquierda)
			if graficoCentro:
				areaCentro.remove_child(graficoCentro)
			if not graficoDerecha:
				copiaGrafico.show()
				copiaGrafico.mirarIzquierda()
				areaDerecha.add_child(copiaGrafico)
				copiaGrafico.position.x = areaIzquierda.size.x / 3
				copiaGrafico.position.y = areaIzquierda.size.y

# Elimina el grafico asociado a un personaje, si es que ya está en el area de
# personajes
func quitarPersonaje(personaje):
	var grafico: Node2D = personaje.get_node("GraficoNV")
	if not grafico:
		return
		
	var graficoEncontrado = areaPersonajes.find_child(grafico.name)
	if not graficoEncontrado:
		return
	
	graficoEncontrado.get_parent().remove_child(graficoEncontrado)

func cambiar_fondo(imagen: String):
	if not imagen:
		fondo.hide()
	
	# Si el nombre de imagen no tiene extensión, asumimos que se desea un png
	if not imagen.get_extension():
		imagen = imagen + ".png"
	var ruta = "res://".path_join(ruta_fondos).path_join(imagen)
	fondo.texture = load(ruta)
	fondo.show()

func cambiar_dialogo(texto: String, nombre: String = ""):
	label_nombre.text = nombre
	label_texto.text = texto
