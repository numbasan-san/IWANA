extends Area2D


# Called when the node enters the scene tree for the first time.
func arcade_area():
	var undyne = get_node('/root/ScreenManager/RPGScreen/undyne/undyne')
	if undyne != null:
		print("existe")
	else:
		print("no existe")
