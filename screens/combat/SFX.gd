class_name SFXPlayer
extends Node

@export var stream_player: AudioStreamPlayer
@export var sounds: Array[SFXResource]
var poly: AudioStreamPlaybackPolyphonic
var sound_dict: Dictionary

func _ready() -> void:
	# Verificar que stream_player existe y tiene un stream
	if stream_player:
		# Asegurar que el stream_player tenga un stream para poder obtener el playback
		if not stream_player.stream:
			# Crear un stream polifónico por defecto si no tiene
			stream_player.stream = AudioStreamPolyphonic.new()
		
		# Obtener el playback
		poly = stream_player.get_stream_playback()
		
		# Verificar que poly no sea null
		if poly == null:
			push_error("SFXPlayer | Could not get stream playback. Make sure the AudioStreamPlayer is properly configured.")
	else:
		push_error("SFXPlayer | stream_player is not assigned in the inspector.")
	
	# Cargar los sonidos en el diccionario
	for s in sounds:
		if s and s.track_name != "":
			sound_dict[s.track_name] = s.stream
		else:
			push_warning("SFXPlayer | A sound resource has no track_name or is null.")

func play(name: String):
	# Verificar que poly existe antes de usarlo
	if poly == null:
		push_error("SFXPlayer | Cannot play sound '" + name + "' because poly is null.")
		return
	
	# Verificar que el sonido existe en el diccionario
	if not sound_dict.has(name):
		push_error("SFXPlayer | Sound '" + name + "' not found in sound_dict.")
		return
	
	var stream = sound_dict[name]
	if stream == null:
		push_error("SFXPlayer | Sound '" + name + "' has a null stream.")
		return
	
	# Verificar que poly.play_stream existe
	if poly.has_method("play_stream"):
		poly.play_stream(stream)
	else:
		push_error("SFXPlayer | poly does not have 'play_stream' method.")

# Función para reproducir con verificación adicional
func play_safe(name: String, volume_db: float = 0.0):
	if poly == null or not sound_dict.has(name):
		return
	
	var stream = sound_dict[name]
	if stream == null:
		return
	
	# Reproducir con volumen ajustado si se especifica
	if volume_db != 0.0:
		var original_volume = stream_player.volume_db
		stream_player.volume_db = volume_db
		poly.play_stream(stream)
		stream_player.volume_db = original_volume
	else:
		poly.play_stream(stream)

# Función para verificar si un sonido está disponible
func has_sound(name: String) -> bool:
	return sound_dict.has(name)

# Función para obtener la lista de sonidos disponibles
func get_sound_list() -> Array[String]:
	var list: Array[String] = []
	for key in sound_dict.keys():
		list.append(key)
	return list

# Función para detener todos los sonidos
func stop_all():
	if poly:
		poly.stop_all_streams()

# Función para pausar todos los sonidos
func pause_all():
	if poly:
		poly.set_stream_paused(true)

# Función para reanudar todos los sonidos
func resume_all():
	if poly:
		poly.set_stream_paused(false)
