extends Control

@export var inventory: Inventory
@onready var item_card_scene : PackedScene = (
	preload("res://scenes/menus/game_menu/item_tarjeta.tscn")
)
@onready var ItemsGrid = (
	$ItemsContainer/ItemsMargin/ItemsBackground/ItemsScroll/ItemsGrid
)

var shop_items = []
var selected_item = null
var stock = 1

func open():
	show_shop()

func load_all_items():
	var items = []
	var folder = "res://script/object_inventory/items/resources/"
	
	if DirAccess.open(folder):
		for file in DirAccess.get_files_at(folder):
			if file.ends_with(".tres"):
				var item = load(folder + file)
				if item is Item and item.sellable:
					items.append(item)
	else:
		print("ERROR: No se pudo abrir la carpeta")
	
	return items

func load_shop_items():
	update_gold()
	clear_ItemsGrid()
	
	shop_items = load_all_items()
	
	for item in shop_items:
		var player_count = count_item_in_inventory(item)
		var card = create_item_card(item, player_count)
		ItemsGrid.add_child(card)
		
		card.get_node("Button").pressed.connect(
			_on_item_card_pressed.bind(card)
		)
	
	if selected_item:
		update_selection()

func create_item_card(item, player_count):
	var card = item_card_scene.instantiate()
	
	var hbox = card.get_node("Button/MarginContainer/HBoxContainer")

	hbox.get_node("icon").texture = item.texture

	card.icon = item.texture
	card.namae = item.name
	card.text = item.description
	card.stack = str(player_count)
	card.item_data = item
	card.hover = item.texture  # Item no tiene esta propiedad

	return card

func count_item_in_inventory(item):
	var count = 0
	for slot in inventory.slots:
		if slot.item == item:
			count += slot.amount
	return count

func add_item_to_inventory(item):
	for slot in inventory.slots:
		if slot.item == item and slot.amount < item.max_stack:  # CAMBIADO: item.stack → item.max_stack
			slot.amount += 1 * stock
			return true
		elif slot.item == null:
			slot.item = item
			slot.amount = 1 * stock
			return true
	return false

func remove_item_from_inventory(item, count_to_remove = 1):
	var total_removed = 0
	
	for slot in inventory.slots:
		if slot.item == item:
			var can_remove = min(slot.amount, count_to_remove - total_removed)
			slot.amount -= can_remove
			total_removed += can_remove
			
			if slot.amount <= 0:
				slot.item = null
			
			if total_removed >= count_to_remove:
				return true
	
	return total_removed >= count_to_remove

# TRANSACCIONES
func buy_item():
	if not selected_item or inventory.gold < (selected_item.cost * stock):
		return
	var item_cost = selected_item.cost
	
	inventory.gold -= (item_cost * stock)
	add_item_to_inventory(selected_item)
	update_ui()

func sell_item():
	if not selected_item:
		return
	
	var available = count_item_in_inventory(selected_item)
	var sell_count = min(stock, available)
	
	if sell_count <= 0:
		print("No tienes este item")
		return
	
	# Pasar la cantidad a remover
	if remove_item_from_inventory(selected_item, sell_count):
		inventory.gold += calculate_sell_price(selected_item.cost, sell_count)
		update_ui()

# UI - RUTAS CORREGIDAS
func update_gold():
	$GoldDisplay/GoldLabel.text = "gold: " + str(inventory.gold)

func update_selection():
	if selected_item:
		$SelectedItemIcon/ItemIcon.texture = selected_item.texture
		
		# RUTAS ACTUALIZADAS
		$ItemInfoPanel/InfoMargin/InfoLayout/ItemDescription.text = selected_item.description
		$ItemInfoPanel/InfoMargin/InfoLayout/ItemName.text = selected_item.name
		$ItemInfoPanel/InfoMargin/InfoLayout/PriceStockRow/ItemPrice.text =  "Price: $" + str(selected_item.cost) + "."
		$ItemInfoPanel/InfoMargin/InfoLayout/PriceStockRow/PlayerStock.text = "x" + str(count_item_in_inventory(selected_item))
		
		update_count_display()

func clear_ItemsGrid():
	for child in ItemsGrid.get_children():
		child.queue_free()

func clean():
	$SelectedItemIcon/ItemIcon.texture = null
	
	# RUTAS ACTUALIZADAS
	$ItemInfoPanel/InfoMargin/InfoLayout/ItemDescription.text = ""
	$ItemInfoPanel/InfoMargin/InfoLayout/ItemName.text = ""
	$ItemInfoPanel/InfoMargin/InfoLayout/PriceStockRow/ItemPrice.text =  ""
	$ItemInfoPanel/InfoMargin/InfoLayout/PriceStockRow/PlayerStock.text = ""
	
	$PriceDisplayPanel/BuyPriceLabel.text = ""
	$PriceDisplayPanel/SellPriceLabel.text = ""
	selected_item = null
	stock = 1

func change_stock(amount):
	stock = max(1, stock + amount)
	if amount > 0 and stock % 10 != 0:
		stock -= 1
	update_stock_display()

func update_stock_display():
	$TransactionControls/StockAmountLabel.text = str(stock)
	update_count_display()

func update_count_display():
	var item_cost = selected_item.cost if selected_item else 0
	var sell_price = calculate_sell_price(item_cost, stock)
	var buy_price = stock * item_cost
	
	$PriceDisplayPanel/SellPriceLabel.text = "sell price: " + str(sell_price)
	$PriceDisplayPanel/BuyPriceLabel.text = "buy price: " + str(buy_price)

func calculate_sell_price(item_cost, sell_count):
	return (
		((sell_count * item_cost) / 2) if ((item_cost / 2) > 1) else (1 * sell_count)
	)

# TIENDA
func show_shop():
	visible = true
	get_tree().paused = true
	AudioServer.set_bus_mute(0, false)
	clean()
	load_shop_items()
	$TransactionControls/StockAmountLabel.text = str(stock)

func hide_shop():
	visible = false
	get_tree().paused = false

func update_ui():
	update_gold()
	load_shop_items()

# SEÑALES
func _on_item_card_pressed(card):
	selected_item = card.item_data
	update_selection()

func _on_buy_button_pressed():
	buy_item()

func _on_sell_button_pressed():
	sell_item()

func _on_increase_stock_button_pressed():
	change_stock(10)

func _on_decrease_stock_button_pressed():
	change_stock(-10)

func _on_close_button_pressed():
	hide_shop()
