class_name CombatControl
extends Control

signal textbox_closed

@export var right_area: CombatPartyArea
@export var left_area: CombatPartyArea
@export var party_menu: PartyMenu
@export var skills_menu: SkillsMenu
@export var change_menu_animation: AnimationPlayer

# The turn order is decided at the beginning of the round according to the
# actors' speed stat and buffs. This is where they will be stored, and they
# will be removed as they perform their actions
var actor_queue: Array[Character]

# The party on the left side of the screen generally is the party of the enemies
var left_party: Party = null
# The party on the right side of the screen generally is the party of the player
var right_party: Party = null

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
# TODO: change to receive both parties, so that we aren't restricted
# to only using the player's party
func start_battle(player_party: Party, enemy_party: Party):
	for member in player_party.members:
		party_menu.add_character(member)
		right_area.add_character(member)
	# We start with no character selected in case one
	# of the enemies attacks first
	party_menu.select_character_index()
	self.right_party = player_party
	for enemy in enemy_party.members:
		left_area.add_character(enemy)
	self.left_party = enemy_party
	await ScreenManager.push(ScreenManager.combat_screen, "Out", "In")
	show_party_menu()
	prepare_new_round()
	next_turn()

# Called at the end of the battle to clean the screen
func end_battle():
	await ScreenManager.pop(ScreenManager.combat_screen, "Out", "In")
	party_menu.clear()
	right_area.clear()
	left_area.clear()
	#TODO: replace this with more permanent solution to rebattle
	left_party.members[0].stats.replenish()
	left_party = null
	right_party = null
	actor_queue.clear()

# This function should be called at the start of the combat or after
# everyone has acted to sort every character's turn for the next round
func prepare_new_round():
	for character in left_area.characters:
		actor_queue.append(character)
	for character in right_area.characters:
		actor_queue.append(character)
	actor_queue.sort_custom(func(a: Character, b: Character):
		return a.stats.speed > b.stats.speed)
	# We only call this to do clean up in case it wasn't called
	# when appropiate
	remove_dead()
	
func next_turn():
	# We check here if one party has been defeated and end the battle to fix
	# a bug that could happen when ending the battle in the code for a skill 
	# button of a player character before it can call scene animations, which
	# would cause it to call next_turn on the next battle
	if left_area.is_empty() or right_area.is_empty():
		end_battle()
	
	elif actor_queue.is_empty():
		prepare_new_round()
		next_turn()
	else:
		var next: Character = actor_queue.pop_front()
		# If the next character is in the player's party, we allow the player
		# to pick an action
		# We check in the party variable of Player and not in the party menu
		# in the battle screen in case both battling parties are controled by
		# the computer
		if Player.party.has(next):
			party_menu.select_character(next)
			_focus_action_list()
		else:
			var target: Character = null
			if left_party.has(next):
				target = right_party.members[0]
			else:
				target = left_party.members[0]
			var action = CombatAction.new(next.skills[0], next, target)
			action.execute()
			remove_dead()
			next_turn()

# Shows the party menu and hides the skills menu
func show_party_menu():
	if not party_menu.visible:
		change_menu_animation.play("HideSkills")
		await change_menu_animation.animation_finished
		if party_menu.selected_character:
			# TODO: change it so that we don't need to refer to the button
			# directly
			_focus_action_list()

# Shows the skills menu and hides the party menu
func show_skills_menu():
	if party_menu.visible:
		change_menu_animation.play("ShowSkills")
		await change_menu_animation.animation_finished
		if skills_menu.skills_container.get_child_count() > 0:
			skills_menu.skills_container.get_child(0).grab_focus()

# This function should be called at the end of each turn to remove
# all characters that have died from the combat area
func remove_dead():
	for char in left_party.members:
		if char.stats.health <= 0:
			# We put this here in case we accidentaly add an actor that was
			# already removed from the area to the queue 
			actor_queue.remove_at(actor_queue.find(char))
			if left_area.has(char):
				left_area.remove_character(char)
	for char in right_party.members:
		if char.stats.health <= 0:
			actor_queue.remove_at(actor_queue.find(char))
			if right_area.has(char):
				right_area.remove_character(char)

func _focus_action_list():
	$PartyMenu/Actions/ActionList/Attack.grab_focus()

# Para mostrar el texto dentro de los cuadros de texto.
func display_text(text):
	$text_box.show()
	$text_box/label.text = text

