class_name SFXPlayer extends Node

@export var stream_player: AudioStreamPlayer
@export var sounds: Array[SFXResource]
var poly: AudioStreamPlaybackPolyphonic
var sound_dict: Dictionary

func _ready() -> void:
	poly = stream_player.get_stream_playback()
	for s in sounds:
		sound_dict[s.track_name] = s.stream
	
func play(name: String):
	var stream = sound_dict[name]
	poly.play_stream(stream)
