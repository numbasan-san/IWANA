extends Control

# menu and menu's elements settings
func menus_setting(audio, video, inputs):
	$Panel/VContainer/settings/Audio.visible = audio
	$Panel/VContainer/settings/Video.visible = video
	$Panel/VContainer/settings/Inputs.visible = inputs

func _ready():
	menus_setting(false, false, false)

func _on_audio_pressed():
	var selected_menu = self.get_parent()
	var audio = selected_menu.get_node('Panel/VContainer/settings/Audio')
	menus_setting(true, false, false)

func _on_video_pressed():
	var selected_menu = self.get_parent()
	var video = selected_menu.get_node('Panel/VContainer/settings/Video')
	menus_setting(false, true, false)

func _on_controls_pressed():
	var selected_menu = self.get_parent()
	var video = selected_menu.get_node('Panel/VContainer/settings/Inputs')
	menus_setting(false, false, true)

