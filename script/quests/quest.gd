# res://script/quests/quest.gd
class_name Quest extends Resource

@export_category("Description")
@export var name: String
@export_multiline var description : String
@export var brief_description : String

@export_category("Quest Process")
@export var quest_prerequisite : String

@export_category("Quest Process")
@export var quantity_collected := 0
@export var quantity_goal := 0
@export var quest_type : QuestsManager.QuestType
@export var quest_item : QuestsManager.ITEM
@export var quest_person : QuestsManager.PERSON
@export var quest_pray : QuestsManager.PERSON
var quest_target

@export_category("Quest Status")
@export var quest_status : QuestsManager.STATUS = QuestsManager.STATUS.LOCKED

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
		QuestsManager.QuestType.KILL:
			return "Kill"

func _get_quest_target_string():
	match quest_type:
		QuestsManager.QuestType.COLLECT:
			return QuestsManager.ITEM.keys()[quest_item].capitalize()
		QuestsManager.QuestType.TALK:
			return QuestsManager.PERSON.keys()[quest_person].capitalize()
		QuestsManager.QuestType.KILL:
			return QuestsManager.PERSON.keys()[quest_pray].capitalize()

func get_quest_target():
	match quest_type:
		QuestsManager.QuestType.COLLECT:
			quest_target = quest_item
		QuestsManager.QuestType.TALK:
			quest_target = quest_person
		QuestsManager.QuestType.KILL:
			quest_target = quest_person
