class_name ChainedEffect extends LastingEffect

# This class can have one effect associated with each of its event functions
# (on_intercept, after_turn, etc), and when that event is triggered, the
# associated effect will be sent to its recorded target.

# This effect will be triggered when the ChainedEffect character_hit function is
# called 
@export var character_hit_effect: Effect

# This will be triggered before the target's turn starts
@export var before_turn_effect: Effect

# This will be triggered after the target's turn ends
@export var after_turn_effect: Effect

# This will be triggered when this ChainedEffect is removed from the target's
# buffs or debuffs
@export var unapply_effect: Effect

# This will be triggered when the ChainedEffect succesfully intercepts another
# effect
@export var intercept_effect: Effect

func character_hit(who: Character, effect: Effect):
	if not hit:
		on_character_hit(who, effect)
		if hit:
			if character_hit_effect:
				await target.combat_handler.receive(character_hit_effect)
			if decrease_duration == Decrease.ON_CHARACTER_HIT:
				duration -= 1
	hit = false

func start_turn(target: Character):
	before_turn(target)
	if before_turn_effect:
		await target.combat_handler.receive(before_turn_effect)
	if decrease_duration == Decrease.BEFORE_TURN:
		duration -= 1
	

func end_turn(target: Character):
	after_turn(target)
	if after_turn_effect:
		await target.combat_handler.receive(after_turn_effect)
	if decrease_duration == Decrease.AFTER_TURN:
		duration -= 1

func unapply(target: Character):
	# We don't decrease duration here as this should only be called when the
	# duration has already reached 0
	on_unapply(target)
	if unapply_effect:
		await target.combat_handler.receive(unapply_effect)

func intercept(effect: Effect):
	if not effect.is_nullified and not interception:
		on_intercept(effect)
		if interception:
			if intercept_effect:
				await target.combat_handler.receive(intercept_effect)
			if decrease_duration == Decrease.ON_INTERCEPT:
				duration -= 1
	interception = false

# Even though in theory duplicating this effect should also duplicate the linked
# ones, we need to call their copy methods to ensure they are also properly copied.
func copy() -> Effect:
	var new_chained = super.copy() as ChainedEffect
	if after_turn_effect:
		new_chained.after_turn_effect = after_turn_effect.copy()
	if before_turn_effect:
		new_chained.before_turn_effect = before_turn_effect.copy()
	if unapply_effect:
		new_chained.unapply_effect = unapply_effect.copy()
	if intercept_effect:
		new_chained.intercept_effect = intercept_effect.copy()
	return new_chained

func _set_caster(_caster: Character):
	super._set_caster(_caster)
	if after_turn_effect:
		after_turn_effect.caster = _caster
	if before_turn_effect:
		before_turn_effect.caster = _caster
	if unapply_effect:
		unapply_effect.caster = _caster
	if intercept_effect:
		intercept_effect.caster = _caster

func _set_skill_targets(_targets: Array[Character]):
	super._set_skill_targets(_targets)
	if after_turn_effect:
		after_turn_effect.skill_targets = _targets
	if before_turn_effect:
		before_turn_effect.skill_targets = _targets
	if unapply_effect:
		unapply_effect.skill_targets = _targets
	if intercept_effect:
		intercept_effect.skill_targets = _targets
