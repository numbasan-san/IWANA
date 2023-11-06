
extends Control

@export var player : Resource # El resource del jugador.
@export var enemy : Resource # El resource del enemigo.
signal textbox_closed

# La vida que tenga el personaje en turno.
var current_player_health = 0
var current_enemy_health = 0

# Para cuando haya una defensa del jugador.
var defending = false

# Called when the node enters the scene tree for the first time.
func _ready():
	# Se cargan los stats y sprite del jugador.
	set_health($player_container/ProgressBar, player.health, player.health, player.name)
	$player_container/TextureRect.texture = player.texture
	
	# Se cargan los stats y sprite del enemigo.
	set_health($enemy_container/ProgressBar, enemy.health, enemy.health, enemy.name)
	$enemy_container/TextureRect.texture = enemy.texture

	# Se establece la vida del enemigo y el jugador que tengan en el momento de iniciar el combate.
	current_player_health = player.health
	current_enemy_health = enemy.health

	# Para verificar que los cuadros de texto estén cerrados.
	$text_box.hide()
	$player_actions.hide()

	# Cuadros de texto que avisan qué pasa.
	display_text('Un ' + enemy.name + ' de prueba quiere pelear!')
	await(textbox_closed)
	$player_actions.show()

func _input(event):
	# Para poder cerrar los cuadros de texto.
	if (Input.is_action_just_pressed("ui_accept") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)) and $text_box.visible:
		$text_box.hide()
		emit_signal("textbox_closed")

func _process(delta):
	var end_game = false # Para cuando una de las partes está muerta.
	if current_enemy_health <= 0: # Gana el jugador.
		display_text(enemy.name + ' fue derrotado.')
		end_game = !end_game
	elif current_player_health <= 0: # Gana el enemigo.
		display_text(enemy.name + ' te derrotó.')
		end_game = !end_game
	
	if end_game:  # Cierre del combate.
		await(textbox_closed)
		await(get_tree().create_timer(0.5))
		get_tree().quit()
		

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
	display_text(enemy.name + ' te ataca.')
	await(textbox_closed)
	var final_damage = enemy.damage
	
	if defending: # En caso de que el jugador se esté defendiendo.
		defending = false
		display_text('Te defiendes exitosamente.')
		final_damage = (final_damage / 2)
		await(textbox_closed)
	
	''' Aquí debería ir una animación por el ataque, pero me da flojera  '''
	current_player_health = max(0, (current_player_health - final_damage))
	set_health($player_container/ProgressBar, current_player_health, player.health, player.name)

# Para terminar el combate por la fuerzza.
func _on_run_pressed():
	display_text('Como buen cobarde, huiste.')
	await(textbox_closed)
	await(get_tree().create_timer(0.5))
	get_tree().quit()

# El ataque del jugador.
func _on_attack_pressed():
	display_text('Atacas al ' + enemy.name + '.')
	await(textbox_closed)
	
	# Se establece la vida que tendrá el enemigo después del ataque.
	current_enemy_health = max(0, (current_enemy_health - player.damage))
	set_health($enemy_container/ProgressBar, current_enemy_health, enemy.health, enemy.name)
	
	''' Aquí debería ir una animación por el ataque, pero me da flojera  '''
	
	enemy_turn() # Turno enemigo.

# La defensa del jugador.
func _on_defense_pressed():
	defending = true
	display_text('Aprietas los dientes.')
	await(textbox_closed)
	enemy_turn()
