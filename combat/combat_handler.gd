class_name CombatHandler extends Node

@export var stats: Stats
@export var skills: Array[Skill]

var character: Character

# Status effects are effects that apply to the character the moment the skill
# lands on it and are removed when a condition is reached

# These are buffs and debuffs that only modify the character's stats.
# When one of these effects enters the list its on_apply function should be
# called to modify the stats, and when it exits its on_unapply function should
# be called to undo the applied changes
var stat_modifiers: Array[LastingEffect]

# These are buffs and debuffs that intercept the effects coming from
# another character, either friend or enemy, and can modify them before applying
# them, redirect them or even prevent them completely.
var incoming_effect_modifiers: Array[LastingEffect]

# These are buffs and debuffs that intercept the effects of skills used by this
# character and can modify them before sending them to a target
var outgoing_effect_modifiers: Array[LastingEffect]

# This function should be called by the caster of the skill that will impact
# this character. Here it is decided how to handle each effect, if it will be
# applied immediately, if it will be added to the status effect lists, if some
# preprocessing must be performed before applying it, etc.
func process(effect: Effect):
	pass


func execute(skill: Skill):
	if stats.energy < skill.energy_cost:
		printerr("Skill | " + character.name + " tried to use a skill without having" \
			+ " the required energy of " + str(skill.energy_cost) + ". This shouldn't" \
			+ " happen as this should be prevented in the combat screen before" \
			+ " selecting the skill")
		return
	
	for effect in skill.effects:
		var copy: Effect = effect.duplicate(true)
		# TODO: duplicate doesn't copy values in the script. See if anything other
		# than these two need to be copied
		copy.caster = effect.caster
		copy.targets = effect.targets
		send(copy)
		
	stats.energy -= skill.energy_cost

# Calculates the initial value of this effect, modifies it based on the caster
# buffs and debuffs, and sends it to the target
func send(effect: Effect):
	# If everything went correctly, effect.caster == character
	effect.on_cast(effect.caster)
	for out in outgoing_effect_modifiers:
		out.intercept(effect)
	for t in effect.targets:
		effect.on_send(t)
		t.combat_handler.receive(effect)

# Receives an effect sent from a caster, modifies it based on the character's
# buffs and debuffs, and if the effect survives it is applied.
func receive(effect: Effect):
	effect.on_receive(effect.caster)
	for inc in incoming_effect_modifiers:
		inc.intercept(effect)
	effect.on_apply(character)
