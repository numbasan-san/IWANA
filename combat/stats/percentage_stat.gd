# Stats extending this class are treated as a percentage, and the modifier is
# applied additively instead of multiplicatively
class_name PercentageStat extends Stat

# The final value of the stat, after applying modifiers.
func get_value():
	return clampi(round(base + modifier), min_value, max_value)

