class_name CombatScreenControl
extends Control

signal textbox_closed
signal battle_ended
signal request_battle_end
signal action_selected(action: Action)
signal skill_selected(skill: Skill)

@export var right_area: CombatPartyArea
@export var left_area: CombatPartyArea
@export var party_menu: PartyMenu
@export var skills_menu: SkillsMenu
@export var selection_module: SelectionModule
@export var change_menu_animation: AnimationPlayer

# The turn order is decided at the beginning of the round according to the
# actors' speed stat and buffs. This is where they will be stored, and they
# will be removed as they perform their actions
var actor_queue: Array[Character]

var enemy_area: CombatPartyArea = null
var player_area: CombatPartyArea = null

var showing_skills = false

var selecting_action = false
var selecting_skill = false
var selecting_target = false

enum Action {
	NONE,
	ATTACK,
	DEFEND,
	RUN
}

enum State {
	SELECTING_ACTION, # The character is deciding to attack, defend or run.
	SELECTING_SKILL, # The character is selecting a skill to use.
	FILLING_DATA, # The character is selecting targets, effects and evaluating conditions.
	EXECUTING, # The skill has been processed and can now be applied.
	END # The process for the current character has stopped and a new character must be chosen.
}

func _ready():
	left_area.combat = self
	right_area.combat = self
	selection_module.combat = self

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

func battle(player_party: Array[Character], enemy_party: Array[Character]):
	var running = false
	request_battle_end.connect(func():
		running = false
	, CONNECT_ONE_SHOT)
	start_battle(player_party, enemy_party)
	while(running):
		pass
	end_battle()

# Fills the screen with the battling characters and their info and begins combat
func start_battle(player_party: Array[Character], enemy_party: Array[Character]):
	# This is here to fix a bug where the menus of the combat screen would move
	# out of their default place sometimes after opening the editor
	change_menu_animation.play("RESET")
	# TODO: change this so that we can control which area corresponds with which
	# party
	player_area = right_area
	player_area.player_controled = true
	selection_module.right_area = right_area
	for member in player_party:
		party_menu.add_character(member)
		right_area.add_character(member)
	# We start with no character selected in case one
	# of the enemies attacks first
	party_menu.select_character_index()
	
	enemy_area = left_area
	enemy_area.player_controled = false
	selection_module.left_area = left_area
	for enemy in enemy_party:
		left_area.add_character(enemy)
	await ScreenManager.push(ScreenManager.combat_screen, "Out", "In")
	
	show_party_menu()
	prepare_new_round()
	next_turn()

# Called at the end of the battle to clean the screen
func end_battle():
	await ScreenManager.pop(ScreenManager.combat_screen, "Out", "In")
	#TODO: replace this with more permanent solution to rebattle
	# This assumes that the enemies are in the left area.
	for m in left_area.characters:
		m.combat_handler.stats.replenish()
	party_menu.clear()
	right_area.clear()
	left_area.clear()
	
	actor_queue.clear()
	battle_ended.emit()

# This function should be called at the start of the combat or after
# everyone has acted to sort every character's turn for the next round
func prepare_new_round():
	for character in left_area.characters:
		if not character.combat_handler.stats.unconscious:
			actor_queue.append(character)
	for character in right_area.characters:
		if not character.combat_handler.stats.unconscious:
			actor_queue.append(character)
	_reorder_queue()
	
func next_turn():
	# We check here if one party has been defeated and end the battle to fix
	# a bug that could happen when ending the battle in the code for a skill 
	# button of a player character before it can call scene animations, which
	# would cause it to call next_turn on the next battle
	if left_area.all_defeated() or right_area.all_defeated():
		# request_battle_end.emit()
		end_battle()
	
	elif actor_queue.is_empty():
		prepare_new_round()
		next_turn()
	else:
		var next: Character = actor_queue.pop_front() as Character
		next.combat_handler.start_turn()
		# If the next character fainted due to an effect in the previous turn
		# or at the star of its turn, we skip this turn
		if next.combat_handler.stats.unconscious:
			next_turn()
		if next.combat_handler.incapacitated:
			next.combat_handler.end_turn()
			next_turn()
			
		# If the next character is in the player's party, we allow the player
		# to pick an action
		# We check in the party variable of Player and not in the party menu
		# in the battle screen in case both battling parties are controled by
		# the computer
		elif Player.party.has(next):
			party_menu.select_character(next)
			_focus_action_list()
		else:
			var handler = next.combat_handler
			var available_skills: Array[Skill] = handler.skills.filter(func(skill):
				return skill.enabled)
			if available_skills.size() > 0:
				var skill: Skill = available_skills.pick_random()
				handler.last_skill = skill
				for eff in skill.effects:
					if eff.target_type.is_manual_target():
						var t_type = eff.target_type as TargetVariable
						t_type.random = true
				skill.process_effects(left_area.characters, right_area.characters, [])
				await handler.execute(skill)
			next.combat_handler.end_turn()
			next_turn()

# Reorder the actor queue in response of the speed of a character changing
func _reorder_from_speed_change(old, new):
	# We ignore the arguments. This is only required because the speed change
	# signal calls functions with 2 parameters
	_reorder_queue()

# Called when the actor queue must be reordered
func _reorder_queue():
	actor_queue.sort_custom(func(a: Character, b: Character):
		var a_handler = a.combat_handler
		var b_handler = b.combat_handler
		return a_handler.stats.speed > b_handler.stats.speed)

# Shows the party menu and hides the skills menu
func show_party_menu():
	if not party_menu.visible:
		skills_menu.hide_targets()
		change_menu_animation.play("HideSkills")
		await change_menu_animation.animation_finished
		# TODO: think of a better way to control in which state is the combat
		# screen
		selecting_action = true
		selecting_skill = false
		selecting_target = false
		if party_menu.selected_character:
			# TODO: change it so that we don't need to refer to the button
			# directly
			_focus_action_list()

# Shows the skills menu and hides the party menu
func show_skills_menu():
	if party_menu.visible:
		change_menu_animation.play("ShowSkills")
		await change_menu_animation.animation_finished
		selecting_action = false
		selecting_skill = true
		selecting_target = false
		if skills_menu.skills_container.get_child_count() > 0:
			skills_menu.skills_container.get_child(0).grab_focus()

func _focus_action_list():
	$PartyMenu/Actions/ActionList/Attack.grab_focus()

# Para mostrar el texto dentro de los cuadros de texto.
func display_text(text):
	$text_box.show()
	$text_box/label.text = text
