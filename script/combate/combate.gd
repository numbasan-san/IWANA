
extends Control

#@onready var player = $player_combat_container # El resource del jugador.
#@onready var enemy = $enemy_combat_container # El resource del enemigo.
signal textbox_closed

# La vida que tenga el personaje en turno.
var current_playerhealth = 0
var current_enemy_health = 0

# Para cuando haya una defensa del jugador.
var defending = false

# Called when the node enters the scene tree for the first time.
func _ready():
	# Se cargan los stats y sprite del jugador.
	set_health($player_combat_container/Panel/ProgressBar, $player_combat_container.stats.health, $player_combat_container.stats.health, $player_combat_container.stats.name)
	$player_combat_container/Panel/TextureRect.texture = $player_combat_container.stats.texture

	# Se cargan los stats y sprite del enemigo.
	set_health($enemy_combat_container/Panel/ProgressBar, $enemy_combat_container.stats.health, $enemy_combat_container.stats.health, $enemy_combat_container.stats.name)
	$enemy_combat_container/Panel/TextureRect.texture = $enemy_combat_container.stats.texture

	# Se establece la vida del enemigo y el jugador que tengan en el momento de iniciar el combate.
#	current_$player_combat_container_health = $player_combat_container.health
#	current_enemy_health = enemy.health

	# Para verificar que los cuadros de texto estén cerrados.
	$text_box.hide()
	$player_actions.hide()

	# Cuadros de texto que avisan qué pasa.
	display_text('Un ' + $enemy_combat_container.stats.name + ' de prueba quiere pelear!')
	await(textbox_closed)
	$player_actions.show()

func _input(_event):
	# Para poder cerrar los cuadros de texto.
	if (Input.is_action_just_pressed("ui_accept") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)) and $text_box.visible:
		$text_box.hide()
		emit_signal("textbox_closed")

func _process(_delta):
	var end_game = false # Para cuando una de las partes está muerta.
	if $enemy_combat_container.stats.current_health <= 0: # Gana el jugador.
		display_text($enemy_combat_container.stats.name + ' fue derrotado.')
		end_game = !end_game
	elif $player_combat_container.stats.current_health <= 0: # Gana el enemigo.
		display_text($enemy_combat_container.stats.name + ' te derrotó.')
		end_game = !end_game
	
	if end_game:  # Cierre del combate.
		await(textbox_closed)
		get_tree().create_timer(0.5)
		$/root/Juego.pantallas.pop($/root/Juego.pantallas.pantalla_combate)
		

# Se establece la vida según qué barra de vida.
func set_health(progress_bar, health, max_health, current_character):
	progress_bar.value = health
	progress_bar.max_value = max_health
	progress_bar.get_node('Label').text = current_character + ": " + str(health) + "/" + str(max_health)

# Para mostrar el texto dentro de los cuadros de texto.
func display_text(text):
	$text_box.show()
	$text_box/label.text = text

# Para que el enemigo haga algo.
func enemy_turn():
	var final_damage = $enemy_combat_container.stats.damage
	
	if defending: # En caso de que el jugador se esté defendiendo.
		defending = false
		display_text('Te defiendes exitosamente.')
		final_damage = (final_damage / 2)
		await(textbox_closed)
	
	display_text($enemy_combat_container.stats.name + ' te ataca por ' + str(final_damage) + '.')
	await(textbox_closed)
	''' Aquí debería ir una animación por el ataque, pero me da flojera  '''
	$player_combat_container.stats.current_health = ($player_combat_container.stats.current_health - final_damage)
	set_health($player_combat_container/Panel/ProgressBar, $player_combat_container.stats.current_health, $player_combat_container.stats.health, $player_combat_container.stats.name)
	

# Para terminar el combate por la fuerzza.
func _on_run_pressed():
	display_text('Como buen cobarde, huiste.')
	await(textbox_closed)
	get_tree().create_timer(0.5)
	$/root/Juego.pantallas.pop($/root/Juego.pantallas.pantalla_combate)

# El ataque del jugador.
func _on_attack_pressed():
	display_text('Atacas al ' + $enemy_combat_container.stats.name + ' por ' + str($player_combat_container.stats.damage) + '.')
	await(textbox_closed)
	
	# Se establece la vida que tendrá el enemigo después del ataque.
	$enemy_combat_container.stats.current_health = ($enemy_combat_container.stats.current_health - $player_combat_container.stats.damage)
	set_health($enemy_combat_container/Panel/ProgressBar, $enemy_combat_container.stats.current_health, $enemy_combat_container.stats.health, $enemy_combat_container.stats.name)
	
	''' Aquí debería ir una animación por el ataque, pero me da flojera  '''
	
	enemy_turn() # Turno enemigo.

# La defensa del jugador.
func _on_defense_pressed():
	defending = true
	display_text('Aprietas los dientes.')
	await(textbox_closed)
	enemy_turn()
