class_name SpriteIconControl extends Panel

@export var icon_placement: GridContainer

var effects_to_textures: Dictionary

# TODO: if we change lasting effects sprites to not repeate but only show
# one icon with the info of all related effects, we must change these functions
# so that they only add one icon and only remove it when all instances of the
# effect are removed.
func add_effect(effect: LastingEffect):
	var texture = TextureRect.new()
	texture.texture = effect.icon
	icon_placement.add_child(texture)
	effects_to_textures[effect] = texture

func remove_effect(effect: LastingEffect):
	var texture = effects_to_textures[effect]
	texture.queue_free()
	effects_to_textures.erase(effect)
	
