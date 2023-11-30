class_name CombatControl
extends Control

signal textbox_closed

@export var player_area: CombatPartyArea
@export var enemy_area: CombatPartyArea
@export var party_menu: PartyMenu
@export var skills_menu: SkillsMenu
@export var change_menu_animation: AnimationPlayer

# When one picks an action (using skill, defending, fleeing, etc), it is stored
# here as a callable so one can proceed with the rest of the members. After
# an action has been chosen for everyone, the queue is read and all actions are
# performed sequentially.
# TODO: we have to decide if enemy actions are going to be queued when one is
# choosing the player actions, according to their speed, or after all player
# actions have been chosen the enemy actions are going to be inserted inbetween.
var action_queue: Array[CombatAction]

# TODO: change this so that there is a party of enemies
var enemy: Character = null

var showing_skills = false

var player = null
var retrato_player = null


# Para cuando haya una defensa del jugador.
var defending = false

func _input(_event):
	# Para poder cerrar los cuadros de texto.
	if (Input.is_action_just_pressed("ui_accept") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)) and $text_box.visible:
		$text_box.hide()
		emit_signal("textbox_closed")
	if Input.is_action_just_released("combat_menu_back"):
		if skills_menu.visible:
			show_party_menu()
		else:
			party_menu.select_previous_character()
	# For now, combat_menu_forward is used when we have deselected the characters,
	# so we can select the first one again
	if Input.is_action_just_released("combat_menu_forward") \
			and not party_menu.selected_character:
		party_menu.select_next_character()

# Fills the screen with the battling characters and their info and begins combat
# TODO: For now it only receives one enemy the characters will battle. It has to
# be changed later to accept a party of enemies, when that is implemented.
func start_battle(enemy: Character):
	for member in Player.party:
		party_menu.add_character(member)
		player_area.add_character(member)
	party_menu.select_character(0)
	enemy_area.add_character(enemy)
	self.enemy = enemy
	await ScreenManager.push(ScreenManager.combat_screen)

# Called at the end of the battle to clean the screen
func end_battle():
	await ScreenManager.pop(ScreenManager.combat_screen)
	party_menu.clear()
	player_area.clear()
	enemy_area.clear()
	#TODO: replace this with more permanent solution to rebattle
	enemy.stats.replenish()

# Shows the party menu and hides the skills menu
func show_party_menu():
	if not party_menu.visible:
		change_menu_animation.play("HideSkills")

# Shows the skills menu and hides the party menu
func show_skills_menu():
	if party_menu.visible:
		change_menu_animation.play("ShowSkills")

# After all actions have been chosen, perform them
func action_phase():
	# Just for testing, we add the enemy actions here
	# Always attacks the first character, we assume that it is there
	var enemy_action = CombatAction.new(enemy.skills[0], enemy, player_area.characters[0])
	action_queue.append(enemy_action)
	action_queue.sort_custom(func(a, b): b.order < a.order)
	for action in action_queue:
		action.execute()
	action_queue.clear()
	if enemy.stats.health <= 0:
		end_battle()
	

# Para mostrar el texto dentro de los cuadros de texto.
func display_text(text):
	$text_box.show()
	$text_box/label.text = text


# Para terminar el combate por la fuerza.
func _on_run_pressed():
	display_text('Como buen cobarde, huiste.')
	await(textbox_closed)
	await get_tree().create_timer(0.5).timeout
	end_battle()

# El ataque del jugador.
func _on_attack_pressed():
	skills_menu.set_to_character(party_menu.selected_character)
	show_skills_menu()

# La defensa del jugador.
func _on_defense_pressed():
	defending = true
	display_text('Aprietas los dientes.')
	await(textbox_closed)
