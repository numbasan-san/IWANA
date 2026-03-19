# res://script/quests/quest_manager.gd
extends Node

signal quest_changed(quest: Quest)
signal item_collected(item: ITEM)
signal person_talked(person: PERSON)

enum QuestType {
	KILL,           # Eliminar objetivos
	COLLECT,        # Recolectar items
	TALK,           # Hablar con NPCs
	EXPLORE,        # Visitar zonas
	CRAFT,          # Crear objetos
	ESCORT          # Acompañar NPC
}
enum PERSON {DUMMY_JUAN, DUMMY_THICC}
enum ITEM {NONE, MANZANA}

var active_quests: Array[Quest] = []

# ESTA COSA ES PARA LAS MISIONES COMPLETADAS
var finished_quests: Array[Quest] = []

func add_quest(quest: Quest):
	# Verificar que la quest no sea null
	if quest == null:
		print("Error: Intento de agregar una quest null")
		return
	
	# Verificar que tenga los datos mínimos necesarios
	if quest.name == null or quest.name.is_empty():
		print("Error: La quest no tiene título")
		return
	
	var quest_copy = quest.duplicate()
	active_quests.append(quest_copy)
	quest_changed.emit(quest_copy)
	print("Quest agregada: ", quest.name)

func collect_quest(item: ITEM, quantity):
	for quest in active_quests:
		if quest.quest_type == QuestType.COLLECT and quest.quest_item == item:
			quest.quantity_collected += quantity

	quest_changed.emit()
	item_collected.emit()

func talk_quest(person: PERSON):
	for quest in active_quests:
		if quest.quest_type == QuestType.TALK and quest.quest_person == person:
			quest.quantity_collected += 1

	quest_changed.emit()
	person_talked.emit()

func own_quest_done(person: PERSON):
	for quest in active_quests:
		if quest.to == person:
			return quest

func quest_done(quest: Quest):
	active_quests.erase(quest)
	finished_quests.append(quest)
	print("Esta misión: " + quest.name + ". Debería estar entregada")

	for q in finished_quests:
		print(q.name)

	quest_changed.emit()
