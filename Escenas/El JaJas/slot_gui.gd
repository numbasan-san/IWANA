
extends Panel

@onready var background_sprite : Sprite2D = $background
@onready var item_sprite : Sprite2D = $CenterContainer/Panel/item

func update(item: Item):
	if item:
		background_sprite.frame = 1
		item_sprite.visible = true
		item_sprite.texture = item.texture
	else:
		background_sprite.frame = 0
		item_sprite.visible = false
