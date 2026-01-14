class_name AudioPlayer extends Node

@export var music: Array[Track]

@export var animator: AnimationPlayer
@export var player: AudioStreamPlayer

# The currently playing track
@export var current_track: Track = null:
	set(value):
		current_track = value
		player.stream = value.stream
		player.volume_db = general_volume

# We use these variables to remember the volume to restore it after fading
var top_volume: float = -5
var bottom_volume: float = -60

# Volume shared between all tracks registered with the manager
var general_volume: float = bottom_volume:
	set(value):
		general_volume = value
		player.volume_db = value

var is_paused: bool = false:
	set(value):
		is_paused = value
		player.stream_paused = value

# Changes the current track without stoping or playing.
# This seaches the music array for a resource that has the given track_name
func set_track(new_track: String):
	var found_tracks = music.filter(
		func(track: Track): return track.track_name == new_track)
	if found_tracks.size() == 1:
		current_track = found_tracks[0]
	elif found_tracks.size() == 0:
		printerr(get_parent().name + " AudioPlayer | Song with name " + new_track \
			+ " not found")
	else:
		printerr(get_parent().name + " AudioPlayer | Too many resources with name " \
			+ new_track + " found. We don't know which one to choose")

# If new_track is empty, this attempts to play the current track, if it is
# stopped or paused. If not empty, it first attempts to change the current track
# before playing. The fade variable is the name of a predefined animation that
# determines how the audio will play
func play(fade: String = "1 sec", new_track: String = ""):
	if new_track:
		if current_track and current_track.track_name == new_track:
			printerr(get_parent().name + " AudioPlayer | The track " + new_track \
				+ " is already playing, no change was made")
		else:
			if current_track:
				stop(fade)
			set_track(new_track)
			if current_track:
				play(fade)
	else:
		if player.playing and not is_paused:
			return
		elif not player.playing:
			player.playing = true
		# If the player is paused, it is already at the minimum volume, so we can
		else:
			pause(false, fade)
		if not animator.has_animation("Play/" + fade):
			printerr(get_parent().name + " AudioPlayer | No play animation with name "\
				+ fade + ". Using default 'No Fade'")
			fade = "No Fade"
		animator.play("Play/" + fade)
		await animator.animation_finished

func stop(fade: String = "1 sec"):
	if not animator.has_animation("Stop/" + fade):
		printerr(get_parent().name + " AudioPlayer | No stop animation with name "\
			+ fade + ". Using default 'No Fade'")
		fade = "No Fade"
	animator.play("Stop/" + fade)
	await animator.animation_finished
	pause(false, fade)
	player.stop()

func pause(value: bool = true, fade: String = "1 sec"):
	if value != is_paused:
		if value:
			if not animator.has_animation("Stop/" + fade):
				printerr(get_parent().name + " AudioPlayer | No stop animation with name "\
					+ fade + ". Using default 'No Fade'")
				fade = "No Fade"
			animator.play("Stop/" + fade)
			await animator.animation_finished
			is_paused = value
		else:
			if not animator.has_animation("Play/" + fade):
				printerr(get_parent().name + " AudioPlayer | No play animation with name "\
					+ fade + ". Using default 'No Fade'")
				fade = "No Fade"
			is_paused = value
			animator.play("Play/" + fade)
			await animator.animation_finished
	
# Sets the track volume and also sets the target volume the manager must reach
# after performing fades
func volume(db: float):
	general_volume = db
	top_volume = db

func silence(value: bool = true):
	if value:
		general_volume = bottom_volume
	else:
		general_volume = top_volume
