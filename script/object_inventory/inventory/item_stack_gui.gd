extends Panel

class_name ItemStackGui

@onready var item_sprite : Sprite2D = $item
@onready var amount_label : Label = $Label

var inventorySlot : Slot

func update():
	if !inventorySlot or !inventorySlot.item: return
	item_sprite.visible = true
	item_sprite.texture = inventorySlot.item.texture
	amount_label.visible = (inventorySlot.amount > 1)
	amount_label.text = str(inventorySlot.amount) 
