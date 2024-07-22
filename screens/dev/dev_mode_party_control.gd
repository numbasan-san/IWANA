class_name DevPartyControl extends HBoxContainer

@export var party_slots: HBoxContainer

var dev: DevMode

func enable():
	Player.control_changed.connect(func(char):
		set_text(0, char.char_name.to_pascal_case()))
	Player.control_removed.connect(func():
		set_text(0, "Vacio"))
	Player.control_changed.connect(func(char):
		reset_party())
	Player.control_removed.connect(func():
		remove_party())
	reset_party()

func get_slot(index: int) -> VBoxContainer:
	if index < party_slots.get_child_count():
		return party_slots.get_children()[index]
	else:
		return null

func set_text(index: int, name: String):
	var char_button = get_slot(index).get_node("Character")
	char_button.text = name

func enable_button(index: int, value: bool):
	var button = get_slot(index).get_node("Remove")
	button.disabled = not value

func reset_party():
	remove_party()
	if Player.character:
		set_text(0, Player.character.char_name)
		adjust_slots(Player.party.size)
		var idx = 1
		for m in Player.party.members:
			if m != Player.character:
				set_character(idx, m)
				idx += 1
			
func remove_party():
	var idx = 1
	while idx < party_slots.get_child_count():
		reset_slot(idx)
		idx += 1

func adjust_slots(value: int):
	if value > party_slots.get_child_count():
		add_slots(value)
	elif value < party_slots.get_child_count():
		remove_slots(value)

func add_slots(up_to: int):
	if up_to < 1:
		return
	var n = party_slots.get_child_count()
	while n < up_to:
		add_slot()
		n += 1

func remove_slots(down_to: int):
	if down_to < 1:
		return
	var n = party_slots.get_child_count() - 1
	while n >= down_to:
		party_slots.get_child(n).free
		n -= 1

func add_slot():
	var slot = party_slots.get_child(0).duplicate(7)
	party_slots.add_child(slot)
	slot.get_node("Character").text = "Vacio"
	slot.get_node("Character").disabled = false
	var rem_button = slot.get_node("Remove") as Button
	rem_button.disabled = false

func set_character(idx: int, character: Character):
	reset_slot(idx, false)
	var slot = party_slots.get_child(idx)
	slot.get_node("Character").disabled = true
	set_text(idx, character.char_name)
	clear_character_list(idx)
	connect_button(idx, character)
	
func connect_button(idx: int, character: Character):
	var rem_button = party_slots.get_child(idx).get_node("Remove") as Button
	rem_button.disabled = false
	rem_button.button_up.connect(func():
		Player.party.remove(character)
		reset_slot(idx))

func reset_button(idx: int):
	var rem_button = party_slots.get_child(idx).get_node("Remove") as Button
	rem_button.disabled = true
	var sig = rem_button.button_up as Signal
	for conn in sig.get_connections():
		sig.disconnect(conn["callable"])

func reset_slot(idx: int, fill_list: bool = true):
	set_text(idx, "Vacio")
	var slot = party_slots.get_child(idx)
	slot.get_node("Character").disabled = false
	if fill_list:
		fill_characters_list(idx)
	reset_button(idx)

func fill_characters_list(idx: int):
	clear_character_list(idx)
	var char_menu = party_slots.get_child(idx).get_node("Character")
	var popup: PopupMenu = char_menu.get_popup()
	
	popup.add_theme_font_size_override("font_size", 30)
	# Esta variable es necesaria porque varias funciones de popup requieren el índice del ítem,
	# pero al agregar un ítem la función no devuelve su índice asignado, por lo que necesitamos
	# asignar manualmente un id y obtener el índice a través de ese id
	var item_id = 0
	CharacterManager.load_all()
	for char_name in CharacterManager.characters:
		var char = CharacterManager.load(char_name)
		popup.add_item(char.char_name.to_pascal_case(), item_id)
		var index = popup.get_item_index(item_id)
		item_id += 1
		popup.set_item_metadata(index, char)
		
	# Al conectar esta señal asumimos que nunca se conectará a otra función fuera de este script.
	# Si esto cambia en algún momento, necesitamos arreglar este código
	if popup.index_pressed.get_connections().size() == 0:
		popup.index_pressed.connect(func (index) -> void:
			var char = popup.get_item_metadata(index)
			Player.party.add(char, true)
			set_character(idx, char)
		)

func clear_character_list(idx: int):
	var char_menu = party_slots.get_child(idx).get_node("Character")
	var popup: PopupMenu = char_menu.get_popup()
	popup.clear()
