class_name Skill extends Resource

# A skill is the main tool a character has during battle. Each player has 8
# skills and each one can either help the party, harm the enemies, or both.
# They can be improved while playing the game with special items, which will
# replace them with a more advanced version
# Each skill will also request a sequence of player inputs with specific timings
# that in some cases will improve its effects when hit properly, and in others
# it will cause them to fail or have negative effects when missed

# The name of the skill that is shown in menus or during combat in the skill
# selection gui
@export var name: String

# A description that is shown to the player in menus or tooltips that explain
# what it does
@export_multiline var description: String

# What level must reach the character to learn this skill
@export var level_to_learn: int

# Which effects this skill has on its caster, if any. The effects are applied
# sequentially, so the order in which they are added is important
@export var caster_effects: Array[Effect]

# Which effects this skill has on its target, if any. The effects are applied
# sequentially, so the order in which they are added is important
@export var target_effects: Array[Effect]

# How much energy using this skill consumes. If the character doesn't have
# enough energy, they can't perform the skill.
@export var energy_cost: int

# Which is the character that is performing the skill.
var caster: Character

# Who will receive the effects of the skill.
var target: SkillTarget

# The animation that is played when using the skill.
# TODO: this will probably have to be revised as it's posible we'll need a way
# to control pauses and timings of the animation to sync with the effects and
# inputs
var animation: Animation

# TODO: add variable to represent input presses and their timings that affect
# the results of the skill

# Performs some initialization before applying the skill.
# Some skills might have special conditions and effects that can't be easily
# represented by this system and they need to extend this script and override
# this function
# TODO: For now this assumes one-target skills. It has to be fixed later
func setup(caster: Character, target: Character):
	pass
