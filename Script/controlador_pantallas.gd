extends Node

# Controla la transición entre pantallas y menus.
# Solo una pantalla puede estar activa en cada momento, otras deben estar 
# pausadas o cerradas.
# Si una pantalla está cerrada, debe tener un sistema que pueda guardar y
# restaurar su estado.
# Un menú puede estar activo sobre una pantalla, la cual quedará parcialmente
# cubierta y en pausa.

# TODO: cambiar el sistema de transiciones. ¿Cada pantalla controla
# sus propias transiciones o se controlan en un diccionario aca? ¿Tienen que tener
# una estructura estandar para que se pueda cambiar las transiciones sin saber
# lo específico de cada elemento, pero de cualquier manera funcione?

# La pantalla del modo desarrollo, que permite ver información de las pantallas
# y cambiair entre ellas libremente
@onready var pantallaDev = $"../DevMode"

# La primera pantalla, que contiene las imágenes del creador del juego y
# herramientas, si es que corresponde
@onready var pantallaIntro = $"../PantallaIntro"

# Despues de la intro se llega a esta pantalla, donde se muestra un menú
# para iniciar juego nuevo, cargar un juego, etc.
@onready var pantallaMenuInicial = $"../PantallaMenuInicial"

# La pantalla del modo rpg
@onready var pantallaMundo = $"../PantallaMundo"

# La pantalla de dialogos. Hasta ahora, la seccion de dialogos funciona como en
# una novela visual, ocupando completamente la pantalla y deberia tener un
# fondo. Considerar si se debería tratar solo como un overlay, de manera que
# pueda superponerse sobre la pantalla rpg.
@onready var pantallaDialogo = $"../PantallaDialogo"

# La pantalla visible en este momento. 
@onready var pantallaActual = pantallaIntro

# Called when the node enters the scene tree for the first time.
func _ready():
	# Cambiar esto para que no sea tan repetitivo y que funcione si queremos
	# más pantallas
	pantallaMenuInicial.process_mode = Node.PROCESS_MODE_DISABLED
	pantallaDialogo.process_mode = Node.PROCESS_MODE_DISABLED
	pantallaMundo.process_mode = Node.PROCESS_MODE_DISABLED
	
	pantallaActual.show()
	var anim: AnimationPlayer = pantallaActual.find_child("FadeAnimator", true)
	anim.play("Fade")
	anim.animation_finished.connect(func (_anim_name) -> void:
		pantallaActual.hide()
		pantallaActual.process_mode = Node.PROCESS_MODE_DISABLED
		pantallaActual = pantallaMenuInicial
		pantallaActual.process_mode = Node.PROCESS_MODE_INHERIT
		var animator = pantallaActual.find_child("FadeAnimator", true)
		pantallaActual.show()
		animator.play("FadeIn")
	)
	

# Un script externo puede llamar a esta función pasando como argumento la
# pantalla a la que desea cambiar.
func transicion(pantalla):
	var anim: AnimationPlayer = pantallaActual.find_child("FadeAnimator", true)
	anim.play("FadeOut")
	if $"../DevMode".activado:
		pantallaDev.hide()
	anim.animation_finished.connect(func (_anim_name) -> void:
		pantallaActual.hide()
		pantallaActual.process_mode = Node.PROCESS_MODE_DISABLED
		pantallaActual = pantalla
		pantallaActual.process_mode = Node.PROCESS_MODE_INHERIT
		anim = pantallaActual.find_child("FadeAnimator", true)
		anim.play("FadeIn")
		pantallaActual.show()
		if $"../DevMode".activado:
			pantallaDev.show()
	)
