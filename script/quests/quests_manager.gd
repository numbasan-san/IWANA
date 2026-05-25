# =============================================================================
# QUEST MANAGER - Mission System
# =============================================================================
# Handles mission creation, tracking, and delivery.
# Supports multiple mission types (collect, talk, kill, explore, etc.)
# =============================================================================


# TO DO: Code the remaining mission types.
# 		 Only talk and collect are available.


extends Node

# =============================================================================
# SIGNALS
# =============================================================================
signal quest_changed(quest: Quest)      # Emitted when a mission changes state/progress
signal item_collected(item: ITEM)       # Emitted when a mission item is collected
signal person_talked(person: PERSON)    # Emitted when a mission NPC is talked to

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

enum PERSON {NONE, DUMMY_JUAN, DUMMY_THICC} # Available NPCs for missions
enum ITEM {NONE, MANZANA} # Available items for missions
enum STATUS {LOCKED, AVAILABLE, ACTIVE, COMPLETED, DELIVERED}

# =============================================================================
# VARIABLES
# =============================================================================
var active_quests: Array[Quest] = []     # Missions in progress
var delivered_quests: Array[Quest] = []   # Completed missions

@onready var inventory: Inventory = preload("res://script/object_inventory/inventory/resources/inventory.tres")

# =============================================================================
# PUBLIC METHODS
# =============================================================================

# Adds a new mission to the system
func add_quest(quest: Quest):
	# Basic validation
	if quest == null:
		return
	if quest.name == null or quest.name.is_empty():
		return
	
	# Prevent duplicate missions
	for active in active_quests:
		if active.name == quest.name:
			return
	for delivered in delivered_quests:
		if delivered.name == quest.name:
			if delivered.quest_status == STATUS.DELIVERED:
				print(delivered.name, " entregada")
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

# =============================================================================
# PRIVATE METHODS
# =============================================================================

# Counts how many units of an item the player has in inventory
func _count_quantity(target_item: ITEM) -> int:
	if not inventory or target_item == null:
		return 0
	
	for slot in inventory.slots:
		if slot.item == null:
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
