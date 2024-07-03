class_name DamageEffect extends Effect

func apply(user: Character, target: Character):
	var u_damage = user.stats.damage
	var u_crit = user.stats.critical
	var rnd = randi_range(1, 100)
	# TODO: verify if this works as var damage = (crit or normal) or if it's
	# (var damage = crit) or normal 
	var damage = 2 * u_damage if u_crit >= rnd else u_damage
	
	# Defense is a value from 0 to 100 that acts as a percentage. We turn into a
	# value from 0 to 1
	var t_defense = float(target.stats.defense) / 100
	# This is the value that we're multiplying by the incoming damage.
	var mod = 1 - t_defense
	target.stats.health -= damage * mod

func process(user: Character):
	var u_damage = user.stats.damage
	var u_crit = user.stats.critical
	var rnd = randi_range(1, 100)
	# TODO: verify if this works as var damage = (crit or normal) or if it's
	# (var damage = crit) or normal 
	var damage = 2 * u_damage if u_crit >= rnd else u_damage
	
	value = damage
