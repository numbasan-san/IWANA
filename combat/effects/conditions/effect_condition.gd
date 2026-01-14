class_name EffectCondition extends Condition

## The character type from which the effects are being taken
@export_enum("Caster", "Target") var character: String = "Caster"

## If the character must have or not have the given effects.
##
## If true, the evaluation will be true if the character has all of the effects
## in the list. If false, the evaluation will be true if it has none of the effects.
@export var has: bool = true

## The types of these effects are going to be searched in the character.
@export var effects: Array[LastingEffect]

func evaluate(caster: Character, target: Character) -> bool:
	var char: Character
	match character:
		"Caster":
			char = caster
		"Target":
			char = target
		_:
			return false
	var char_effects = char.combat_handler.lasting_effects
	for eff in effects:
		# Finds the effects on the character with the same type as eff
		var filtered = char_effects.filter(func(char_eff: LastingEffect):
			return char_eff.is_same_type(eff)
		)
		var result = filtered.size() > 0
		if not has:
			result = not result 
		if not result:
			return false
	return true
