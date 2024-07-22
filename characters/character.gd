class_name Character
extends Node

var char_name: String

@export var unique: bool = true
var is_clone: bool = false:
	get:
		return CharacterManager.is_clone(self)

var dialog_model: DialogModel
var rpg_model: RPGModel
var combat_model: CombatModel
var combat_handler: CombatHandler

# The zone where this character is actually placed in the rpg world
var zone: Zone

# The party to which this character belongs, if any
var party: Party

# If this character belongs to the player's party, this should point to a
# corresponding point that follows the party path
var follower_node: PartyFollower

# This indicate if this character is the leader of its party. Operations on the
# party leader may affect other members too
var is_leader: bool

# This indicates if the character is following the leader of its party or if it's
# moving independently. This should always be false for leaders
var is_following: bool = false:
	set(value):
		var old_value = is_following
		is_following = value
		if old_value != value and rpg_model:
			if value:
				rpg_model.reposition(Vector2(0, 0), rpg_model.direction)
				_reattach_model(follower_node)
			else:
				if  rpg_model.get_parent() == follower_node:
					var position = follower_node.position
					reposition(zone, position, rpg_model.direction)

# The name of a unit of the script that is going to be loaded when someone
# interacts with this character
# TODO: we must make a more general code that would work if there are different
# situations that can trigger different units
var dialog_unit: String

func _ready():
	_link_components()
	
# We do this in a separate function instead of on _ready because when we clone
# a character we don't add it as a child of CharacterManager, which makes it so
# that _ready is never called.
func _link_components():
	dialog_model = $DialogModel
	if not dialog_model.is_node_ready():
		dialog_model._ready()
	dialog_model.character = self
	
	rpg_model = $RPGModel
	if not rpg_model.is_node_ready():
		rpg_model._ready()
	rpg_model.character = self
	rpg_model.deactivate()
	
	combat_model = $CombatModel
	if not combat_model.is_node_ready():
		combat_model._ready()
	combat_model.character = self
	
	combat_handler = $CombatHandler
	combat_handler.character = self
	combat_handler.init()
	for skill in combat_handler.skills:
		skill.caster = self
	if combat_handler.stats:
		combat_handler.stats.replenish()
	
	
	party = Party.new(self)

# Changes the position of this character model, possibly moving to a different
# zone. Calling this function with move_party false will force the character to
# move, possibly breaking its party formation and allowing several members of 
# the same party to be in different areas. If move_party is true this will instead
# call the reposition function in the Party object and move the entire party,
# preserving their formation
func reposition(new_zone: Zone, position: Vector2, direction: String, move_party: bool = false):
	if move_party:
		party.reposition(new_zone, position, direction)
	else:
		if not new_zone:
			remove_from_zone()
		# If we are moving to the same zone it was already in, most of these
		# calls have no effect
		else:
			rpg_model.activate()
			_reattach_model(new_zone)
			zone = new_zone
			rpg_model.reposition(position, direction)

# Removes this character from the current zone and restores its model
func remove_from_zone():
	if zone:
		if rpg_model:
			_detach_model()
			rpg_model.deactivate()
		zone = null

# Detaches the character model from wherever it is and attaches it to a new zone
# or follower node
# This function must be called using call_deferred so that moving the nodes
# doesn't throw errors and the conditions are properly checked each time
func _reattach_model(node: Node2D):
	if node != rpg_model.get_parent() and node is Zone or node is PartyFollower:
		_detach_model(false)
		_attach_model(node)

# Attaches the model to a node that can be either a zone or a follower node.
# This function assumes the model is either attached to the character or is an
# orphan, so this should only be called after calling _detach_model
# This moves any character to a new node regardless of if their following status
# This function must be called using call_deferred so that moving the nodes
# doesn't throw errors and the conditions are properly checked each time
func _attach_model(node: Node2D):
	if rpg_model and (node is Zone or node is PartyFollower):
		if self == rpg_model.get_parent():
			remove_child(rpg_model)
		node.add_child(rpg_model)

# Detaches the model from its current parent (either a path follower node or the
# current zone. If attach_to_char is true, the model is then reattached to the
# character node. If not, it is left orphaned. This last case should only be used
# if one intends to attach it immediately to another node
func _detach_model(attach_to_char: bool = true):
	if rpg_model and rpg_model.get_parent() != self:
		rpg_model.get_parent().remove_child(rpg_model)
		if attach_to_char:
			add_child(rpg_model)

func enable_collisions():
	if rpg_model:
		rpg_model.enable_collisions()

func disable_collisions():
	if rpg_model:
		rpg_model.disable_collisions()

func is_colliding() -> bool:
	return rpg_model and not rpg_model.collider.disabled

# Duplicates a non unique character, initializing all of its variables. If one
# tries to clone a unique character this returns null.
# One has to use this function instead of node.duplicate, as using that doesn't
# copy the script variables
func clone() -> Character:
	if not unique:
		return CharacterManager.clone(self)
	else:
		return null

# This is just a shortcut for the destroy function in CharacterManager
func destroy(force: bool = false):
	CharacterManager.destroy(self, force)
	
