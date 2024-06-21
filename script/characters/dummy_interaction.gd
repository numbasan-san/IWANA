extends GeneralInteractionArea

func _ready():
	if not ScriptManager.chain_ended.is_connected(_start_after_dialog):
		ScriptManager.chain_ended.connect(_start_after_dialog)

func interaction(_player: PlayerControl):
	# If this character has a dialogo unit asociated, we will wait for it to
	# finish talking
	if $"..".character.dialog_unit:
		# TODO: this assumes that there is a unit in the current scene with the
		# given name. If the scene has changed this will fail, but a better
		# outcome would it be that after setting the dialog in a scene, it stays
		# the same across different scenes unless changed later. To do this we
		# would have to refer to units in different scenes or store units and
		# their links in a different class that can be then passed to the
		# manager to execute
		ScriptManager.current_scene.load($"..".character.dialog_unit)
	else:
		_start_battle()

func _start_after_dialog(scene_name: String, unit_name: String):
	if unit_name == $"..".character.dialog_unit:
		_start_battle()
		
func _start_battle():
	var enemy_party = Party.new(4)
	var dummy: Character = $"..".character
	enemy_party.add(dummy)
	var i = 0
	while i < 3:
		var d: Character = dummy.duplicate()
		d.stats = dummy.stats.duplicate()
		d.stats.replenish()
		enemy_party.add(d)
		i += 1
	enemy_party.members[1].stats.base_speed = 2
	enemy_party.members[2].stats.base_speed = 4
	enemy_party.members[3].stats.base_speed = 6
	ScreenManager.combat_screen.contents.start_battle(Player.party, enemy_party)
