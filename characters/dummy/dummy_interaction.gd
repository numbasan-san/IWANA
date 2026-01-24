extends GeneralInteractionArea

var dummy: Character

func _start_battle():
	if !dummy:
		dummy = $"..".character
	var enemy_party = dummy.party
	replenish()
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
