extends Control

func _on_characters_btn_pressed():
	self.visible = false
	var selected_menu = self.get_parent()
	var characters_menu = selected_menu.get_node('characters_menu')
	characters_menu.visible = true
	characters_menu.load_canditates()

func _on_maps_btn_pressed():
	self.visible = false
	var selected_menu = self.get_parent()
	var maps_menu = selected_menu.get_node('maps_menu')
	maps_menu.visible = true
	maps_menu.load_maps()

func _on_items_btn_pressed():
	self.visible = false
	var selected_menu = self.get_parent()
	var items_menu = selected_menu.get_node('items_menu')
	items_menu.visible = true
	items_menu.load_items()


func _on_contacts_btn_pressed():
	self.visible = false
	var selected_menu = self.get_parent()
	var contacts_menu = selected_menu.get_node('contacts_menu')
	contacts_menu.visible = true
	contacts_menu.load_characters()
