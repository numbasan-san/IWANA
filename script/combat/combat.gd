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

var enemy_party: Party = null

var showing_skills = false

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
func start_battle(enemy_party: Party):
	for member in Player.party.members:
		party_menu.add_character(member)
		player_area.add_character(member)
	party_menu.select_character(0)
	for enemy in enemy_party.members:
		enemy_area.add_character(enemy)
	self.enemy_party = enemy_party
	show_party_menu()
	await ScreenManager.push(ScreenManager.combat_screen, "Out", "In")
	$PartyMenu/Actions/Attack.grab_focus()

# Called at the end of the battle to clean the screen
func end_battle():
	await ScreenManager.pop(ScreenManager.combat_screen, "Out", "In")
	party_menu.clear()
	player_area.clear()
	enemy_area.clear()
	#TODO: replace this with more permanent solution to rebattle
	enemy_party.members[0].stats.replenish()
	enemy_party = null

# Shows the party menu and hides the skills menu
func show_party_menu():
	if not party_menu.visible:
		change_menu_animation.play("HideSkills")
		await change_menu_animation.animation_finished
		if party_menu.selected_character:
			# TODO: change it so that we don't need to refer to the button
			# directly
			$PartyMenu/Actions/Attack.grab_focus()

# Shows the skills menu and hides the party menu
func show_skills_menu():
	if party_menu.visible:
		change_menu_animation.play("ShowSkills")
		await change_menu_animation.animation_finished
		if skills_menu.skills_container.get_child_count() > 0:
			skills_menu.skills_container.get_child(0).grab_focus()

# After all actions have been chosen, perform them
func action_phase():
	# Just for testing, we add the enemy actions here
	# Always attacks the first character, we assume that it is there
	for enemy in enemy_party.members:
		var enemy_action = CombatAction.new(enemy.skills[0], enemy, player_area.characters[0])
		action_queue.append(enemy_action)
	action_queue.sort_custom(func(a, b): b.order < a.order)
	for action in action_queue:
		action.execute()
	action_queue.clear()
	for enemy in enemy_party.members:
		if enemy.stats.health <= 0 and enemy_area.has(enemy):
			enemy_area.remove_character(enemy)
	if enemy_area.is_empty():
		end_battle()
	else:
		party_menu.select_character(0)
		# TODO: change it so that we don't need to refer to the button
		# directly
		$PartyMenu/Actions/Attack.grab_focus()
	

# Para mostrar el texto dentro de los cuadros de texto.
func display_text(text):
	$text_box.show()
	$text_box/label.text = text

