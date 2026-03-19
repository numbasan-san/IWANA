class_name StatControl extends HBoxContainer

@export_enum(
	"Max Health",
	"Max Energy",
	"Damage",
	"Defense",
	"Speed",
	"Critical",
	"Precision",
	"Evasion"
) var stat: String:
	set(value):
		stat = value
		_stat_name = stat.to_snake_case()
		_base_name = "base_" + _stat_name
		_mod_name = _stat_name + "_modifier"
		_signal_name = "update_" + _stat_name
		
@export var label_text: String:
	set(value):
		label_text = value
		label.text = value + ": "
		
@export var label: Label
@export var base: LineEdit
@export var mod: LineEdit
@export var final: Label

# These four should only be set in the editor by setting the stat variable.
var _base_name: String
var _mod_name: String
var _stat_name: String
var _signal_name: String

var _stats: Stats

var character: Character:
	set(value):
		# If there was a previous character, we unlink the signals.
		if _character:
			_delink_stats()
			_stats = null
		if value:
			_stats = value.combat_handler.stats
			_signal_name = "update_" + _stat_name
			_link_stats()
			_stats.connect(_signal_name, _link_stats)
			base.text_changed.connect(func(text): _stats.set(_base_name, text.to_int()))
			# This is commented because for now we don't allow the mod field
			# to change, only the base. The mod is only changed via effects. 
			# If later we allow mod to change we should uncomment this
			#mod.text_changed.connect(func(): stats.set(_mod_name, mod.text.to_float()))
		_character = value
var _character: Character

func _delink_stats():
	if _character:
		if _stats.is_connected(_signal_name, _link_stats):
			_stats.disconnect(_signal_name, _link_stats)
			# There should only be one
			for conn in base.text_changed.get_connections():
				base.text_changed.disconnect(conn.callable)
		base.text = ""
		mod.text = ""
		final.text = ""

# The arguments aren't used, they are only there because the stat updated signals
# have them as arguments, and we must call a function with the same arguments
func _link_stats(old = -1, new = -1):
	base.text = str(_stats.get(_base_name))
	mod.text = str(_stats.get(_mod_name))
	final.text = str(_stats.get(_stat_name))
	
