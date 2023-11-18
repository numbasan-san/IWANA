
extends Control

signal textbox_closed

var player = null
var retrato_player = null

var enemy = null

# Para cuando haya una defensa del jugador.
var defending = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$player_actions/attacks.hide()
	player = $player_actions/stats_screen.get_child(0)
	retrato_player = $retratos_player.get_child(0)
	enemy = $enemy_combat_container

	# Se cargan los stats y sprite del jugador.
	set_health(
		player.get_node("ProgressBar"), 
		player.stats.health, 
		player.stats.health,
		player.stats.name
	)
	player.get_node("retrato").texture = (
		player.stats.texture
	)
	player.get_node("etiqueta_nombre/Label").text = (
		str(player.stats.name)
	)
	retrato_player.get_node("retrato").texture = player.stats.retrato

	# Se cargan los stats y sprite del enemigo.
	set_health(
		enemy.get_node("ProgressBar"),
		enemy.stats.health,
		enemy.stats.health,
		enemy.stats.name
	)
	enemy.get_node('retrato').texture = enemy.stats.texture

	# Para verificar que los cuadros de texto estén cerrados.
	$text_box.hide()
	$player_actions.hide()

	# Cuadros de texto que avisan qué pasa.
	display_text('Un ' + enemy.stats.name + ' de prueba quiere pelear!')
	await(textbox_closed)

	$player_actions.show()

func _input(_event):
	# Para poder cerrar los cuadros de texto.
	if (Input.is_action_just_pressed("ui_accept") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)) and $text_box.visible:
		$text_box.hide()
		emit_signal("textbox_closed")

func _process(_delta):
	var end_game = false # Para cuando una de las partes está muerta.
	if enemy.stats.current_health <= 0: # Gana el jugador.
		display_text(enemy.stats.name + ' fue derrotado.')
		end_game = !end_game
	elif player.stats.current_health <= 0: # Gana el enemigo.
		display_text(enemy.stats.name + ' te derrotó.')
		end_game = !end_game
	
	if end_game:  # Cierre del combate.
		await(textbox_closed)
		await get_tree().create_timer(0.5).timeout
		await ScreenManager.pop(ScreenManager.combat_screen)
		

# Se establece la vida según qué barra de vida.
func set_health(progress_bar, health, max_health, current_character):
	progress_bar.value = health
	progress_bar.max_value = max_health
	progress_bar.get_node('Label').text = str(health) + "/" + str(max_health)

# Para mostrar el texto dentro de los cuadros de texto.
func display_text(text):
	$text_box.show()
	$text_box/label.text = text

# Para que el enemigo haga algo.
func enemy_turn():
	var final_damage = enemy.stats.damage

	if defending: # En caso de que el jugador se esté defendiendo.
		defending = false
		display_text('Te defiendes exitosamente.')
		final_damage = (final_damage / 2)
		await(textbox_closed)

	display_text(enemy.stats.name + ' te ataca por ' + str(final_damage) + '.')
	await(textbox_closed)

	# Animación para cuando se es herido.
	retrato_player.get_node("animation").play('hurt')
	await(retrato_player.get_node("animation").animation_finished)

	player.stats.current_health = (player.stats.current_health - final_damage)
	set_health(
		player.get_node("ProgressBar"), 
		player.stats.current_health, 
		player.stats.health,
		player.stats.name
	)

	$player_actions/attacks.hide()
	$player_actions/actions.show()

# Para terminar el combate por la fuerza.
func _on_run_pressed():
	display_text('Como buen cobarde, huiste.')
	await(textbox_closed)
	await get_tree().create_timer(0.5).timeout
	await ScreenManager.pop(ScreenManager.combat_screen)

# El ataque del jugador.
func _on_attack_pressed():
	$player_actions/actions.hide()
	$player_actions/attacks.show()

# La defensa del jugador.
func _on_defense_pressed():
	defending = true
	display_text('Aprietas los dientes.')
	await(textbox_closed)
	enemy_turn()

func _on_attack_1_pressed():
	var text = 'ataque 1'
	make_attack(text)

func _on_attack_2_pressed():
	var text = 'ataque 2'
	make_attack(text)

func _on_attack_3_pressed():
	var text = 'ataque 3'
	make_attack(text)

func _on_attack_4_pressed():
	var text = 'ataque 4'
	make_attack(text)


func make_attack(text):
	display_text('Atacas al ' + enemy.stats.name + ' por ' + str(player.stats.damage) + ' con el ' + text + '.')
	await(textbox_closed)

	# Se establece la vida que tendrá el enemigo después del ataque.
	enemy.stats.current_health = (
		enemy.stats.current_health - player.stats.damage
	)
	set_health(
		enemy.get_node("ProgressBar"),
		enemy.stats.current_health,
		enemy.stats.health,
		enemy.stats.name
	)

	# Animación para cuando se es herido.
	enemy.get_node("animation").play('hurt')
	await(enemy.get_node("animation").animation_finished)

	enemy_turn() # Turno enemigo.
