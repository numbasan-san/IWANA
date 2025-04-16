class_name ChainedEffect extends LastingEffect

# This class can have one effect associated with each of its event functions
# (on_incoming, after_turn, etc), and when that event is triggered, the
# associated effect will be sent to its recorded target.

# This will be triggered before the target's turn starts
@export var before_turn_effect: Effect

# This will be triggered after the target's turn ends
@export var after_turn_effect: Effect

# This will be triggered when this ChainedEffect is removed from the target's
# buffs or debuffs
@export var unapply_effect: Effect

# This will be triggered when the ChainedEffect succesfully intercepts an
# incoming effect
@export var incoming_effect: Effect

# This will be triggered when the ChainedEffect succesfully intercepts an
# outgoing effect
@export var outgoing_effect: Effect

# This effect will be triggered when the ChainedEffect character_hit function is
# called 
@export var character_hit_effect: Effect

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

func incoming(effect: Effect):
	if not effect.is_nullified and not incoming_intercepted:
		on_incoming(effect)
		if incoming_intercepted:
			if incoming_effect:
				# Because this effect is passed directly to the receive function,
				# the on_cast function of the effect and out_moding effects of
				# the caster will be bypassed. This means the effect value won't
				# be modified before reaching the target and it will use the value
				# set in the editor. In particular, triggering a damage effect
				# won't use the caster's damage to calculate the value.
				await incoming_effect.target.combat_handler.receive(incoming_effect)
			if decrease_duration == Decrease.ON_INCOMING_INTERCEPT:
				duration -= 1
	incoming_intercepted = false

func outgoing(effect: Effect):
	if not effect.is_nullified and not outgoing_intercepted:
		on_outgoing(effect)
		if outgoing_intercepted:
			if outgoing_effect:
				# Because this effect is passed directly to the receive function,
				# the on_cast function of the effect and out_moding effects of
				# the caster will be bypassed. This means the effect value won't
				# be modified before reaching the target and it will use the value
				# set in the editor. In particular, triggering a damage effect
				# won't use the caster's damage to calculate the value.
				await outgoing_effect.target.combat_handler.receive(outgoing_effect)
			if decrease_duration == Decrease.ON_OUTGOING_INTERCEPT:
				duration -= 1
	outgoing_intercepted = false

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
	if incoming_effect:
		new_chained.incoming_effect = incoming_effect.copy()
	if outgoing_effect:
		new_chained.outgoing_effect = outgoing_effect.copy()
	return new_chained

func _set_caster(_caster: Character):
	super._set_caster(_caster)
	if after_turn_effect:
		after_turn_effect.caster = _caster
	if before_turn_effect:
		before_turn_effect.caster = _caster
	if unapply_effect:
		unapply_effect.caster = _caster
	if incoming_effect:
		incoming_effect.caster = _caster
	if outgoing_effect:
		outgoing_effect.caster = _caster

func _set_skill_targets(_targets: Array[Character]):
	super._set_skill_targets(_targets)
	if after_turn_effect:
		after_turn_effect.skill_targets = _targets
	if before_turn_effect:
		before_turn_effect.skill_targets = _targets
	if unapply_effect:
		unapply_effect.skill_targets = _targets
	if incoming_effect:
		incoming_effect.skill_targets = _targets
	if outgoing_effect:
		outgoing_effect.skill_targets = _targets
		
func _set_skill_(_skill: Skill):
	super._set_skill(_skill)
	if after_turn_effect:
		after_turn_effect.skill = _skill
	if before_turn_effect:
		before_turn_effect.skill = _skill
	if unapply_effect:
		unapply_effect.skill = _skill
	if incoming_effect:
		incoming_effect.skill = _skill
	if outgoing_effect:
		outgoing_effect.skill = _skill
