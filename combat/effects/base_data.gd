## Common data that describes an effect.
##
## It is stored as a separate resource so that it can be shared amongst related
## effects while being able to change other variables like duration or value.
class_name EffectBaseData extends Resource

## Name that will be shown in tooltips and menus.
@export var name: String:
	set(new_name):
		name = new_name
		emit_changed()

## Short description that will be shown in tooltips and menus.
@export_multiline var description: String:
	set(new_desc):
		description = new_desc
		emit_changed()

## Information that will be shown in tooltips that changes as the values of the
## effect change.
## 
## This can be used to update the tooltips without having to change the description.
var variable_info: String:
	set(new_info):
		variable_info = new_info
		emit_changed()

## Icon that will be used to show in the buffs/debuffs list or in the effect
## selection menu.
@export var icon: AtlasTexture:
	set(new_icon):
		if icon:
			icon.changed.disconnect(emit_changed)
		icon = new_icon
		if icon:
			icon.changed.connect(emit_changed)
		emit_changed()
