extends AudioStreamPlayer

# An audio track can be split into seveal segments, each with a name, a beginning
# time and an ending time. If a specific segment is set to loop, it will play
# from its beginning to its end continuously
@export var segments: Dictionary

# The segment of the track that is currently playing. If it is empty or null, the
# entire track must play from start to finish
var current_segment: String = ""

# The starting time of the current segment. It should be changed every time the
# current segment changes. Every time the stream is restarted it must start from
# this point
var _start: float

# The ending time of the current segment. It should be changed every time the
# current segment changes. Every time the stream reaches this time it must restart
# from _start
var _end: float

# The segment of the track that will play after the current segment reaches its
# final frame. If it's empty or null, after this segment the entire track will
# play from start to finish. If it's equal to the current segment, the segment
# will loop
var next_segment: String = ""

func _ready():
	# The first time this is called, it will only set the start and end times,
	# but it won't change the current segment
	set_current_segment(current_segment)

func _process(delta):
	# We reached the end of the segment
	if get_playback_position() >= _end:
		# If the next segment is different to the current one, we switch
		if next_segment != current_segment:
			set_current_segment(next_segment)
		# Whether we changed segments or not, we go to the start
		seek(_start)

# Function used to load the segments of the track via code. It will replace the
# old segment data
func load(values: Dictionary):
	segments = values

# Queues the given segment to be played when the current segment finishes
func set_next_segment(name: String):
	next_segment = name

# Sets the current segments and its corresponding start and end times
func set_current_segment(name: String):
	if not name:
		# If the next segment is empty, we play the entire track
		_start = 0
		_end = stream.get_length()
	else:
		_start = segments[name]["start"]
		_end = segments[name]["end"]
	current_segment = name
