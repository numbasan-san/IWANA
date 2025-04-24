## Helper class that has some commonly used functions related to menu buttons used
## in dev mode.
class_name DevPopupMenu extends MenuButton

## Fills the popup menu with the values in the dictionary and applies the function
## on_click when clicking in one of the items.
##
## The dictionary is made of pairs { name: metadata } and on_click must receive
## an the same metadata as argument .
func fill_contents(contents: Dictionary, on_click: Callable):
	var popup: PopupMenu = get_popup()
	# We assume that every time fill_contents is called it's because the list must
	# be regenerated, so we clear the old contents.
	popup.clear()
	popup.add_theme_font_size_override("font_size", 30)
	# Esta variable es necesaria porque varias funciones de popup requieren el índice del ítem,
	# pero al agregar un ítem la función no devuelve su índice asignado, por lo que necesitamos
	# asignar manualmente un id y obtener el índice a través de ese id
	var id = 0
	for elem in contents:
		popup.add_item(elem, id)
		var index = popup.get_item_index(id)
		popup.set_item_metadata(index, contents[elem])
		id += 1
		
	# Al conectar esta señal asumimos que nunca se conectará a otra función fuera de este script.
	# Si esto cambia en algún momento, necesitamos arreglar este código
	if popup.index_pressed.get_connections().size() == 0:
		popup.index_pressed.connect(func (index) -> void:
			var meta = popup.get_item_metadata(index)
			on_click.call(meta)
		)
