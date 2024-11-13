extends GeneralInteractionArea

func _start_battle():
	var dummy: Character = $"..".character
	var enemy_party = dummy.party
	# In this case this is the first time we talk with the dummy and the
	# party hasn't been filled
	if enemy_party.size == 1:
		var i = 0
		while i < 3:
			var d: Character = dummy.clone()
			d.combat_handler.stats.replenish()
			d.rpg_model.get_node("GeneralInteraction").disable
			d.disable_collisions()
			d.rpg_model.reposition(Vector2(0, 0), "down")
			enemy_party.add(d)
			i += 1
	enemy_party.members[1].combat_handler.stats.base_speed = 2
	enemy_party.members[1].combat_handler.stats.base_damage = 3
	enemy_party.members[2].combat_handler.stats.base_speed = 4
	enemy_party.members[2].combat_handler.stats.base_damage = 4
	enemy_party.members[3].combat_handler.stats.base_speed = 6
	enemy_party.members[3].combat_handler.stats.base_damage = 1
	ScreenManager.combat_screen.contents.start_battle(Player.party, enemy_party)
	print("Leaving start battle function")

# TODO: Temporary function that will be used to disable interactions on clones
# of the dummy.
func disable():
	$CollisionShape2D.disabled = true
