class_name SpriteIconControl extends Panel

@export var icon_placement: GridContainer

var effects_to_textures: Dictionary

func add_effect(effect: LastingEffect):
	var texture = TextureRect.new()
	texture.texture = effect.icon
	icon_placement.add_child(texture)
	effects_to_textures[effect] = texture

func remove_effect(effect: LastingEffect):
	var texture = effects_to_textures[effect]
	texture.queue_free()
	effects_to_textures.erase(effect)
	
