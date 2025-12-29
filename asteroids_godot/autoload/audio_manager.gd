extends Node
## Audio management system
## Handles all game sound effects and music

var sounds = {}
var continuous_sounds = {}

func _ready():
	# Create audio players for each sound
	create_sound("fire", "res://assets/sounds/fire.wav")
	create_sound("explode1", "res://assets/sounds/explode1.wav")
	create_sound("explode2", "res://assets/sounds/explode2.wav")
	create_sound("explode3", "res://assets/sounds/explode3.wav")
	create_sound("thrust", "res://assets/sounds/thrust.wav")
	create_sound("saucer_fire", "res://assets/sounds/sfire.wav")
	create_sound("large_saucer", "res://assets/sounds/lsaucer.wav")
	create_sound("small_saucer", "res://assets/sounds/ssaucer.wav")
	create_sound("extra_life", "res://assets/sounds/life.wav")

func create_sound(sound_name: String, path: String):
	"""Create an AudioStreamPlayer for a sound"""
	var player = AudioStreamPlayer.new()
	player.name = sound_name
	add_child(player)
	
	# Try to load the audio file
	if FileAccess.file_exists(path):
		player.stream = load(path)
	
	sounds[sound_name] = player

func play_sound(sound_name: String):
	"""Play a one-shot sound effect"""
	if sound_name in sounds:
		sounds[sound_name].play()

func play_continuous(sound_name: String):
	"""Play a looping sound"""
	if sound_name in sounds:
		var player = sounds[sound_name]
		if not player.playing:
			player.stream.loop = true
			player.play()
		continuous_sounds[sound_name] = player

func stop_sound(sound_name: String):
	"""Stop a playing sound"""
	if sound_name in sounds:
		sounds[sound_name].stop()
	if sound_name in continuous_sounds:
		continuous_sounds.erase(sound_name)
