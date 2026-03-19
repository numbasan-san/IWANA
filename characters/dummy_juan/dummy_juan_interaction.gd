extends GeneralInteractionArea

var dummy_juan: Character
@export var test_quest: Array[Quest]

func _start_battle():
	
	print("Deberías tener una misión activada ahora.")

	if len(QuestsManager.active_quests) < 1:
		var test_pick = test_quest.pick_random()
		QuestsManager.add_quest(test_pick)
		test_quest.erase(test_pick)

	if dummy_juan:
		dummy_juan = $"..".character
		var own_done_quest = QuestsManager.own_quest_done(dummy_juan.char_info.person)
		if own_done_quest:
			QuestsManager.quest_done(own_done_quest)
		else:
			QuestsManager.talk_quest(dummy_juan.char_info.person)

func disable():
	$CollisionShape2D.disabled = true
