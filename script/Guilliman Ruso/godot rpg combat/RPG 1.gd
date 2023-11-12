extends Node2D

class_name RPG_por_turnos

var active_battler : battler

func initialize():
	var battlers = get_battlers()
	battlers.sort_custom(self, 'sort_battlers')
	for battler in battlers:
		battlers.raise()
	active_battler = get_child(0)
	
	static func sort_battlers(a : battler, b : battler) -> bool:
		return a.stats.speed > b.stats.speed

func play_turn(target : battler, action : CombatAction): 
	yield(active_battler.play_turn(target, action), "completed")
	var new_index : int = (active_battler.get_index() + 1) % get_child_count() 
	active_battler = get_child(new_index)

func 
