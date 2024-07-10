extends Control

var rooms = {
	'RoomF1N1': 'RF1N1',
	'RoomF1N2': 'RF1N2',
	'Yard': 'YRD',
	'F1FemaleBathroom': 'F1FBTHR',
	'F1MaleBathroom': 'F1MBTHR',
	'Laboratory': 'LBRT',
	'DiningRoom': 'DNR',
	'RoomF1S1': 'RF1S1',
	'RoomF1S2': 'RF1S2',
	'ArtRoom': 'ARTR',
}

var current_room_node = null  # Variable para llevar un seguimiento del nodo actual

# Función para reproducir la animación en el nodo correspondiente y detenerla en el nodo anterior
func play_animation_on_room(room_key):
	var room_name = rooms.get(room_key, null)

	if room_name:
		var room_node = get_node('background/Map/' + room_name)

		if room_node:
			if current_room_node and current_room_node != room_node:
				# Detener la animación en el nodo anterior
				var previous_anim_player = current_room_node.get_node("AnimationPlayer")
				if previous_anim_player:
					previous_anim_player.play("RESET")

			# Reproducir la animación en el nuevo nodo
			var anim_player = room_node.get_node("AnimationPlayer")
			if anim_player:
				anim_player.play("in_there")
				current_room_node = room_node  # Actualizar el nodo actual
			else:
				print("AnimationPlayer not found in room node")
		else:
			print("Room node not found")
	else:
		# Si no estás en ninguna habitación listada, detener la animación en el nodo actual
		if current_room_node:
			var anim_player = current_room_node.get_node("AnimationPlayer")
			if anim_player:
				anim_player.play("RESET")
			current_room_node = null  # Resetear el nodo actual

# Función load como ejemplo de uso
func load():
	var world = Player.zone
	print('current screen: ' + world.name)
	
	if rooms.has(world.name):
		play_animation_on_room(world.name)
	else:
		play_animation_on_room(null)  # Manejar el caso del pasillo


func _on_characters_btn_pressed():
	self.visible = false
	var selected_menu = self.get_parent()
	var characters_menu = selected_menu.get_node('characters_menu')
	characters_menu.visible = true

func _on_items_btn_pressed():
	self.visible = false
	var selected_menu = self.get_parent()
	var characters_menu = selected_menu.get_node('items_menu')
	characters_menu.visible = true
