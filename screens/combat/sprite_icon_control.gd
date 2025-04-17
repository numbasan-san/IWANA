class_name SpriteIconControl extends Panel

@export var icon_placement: GridContainer

var effects_to_textures: Dictionary

# TODO: if we change lasting effects sprites to not repeate but only show
# one icon with the info of all related effects, we must change these functions
# so that they only add one icon and only remove it when all instances of the
# effect are removed.
func add_effect(effect: LastingEffect):
	var texture = TextureRect.new()
	effect.init_base_data()
	effect.base_data.changed.connect(_update_icon)
	_update_icon(texture, effect)
	icon_placement.add_child(texture)
	effects_to_textures[effect] = texture

func remove_effect(effect: LastingEffect):
	var texture = effects_to_textures[effect]
	effect.base_data.changed.disconnect(_update_icon)
	texture.queue_free()
	effects_to_textures.erase(effect)
	
func _update_icon(texture: TextureRect, effect: Effect):
	texture.texture = effect.base_data.icon
	texture.tooltip_text = effect.base_data.name + "\n" + \
		effect.base_data.description + "\n" + \
		effect.base_data.variable_info
