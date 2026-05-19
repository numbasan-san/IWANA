extends GeneralInteractionArea

var dummy: Character

func _start_battle():
	if !dummy:
		dummy = $"..".character
	var enemy_party = dummy.party
	# In this case this is the first time we talk with the dummy and the
	# party hasn't been filled
	if enemy_party.size == 1:
		var i = 0
		while i < 3:
			var d : Character = dummy.clone()
			d.combat_handler.stats.replenish()
			d.rpg_model.get_node("GeneralInteraction").disable
			d.disable_collisions()
			d.rpg_model.reposition(Vector2(0, 0), "down")
			enemy_party.add(d)
			i += 1
	enemy_party.members[1].combat_handler.stats.base_speed = 9
	enemy_party.members[1].combat_handler.stats.base_damage = 3
	enemy_party.members[2].combat_handler.stats.base_speed = 9
	enemy_party.members[2].combat_handler.stats.base_damage = 4
	enemy_party.members[3].combat_handler.stats.base_speed = 9
	enemy_party.members[3].combat_handler.stats.base_damage = 1
	if !ScreenManager.combat_screen.contents.battle_ended.is_connected(replenish):
		ScreenManager.combat_screen.contents.battle_ended.connect(replenish)
	ScreenManager.combat_screen.contents.battle(Player.party.members, enemy_party.members)
	print("Leaving start battle function")

func replenish():
	for m in dummy.party.members:
		m.combat_handler.stats.replenish()

# TODO: Temporary function that will be used to disable interactions on clones
# of the dummy.
func disable():
	$CollisionShape2D.disabled = true
