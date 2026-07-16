# res://script/globals/event_bus.gd
extends Node

# Señales relacionadas con diálogos y NPCs
signal talked(npc_name: String, npc: Character)
signal dialog_started(unit_name: String)
signal dialog_ended(unit_name: String)

# Señales relacionadas con combate
signal battle_started(enemies: Array)
signal battle_ended(result: String)  # "victory", "defeat", "escaped"

# Señales relacionadas con misiones
signal quest_accepted(quest_id: String)
signal quest_completed(quest_id: String)
signal quest_updated(quest_id: String, progress: int, total: int)

# Señales relacionadas con items
signal item_collected(item_id: String, quantity: int)
signal item_used(item_id: String)

# Señales relacionadas con el jugador
signal player_level_up(new_level: int)
signal player_died()

# Señales relacionadas con zonas
signal zone_changed(zone_name: String)
