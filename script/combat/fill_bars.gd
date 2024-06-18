class_name FillBars extends Control

@export var health_bar: ProgressBar
@export var energy_bar: ProgressBar
@export var health_value: Label
@export var energy_value: Label

@export var container: Control

func _update_max_health(_old: int, new: int):
	var current = container.character.stats.health
	health_bar.max_value = new
	health_bar.value = current
	health_value.text = str(current) + "/" + str(new)
	
func _update_health(_old: int, new: int):
	var max = container.character.stats.max_health
	health_bar.max_value = max
	health_bar.value = new
	health_value.text = str(new) + "/" + str(max)

func _update_max_energy(_old: int, new: int):
	var current = container.character.stats.energy
	energy_bar.max_value = new
	energy_bar.value = current
	energy_value.text = str(current) + "/" + str(new)
	
func _update_energy(_old: int, new: int):
	var max = container.character.stats.max_energy
	energy_bar.max_value = max
	energy_bar.value = new
	energy_value.text = str(new) + "/" + str(max)
