# res://script/quests/quest.gd
class_name Quest extends Resource

@export_category("Description")
@export var name: String
@export_multiline var description: String
@export var brief_description: String

@export_category("Quest Process")
@export var quantity_collected := 0
@export var quantity_goal := 0
@export var quest_status : String
@export var quest_type : QuestsManager.QuestType
@export var quest_item : QuestsManager.ITEM
@export var quest_person : QuestsManager.PERSON

@export_category("Quest Completion")
@export var to: QuestsManager.PERSON

func get_brief_description():
	var quest_state = str(quantity_collected) + "/" + str(quantity_goal)
	return _get_wanted_condition_string() + " " + _get_quest_target_string() + " " + quest_state

func _get_wanted_condition_string():
	match quest_type:
		QuestsManager.QuestType.COLLECT:
			return "Collect"
		QuestsManager.QuestType.TALK:
			return "Talk with"

func _get_quest_target_string():
	match quest_type:
		QuestsManager.QuestType.COLLECT:
			return QuestsManager.ITEM.keys()[quest_item].capitalize()
		QuestsManager.QuestType.TALK:
			return QuestsManager.PERSON.keys()[quest_person].capitalize()

func get_quest_target():
	match quest_type:
		QuestsManager.QuestType.COLLECT:
			return quest_item
		QuestsManager.QuestType.TALK:
			return quest_person

