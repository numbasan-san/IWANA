class_name DevCombatMode extends Control

@export var left_control: DevAreaControl
@export var right_control: DevAreaControl

var combat: CombatScreenControl:
	set(value):
		combat = value
		left_control.combat_area = combat.left_area
		right_control.combat_area = combat.right_area

var enabled: bool = false

func enable():
	if !enabled:
		enabled = true
		combat = ScreenManager.combat_screen.contents as CombatScreenControl
		var fill_battle_characters = func():
			for char in combat.left_area.characters:
				var container = combat.left_area.find(char)
				var coords = combat.left_area.combat_grid.contents.find_key(container)
				left_control._add_character_at(char, coords)
			for char in combat.right_area.characters:
				var container = combat.right_area.find(char)
				var coords = combat.right_area.combat_grid.contents.find_key(container)
				right_control._add_character_at(char, coords)
				
		combat.battle_started.connect(fill_battle_characters)
		# This is to fill the characters when this control is enabled after a
		# battle hash already started
		if combat.running:
			fill_battle_characters.call()
		_sync_area_controls()

func _new_battle():
	# If we are already fighting, this stops that battle before starting a new one.
	# TODO: for now, this only makes a request, so if a character's turn is still
	# playing this will wait for it to end. If the character is being controled
	# by the player, this requires us to select a skill to finish. We should
	# change it so that either it immediately interrupts any movement, or if it is
	# manually controlled we skip any remaining actions.
	combat.request_battle_end.emit()
	# This starts a battle with no characters on any side. We pause the combat
	# before the first round because only when the first turn starts we check if
	# there is any conscious character on a team and end the battle, so this allows
	# us to have an empty field to play around in.
	combat.pause_before_round = true
	combat.battle([], [])
	

func _add_character_left(character: Character):
	if combat.left_area:
		pass

func _sync_combat_pause(paused: bool):
	combat.pause_before_round = paused

func _continue_combat():
	combat.continue_round.emit()

# We call this once to adjust the grid overlays to the actual combat areas so
# they have the same initial size, and so we can alter the overlays to change the
# shape of the areas.
func _sync_area_controls():
	left_control.grid_overlay._sync_area_controls()
	right_control.grid_overlay._sync_area_controls()
