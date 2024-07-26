class_name FillBars extends Control

@export var slot: int = 0

@export var health_bar: TextureProgressBar
@export var energy_bar: TextureProgressBar
@export var health_value: Label
@export var energy_value: Label

@export var container: Control

# This is used instead of _ready so that the parent is
# initialized first and it can pass its slot variable
# to this node
func _enter_tree():
	if slot == 1 or slot == 3:
		health_bar = $Health1
		health_value = $Health1/Label
		$Health1.show()
		$Health2.hide()
		energy_bar = $Energy1
		energy_value = $Energy1/Label
		$Energy1.show()
		$Energy2.hide()
	else:
		health_bar = $Health2
		health_value = $Health2/Label
		$Health2.show()
		$Health1.hide()
		energy_bar = $Energy2
		energy_value = $Energy2/Label
		$Energy2.show()
		$Energy1.hide()

func _update_max_health(_old: int, new: int):
	var current = container.character.stats.health
	health_bar.max_value = new
	health_bar.value = current
	health_value.text = str(current)
	
func _update_health(_old: int, new: int):
	var max = container.character.stats.max_health
	health_bar.max_value = max
	health_bar.value = new
	health_value.text = str(new)

func _update_max_energy(_old: int, new: int):
	var current = container.character.stats.energy
	energy_bar.max_value = new
	energy_bar.value = current
	energy_value.text = str(current)
	
func _update_energy(_old: int, new: int):
	var max = container.character.stats.max_energy
	energy_bar.max_value = max
	energy_bar.value = new
	energy_value.text = str(new)
