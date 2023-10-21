
extends "res://Script/inventario_objetos/items/collectable.gd"

@onready var anim = $AnimationPlayer

func collect(inventory : Inventory):
	anim.play("taked")
	await anim.animation_finished
	super(inventory)
