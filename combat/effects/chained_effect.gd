class_name ChainedEffect extends LastingEffect

# This class can have one effect associated with each of its event functions
# (on_incoming, after_turn, etc), and when that event is triggered, the
# associated effect will be sent to its recorded target.

# These will be triggered before the target's turn starts
@export var before_turn_effects: Array[Effect]

# These will be triggered after the target's turn ends
@export var after_turn_effects: Array[Effect]

# These will be triggered when this ChainedEffect is removed from the target's
# buffs or debuffs
@export var unapply_effects: Array[Effect]

# These will be triggered when the ChainedEffect succesfully intercepts an
# incoming effect
@export var incoming_effects: Array[Effect]

# These will be triggered when the ChainedEffect succesfully intercepts an
# outgoing effect
@export var outgoing_effects: Array[Effect]

# These will be triggered when the ChainedEffect character_hit function is
# called 
@export var character_hit_effects: Array[Effect]

func character_hit(who: Character, effect: Effect):
	if not hit:
		on_character_hit(who, effect)
		if hit:
			for eff in character_hit_effects:
				await eff.target.combat_handler.receive(eff)
			if decrease_duration == Decrease.ON_CHARACTER_HIT:
				duration -= 1
	hit = false

func start_turn(target: Character):
	before_turn(target)
	for eff in before_turn_effects:
		await eff.target.combat_handler.receive(eff)
	if decrease_duration == Decrease.BEFORE_TURN:
		duration -= 1
	
func end_turn(target: Character):
	after_turn(target)
	for eff in after_turn_effects:
		await eff.target.combat_handler.receive(eff)
	if decrease_duration == Decrease.AFTER_TURN:
		duration -= 1

func unapply(target: Character):
	# We don't decrease duration here as this should only be called when the
	# duration has already reached 0
	on_unapply(target)
	for eff in unapply_effects:
		await eff.target.combat_handler.receive(eff)

func incoming(effect: Effect):
	if not effect.is_nullified and not incoming_intercepted:
		on_incoming(effect)
		if incoming_intercepted:
			for eff in incoming_effects:
				# Because this effect is passed directly to the receive function,
				# the on_cast function of the effect and out_moding effects of
				# the caster will be bypassed. This means the effect value won't
				# be modified before reaching the target and it will use the value
				# set in the editor. In particular, triggering a damage effect
				# won't use the caster's damage to calculate the value.
				await eff.target.combat_handler.receive(eff)
			if decrease_duration == Decrease.ON_INCOMING_INTERCEPT:
				duration -= 1
	incoming_intercepted = false

func outgoing(effect: Effect):
	if not effect.is_nullified and not outgoing_intercepted:
		on_outgoing(effect)
		if outgoing_intercepted:
			for eff in outgoing_effects:
				# Because this effect is passed directly to the receive function,
				# the on_cast function of the effect and out_moding effects of
				# the caster will be bypassed. This means the effect value won't
				# be modified before reaching the target and it will use the value
				# set in the editor. In particular, triggering a damage effect
				# won't use the caster's damage to calculate the value.
				await eff.target.combat_handler.receive(eff)
			if decrease_duration == Decrease.ON_OUTGOING_INTERCEPT:
				duration -= 1
	outgoing_intercepted = false

# Even though in theory duplicating this effect should also duplicate the linked
# ones, we need to call their copy methods to ensure they are also properly copied.
func copy() -> Effect:
	var new_chained = super.copy() as ChainedEffect
	
	var copies: Array[Effect] = []
	for eff in after_turn_effects:
		copies.append(eff.copy())
	new_chained.after_turn_effects = copies
	
	copies = []
	for eff in before_turn_effects:
		copies.append(eff.copy())
	new_chained.before_turn_effects = copies
	
	copies = []
	for eff in unapply_effects:
		copies.append(eff.copy())
	new_chained.unapply_effects = copies
	
	copies = []
	for eff in incoming_effects:
		copies.append(eff.copy())
	new_chained.incoming_effects = copies
	
	copies = []
	for eff in outgoing_effects:
		copies.append(eff.copy())
	new_chained.outgoing_effects = copies
	
	copies = []
	for eff in character_hit_effects:
		copies.append(eff.copy())
	new_chained.character_hit_effects = copies

	return new_chained

# The chain can't be flattened, so this function will return an array of chains.
func process_effect(
		allies: Array[Character],
		enemies: Array[Character],
		handler: TurnHandler,
		parent_target: Character = null) -> Array[Effect]:
	
	var copies = await super.process_effect(allies, enemies, handler, parent_target)
	# Before processing the skill is set to NEW unless it failed some check.
	# During processing it should still be NEW unless it was manually cancelled
	# or something failed.
	if skill.status != skill.Status.NEW:
		return []
	
	# All the elements in the copies array should be a copy of this chain effect.
	# Each sub effect is a copy of the original without processing
	for chain in copies:
		chain = chain as ChainedEffect
		var process = func(eff):
			return await eff.process_effect(allies, enemies, handler, chain.target)
		# This will iterate over each effect, process it, and append it to the
		# result of processing the previous one. We use the empty array as the
		# first value to force the processing of the first element of the array
		var processed: Array[Effect]
		for eff in chain.after_turn_effects:
			processed.append_array(process.call(eff))
		chain.after_turn_effects = processed
		
		processed = []
		for eff in chain.before_turn_effects:
			processed.append_array(process.call(eff))
		chain.before_turn_effects = processed
		
		processed = []
		for eff in chain.unapply_effects:
			processed.append_array(process.call(eff))
		chain.unapply_effects = processed
		
		processed = []
		for eff in chain.incoming_effects:
			processed.append_array(process.call(eff))
		chain.incoming_effects = processed
		
		processed = []
		for eff in chain.outgoing_effects:
			processed.append_array(process.call(eff))
		chain.outgoing_effects = processed
		
		processed = []
		for eff in chain.character_hit_effects:
			processed.append_array(process.call(eff))
		chain.character_hit_effects = processed
		
	return copies

func _set_caster(_caster: Character):
	super._set_caster(_caster)
	for eff in after_turn_effects:
		eff.caster = _caster
	for eff in before_turn_effects:
		eff.caster = _caster
	for eff in unapply_effects:
		eff.caster = _caster
	for eff in incoming_effects:
		eff.caster = _caster
	for eff in outgoing_effects:
		eff.caster = _caster
	for eff in character_hit_effects:
		eff.caster = _caster
	
		
func _set_skill(_skill: Skill):
	super._set_skill(_skill)
	for eff in after_turn_effects:
		eff.skill = _skill
	for eff in before_turn_effects:
		eff.skill = _skill
	for eff in unapply_effects:
		eff.skill = _skill
	for eff in incoming_effects:
		eff.skill = _skill
	for eff in outgoing_effects:
		eff.skill = _skill
	for eff in character_hit_effects:
		eff.skill = _skill
