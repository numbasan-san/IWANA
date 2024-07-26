extends Control

var zone: Zone
var current_zone: Zone
var intro_played: bool = false

# Called when the node enters the scene tree for the first time.
func intro():
	if zone:
		if not intro_played:
			$Animation.stop()
			$Animation.play("intro")
			intro_played = true
		$Panel/Label.text = zone.room_info.name
	else:
		print('No zone.')

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	zone = Player.zone
	
	# Check if the zone has changed
	if zone != current_zone:
		current_zone = zone
		intro_played = false  # Reset intro_played to allow animation if zone changes
		intro()
	else:
		# Update label text without playing animation
		if zone:
			$Panel/Label.text = zone.room_info.name
		else:
			print('No zone.')
