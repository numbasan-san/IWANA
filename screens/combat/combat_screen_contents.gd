class_name CombatScreenControl
extends Control

signal textbox_closed
signal battle_ended
signal request_battle_end
signal action_selected(action: Action)
signal skill_selected(skill: Skill)
signal continue_round

@export var right_area: CombatPartyArea
@export var left_area: CombatPartyArea
@export var party_menu: PartyMenu
@export var skills_menu: SkillsMenu
@export var turn_handler: TurnHandler
@export var change_menu_animation: AnimationPlayer

# The turn order is decided at the beginning of the round according to the
# actors' speed stat and buffs. This is where they will be stored, and they
# will be removed as they perform their actions
var actor_queue: Array[Character]

var enemy_area: CombatPartyArea = null
var player_area: CombatPartyArea = null

## It should be true if the main loop of the combat controller is running.
var running: bool = false

var pause_before_round: bool = false

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
	turn_handler.combat = self

func _input(_event):
	# Para poder cerrar los cuadros de texto.
	if (Input.is_action_just_pressed("ui_accept") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)) and $text_box.visible:
		$text_box.hide()
		emit_signal("textbox_closed")

func battle(player_party: Array[Character], enemy_party: Array[Character]):
	running = true
	request_battle_end.connect(func():
		running = false
	, CONNECT_ONE_SHOT)
	await start_battle(player_party, enemy_party)
	# This loop controls the rounds. A round consists of 1 turn of each character.
	while running:
		if pause_before_round:
			await continue_round
		prepare_new_round()
		# This loop controls each turn. Because each turn could request the end
		# of battle, we must again check the running variable or else we would
		# have to wait for all turns in a round to pass before ending the battle.
		while(running and !actor_queue.is_empty()):
			await next_turn()
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
	turn_handler.right_area = right_area
	for member in player_party:
		party_menu.add_character(member)
		right_area.add_character(member)
		
	enemy_area = left_area
	enemy_area.player_controled = false
	turn_handler.left_area = left_area
	for enemy in enemy_party:
		left_area.add_character(enemy)
	await ScreenManager.push(ScreenManager.combat_screen, "Out", "In")
	
# Called at the end of the battle to clean the screen
func end_battle():
	await ScreenManager.pop(ScreenManager.combat_screen, "Out", "In")
	
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
		request_battle_end.emit()
		return
	
	else:
		# Pop should always return a result as if the queue is empty, the loop
		# will exit before calling this function and in the next loop the queue
		# will be repopulated.
		var next: Character = actor_queue.pop_front() as Character
		next.combat_handler.start_turn()
		# If the next character fainted due to an effect in the previous turn
		# or at the star of its turn, we skip this turn. We don't apply end of
		# turn effects.
		if next.combat_handler.stats.unconscious:
			return
		if next.combat_handler.incapacitated:
			next.combat_handler.end_turn()
			return
		
		# If we reach this point, we can run the character's turn and hand the
		# execution to the selection module, which will be stuck in its loop
		# until the character's turn ends, be it by defending or using a skill.
		await turn_handler.run_turn(next)
		
		# After run_turn returns, we are guaranteed that the character's turn
		# has ended
		next.combat_handler.end_turn()

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

func _focus_action_list():
	$PartyMenu/Actions/ActionList/Attack.grab_focus()

# Para mostrar el texto dentro de los cuadros de texto.
func display_text(text):
	$text_box.show()
	$text_box/label.text = text
