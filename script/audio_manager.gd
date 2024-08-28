extends Node

@export var music: Dictionary

@export var screen_audio: Dictionary

var player: AudioStreamPlayer = AudioStreamPlayer.new()

# The currently playing track
var current_track: Track = null:
	set(value):
		current_track = value
		player.stream = value.stream
		player.volume_db = general_volume

# Volume shared between all tracks registered with the manager
var general_volume: float = -5:
	set(value):
		general_volume = value
		player.volume_db = value

# We use these variables to remember the volume to restore it after fading
var top_volume: float = -5
var bottom_volume: float = -60

var is_paused: bool = false

# Duration of fade in and out transitions, in seconds
var fade_duration: float = 1

# The fade operations each create a tween, which should be stored here. When a
# new fade operation starts should check if this has a working tween, and if so
# it should wait for it to finish before replacing it. This is done to avoid
# race conditions
var tween: Tween

# Changes the current track without reproducing it. Restores the old track to a
# default state so it can be used later
func set_track(new_track: String):
	if music.has(new_track):
		var track = music.get(new_track)
		current_track = track

# If calling just play(), the current track is unpaused or its played from
# the beginning if it was stopped. If a track is passed, the manager switches
# to the new track and starts playing
func play(new_track: String = "", fade: bool = true):
	if new_track:
		if music.has(new_track):
			await stop(fade)
			set_track(new_track)
			await play("", fade)
		else:
			printerr("AudioManager | There is no song registered with name " \
				+ new_track)
	else:
		if current_track:
			if player.playing and is_paused:
				pause(false, fade)
			elif not player.playing:
				if fade:
					await _fade_in(player.play)
				else:
					player.play()
		else:
			printerr("AudioManager | Can't play a track as there is none selected")

#TODO temporary function to play songs associated to a particular screen. Change
# this later for a more flexible approach
func play_screen(screen: StringName, fade: bool = true):
	if screen_audio.has(screen):
		var track = screen_audio.get(screen)
		play(track, fade)
	else:
		printerr("AudioManager | The screen " + screen + " isn't associated to a track")

func pause(value: bool = true, fade: bool = true):
	if current_track:
		if fade:
			var callback = func ():
				player.stream_paused = value
			if value:
				await _fade_out(callback)
			else:
				await _fade_in(callback)
		else:
			player.stream_paused = value
	is_paused = value

func stop(fade: bool = true):
	if current_track:
		if fade:
			await _fade_out(player._set_playing.bind(false))
		else:
			player.playing = false
		is_paused = false

# Sets the track volume and also sets the target volume the manager must reach
# after performing fades
func volume(db: float):
	general_volume = db
	top_volume = db

# Used to change the volume when using fades, it doesn't change the top volume
func _fade_volume(db: float):
	general_volume = db

# Performs volume fading in for play and unpause. c_in will be called before 
# performing the fade. If from is greater than to, it will be used without
# fading
func _fade_in(c_in: Callable, duration: float = fade_duration):
	var from = bottom_volume
	var to = top_volume
	if from > to:
		to = from
	tween = create_tween()
	tween.tween_callback(c_in)
	tween.tween_method(_fade_volume, from, to, duration)
	await tween.finished
	

# Performs volume fading out for stop and pause. c_out will be called after 
# performing the fade. If from is less than to, it will be used without fading
func _fade_out(c_out: Callable, duration: float = fade_duration):
	var from = top_volume
	var to = bottom_volume
	if from < to:
		to = from
	var tween = create_tween()
	tween.tween_method(_fade_volume, from, to, duration)
	tween.tween_callback(c_out)
	await tween.finished

func silence(value: bool = true):
	if value:
		general_volume = bottom_volume
	else:
		general_volume = top_volume
