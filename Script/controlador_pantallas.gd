extends Node

class_name ControladorPantallas
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

# La pila de pantallas se usa para transicionar entre pantallas o para abrir
# menus sobre la pantalla actual. Solo la pantalla en el tope de la pila debe
# estar activa. Cuando se agrega otra pantalla, la pantalla actual debe
# desactivarse y la pantalla agregada debe activarse. Si la pantalla actual
# tiene definidas animaciones de entrada y salida, estas se reproducirán cuando
# la pantalla se agrega o se saca de la pila respectivamente
var stack_pantallas: Array[Pantalla]

# Esta variable siempre debe apuntar a la pantalla en el tope de la pila. Se usa
# para no tener que siempre ejecutar stack_pantallas[stack_pantallas.size()]
var pantalla_actual: Pantalla

# La pantalla del modo desarrollo, que permite ver información de las pantallas
# y cambiar entre ellas libremente
@export var pantalla_dev: Pantalla

# La primera pantalla, que contiene las imágenes del creador del juego y
# herramientas, si es que corresponde
@export var pantalla_intro: Pantalla

# Despues de la intro se llega a esta pantalla, donde se muestra un menú
# para iniciar juego nuevo, cargar un juego, etc.
@export var pantalla_menu_inicial: Pantalla

# La pantalla del modo rpg
@export var pantalla_mundo: Pantalla

# La pantalla del modo combate
@export var pantalla_combate: Pantalla

# La pantalla de dialogos. Hasta ahora, la seccion de dialogos funciona como en
# una novela visual, ocupando completamente la pantalla y deberia tener un
# fondo. Considerar si se debería tratar solo como un overlay, de manera que
# pueda superponerse sobre la pantalla rpg.
@export var pantalla_dialogo: Pantalla


# Called when the node enters the scene tree for the first time.
func _ready():
	# Cambiar esto para que no sea tan repetitivo y que funcione si queremos
	# más pantallas
	pantalla_menu_inicial.desactivar()
	pantalla_dialogo.desactivar()
	pantalla_mundo.desactivar()
	pantalla_dev.desactivar()
	pantalla_intro.desactivar()
	
	push(pantalla_intro)
	

# Se puede llamar a esta función para agregar a la pantalla al tope de la pila.
# Se asume que las pantallas anteriores van a seguir siendo visibles aunque
# estén cubiertas por pantallas nuevas. Idealmente godot sabrá ser eficiente y
# no las dibujará, lo que hace este código más simple. Si no es así, habría que
# esperar a que la animación termine antes de hacerlas invisibles, y habría que
# saber si la pantalla nueva es parcialmente transparente para saber si hay que
# ocultarlas o no
func push(pantalla_nueva: Pantalla):
	# La pantalla actual se desactiva pero se sigue mostrando, por lo que se
	# puede desactivar antes que esté lista la transición. Como la referencia a
	# la pantalla anterior ya no se necesita, pantalla actual ahora puede
	# apuntar a la nueva 
	if pantalla_actual:
		pantalla_actual.desactivar(true)
	stack_pantallas.push_back(pantalla_nueva)
	# Desde este punto pantalla_actual se refiere a la pantalla nueva
	pantalla_actual = pantalla_nueva
	# Se muestra la pantalla nueva para poder ver sus animaciones.
	# Notar que si la pantalla tiene una animación de transición, debe iniciar
	# estando oculta de alguna manera para que no cubra inmediatamente a la 
	# pantalla anterior
	pantalla_actual.activar()
	
	if pantalla_actual.transiciones and pantalla_actual.transiciones.has_animation("In"):
		# Se pausa la pantalla siguiente para que no reaccione a
		# inputs del usuario pero se siga viendo.
		pantalla_actual.desactivar(true)
		pantalla_actual.transiciones.play("In")
		await pantalla_actual.transiciones.animation_finished
		pantalla_actual.activar()

# Se puede llamar a esta función para sacar la pantalla del tope de la pila.
func pop():
	# Si la pantalla actual tiene transición, se debe esperar a que termine
	if pantalla_actual.transiciones and pantalla_actual.transiciones.has_animation("Out"):
		# Se pausa la pantalla actual para que no reaccione a
		# inputs del usuario pero siga mostrándose mientras se ejecuta la
		# transición
		pantalla_actual.desactivar(true)
		pantalla_actual.transiciones.play("Out")
		await pantalla_actual.transiciones.animation_finished
		
	# Si no, se cambia la pantalla activa inmediatamente
	# Solo al final de al animación se puede desactivar completamente
	# la pantalla actual
	pantalla_actual.desactivar()
	stack_pantallas.pop_back()
	# Y activar la pantalla siguiente. Ya era visible, así que esto solo
	# hace que funcionen los inputs
	pantalla_actual = stack_pantallas.back()
	pantalla_actual.activar()
