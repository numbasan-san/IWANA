# =============================================================================
# QUEST MANAGER - Mission System
# =============================================================================
# Handles mission creation, tracking, and delivery.
# Supports multiple mission types (collect, talk, kill, explore, etc.)
# =============================================================================

# TODO: Code the remaining mission types (EXPLORE, CRAFT, ESCORT)
#       Currently only KILL, TALK and COLLECT are available.
#		(Don't know if will be needed more missions type).

extends Node

# =============================================================================
# SIGNALS
# =============================================================================
signal quest_changed(quest: Quest)      # Emitted when a mission changes state/progress
signal item_collected(item: ITEM)       # Emitted when a mission item is collected
signal person_talked(person: PERSON)    # Emitted when a mission NPC is talked to
signal enemy_killed(person: PERSON)		# Emitted when a mission Enemy is killed

# =============================================================================
# ENUMERATIONS - Mission types and objectives
# =============================================================================
enum QuestType {
	KILL,           # Defeat X specific enemies
	COLLECT,        # Collect X specific items
	TALK,           # Talk to X specific NPCs
	EXPLORE,        # Visit X specific zones
	CRAFT,          # Craft X specific items
	ESCORT          # Escort an NPC to a destination
}

enum PERSON {NONE, DUMMY_JUAN, DUMMY_THICC, DUMMY}  # Available NPCs for missions
enum ENEMY {DUMMY}  # Available NPCs for missions
enum ITEM {NONE, MANZANA}                    # Available items for missions
enum STATUS {LOCKED, AVAILABLE, ACTIVE, COMPLETED, DELIVERED}

enum AFFINITY {
	NEUTRAL,
	FRIENDLY,
	HOSTILE,
	MERCHANT,
	QUEST_GIVER,
	ALLY,
	ENEMY
}

# =============================================================================
# VARIABLES
# =============================================================================
var active_quests: Array[Quest] = []      # Missions in progress
var delivered_quests: Array[Quest] = []   # Completed missions

@onready var inventory: Inventory = preload("res://script/object_inventory/inventory/resources/inventory.tres")

# =============================================================================
# PUBLIC METHODS
# =============================================================================

# Adds a new mission to the system
func add_quest(quest: Quest):
	if not can_accept_quest(quest):
		return
	
	var quest_copy = quest.duplicate()
	update_quest_status(quest_copy)
	sync_collect_quest_with_inventory(quest_copy)
	active_quests.append(quest_copy)
	quest_changed.emit(quest_copy)

# Registers item collection and updates COLLECT type missions
func collect_quest(item: ITEM):
	for quest in active_quests:
		if quest.quest_type == QuestType.COLLECT and quest.quest_item == item:
			quest.quantity_collected = _count_quantity(item)
			update_quest_status(quest)
	
	quest_changed.emit()
	item_collected.emit()

# Registers NPC conversation and updates TALK type missions
func talk_quest(person: PERSON):
	for quest in active_quests:
		if quest.quest_type == QuestType.TALK and quest.quest_person == person:
			quest.quantity_collected += 1
			update_quest_status(quest)
	
	quest_changed.emit()
	person_talked.emit()

# Register Enemy and updates KILL (or hunt) type missions
func kill_quest(person : PERSON, affinity : AFFINITY):
	for quest in active_quests:
		if quest.quest_type == QuestType.KILL and quest.quest_pray == person and affinity == AFFINITY.ENEMY:
			quest.quantity_collected += 1
			update_quest_status(quest)
	
	quest_changed.emit()
	enemy_killed.emit()

# Updates mission status based on collected quantity vs goal
func update_quest_status(quest: Quest):
	if quest.quantity_collected >= quest.quantity_goal:
		quest.quest_status = STATUS.COMPLETED
	else:
		quest.quest_status = STATUS.ACTIVE

# Checks if there's a completed mission ready to deliver to an NPC
# Returns the mission if exists, otherwise null
func own_quest_done(person: PERSON):
	for quest in active_quests:
		if quest.to == person and quest.quantity_collected >= quest.quantity_goal:
			return quest
	return null

# Marks a mission as delivered and moves it to completed history
func quest_done(quest: Quest):
	quest.quest_status = STATUS.DELIVERED
	active_quests.erase(quest)
	delivered_quests.append(quest)
	quest_changed.emit()

func get_active_quest_by_id(quest_id):
	for quest in active_quests:
		if quest_id == quest.name and quest.quest_status == STATUS.COMPLETED:
			print("la misión " + quest.name + " fue entregada a su dueño pertinente")
			return quest
	return null

# =============================================================================
# VALIDATION METHODS
# =============================================================================

# Checks all conditions for accepting a new mission
func can_accept_quest(quest: Quest) -> bool:
	if _is_quest_null(quest): return false
	
	if _has_no_name(quest): return false
	
	if _is_already_active(quest):
		print("Misión ya activa: ", quest.name)
		return false
	
	if _was_delivered(quest):
		print("Misión ya entregada: ", quest.name)
		return false
	
	if not _prerequisites_met(quest):
		print("Requisitos no cumplidos: ", quest.quest_prerequisite)
		return false
	
	return true

func _is_quest_null(quest: Quest) -> bool: return quest == null

func _has_no_name(quest: Quest) -> bool:
	return quest.name == null or quest.name.is_empty()

func _is_already_active(quest: Quest) -> bool:
	for active in active_quests:
		if active.name == quest.name:
			return true
	return false

func _was_delivered(quest: Quest) -> bool:
	for delivered in delivered_quests:
		if delivered.name == quest.name:
			return delivered.quest_status == STATUS.DELIVERED
	return false

func _prerequisites_met(quest: Quest) -> bool:

	if quest.quest_prerequisite == "": return true

	for delivered in delivered_quests:
		if delivered.name == quest.quest_prerequisite:
			return true
	return false

# =============================================================================
# PRIVATE METHODS
# =============================================================================

# Counts how many units of an item the player has in inventory
func _count_quantity(target_item: ITEM) -> int:
	if not inventory or target_item == ITEM.NONE:
		return 0
	
	for slot in inventory.slots:
		if slot == null or slot.item == null:
			continue
		if slot.item.item == target_item:
			return slot.amount
	return 0

# Syncs a collection mission's progress with current inventory
func sync_collect_quest_with_inventory(quest: Quest):
	if quest == null:
		return
	
	if quest.quest_type == QuestType.COLLECT:
		var current_amount = _count_quantity(quest.quest_item)
		quest.quantity_collected = current_amount
		update_quest_status(quest)
