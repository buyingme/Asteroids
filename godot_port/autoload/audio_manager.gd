extends Node
## Global audio manager for sound effects and music
## Handles loading, playing, and stopping sounds

# Audio players for different sounds
var fire_player: AudioStreamPlayer
var thrust_player: AudioStreamPlayer
var explode1_player: AudioStreamPlayer
var explode2_player: AudioStreamPlayer
var explode3_player: AudioStreamPlayer
var lsaucer_player: AudioStreamPlayer
var ssaucer_player: AudioStreamPlayer
var sfire_player: AudioStreamPlayer
var extralife_player: AudioStreamPlayer

func _ready():
	# Create audio stream players
	fire_player = _create_player("fire")
	thrust_player = _create_player("thrust")
	explode1_player = _create_player("explode1")
	explode2_player = _create_player("explode2")
	explode3_player = _create_player("explode3")
	lsaucer_player = _create_player("lsaucer")
	ssaucer_player = _create_player("ssaucer")
	sfire_player = _create_player("sfire")
	extralife_player = _create_player("extralife")

func _create_player(name: String) -> AudioStreamPlayer:
	"""Create and configure an audio stream player"""
	var player = AudioStreamPlayer.new()
	player.name = name + "_player"
	player.bus = "Master"
	add_child(player)
	return player

func play_sound(sound_name: String):
	"""Play a sound effect once"""
	var player = _get_player(sound_name)
	if player and player.stream:
		player.play()

func play_sound_continuous(sound_name: String):
	"""Play a sound effect in a loop"""
	var player = _get_player(sound_name)
	if player and player.stream:
		if not player.playing:
			player.stream.set_loop(true)
			player.play()

func stop_sound(sound_name: String):
	"""Stop a playing sound"""
	var player = _get_player(sound_name)
	if player:
		player.stop()

func _get_player(sound_name: String) -> AudioStreamPlayer:
	"""Get audio player by name"""
	match sound_name:
		"fire":
			return fire_player
		"thrust":
			return thrust_player
		"explode1":
			return explode1_player
		"explode2":
			return explode2_player
		"explode3":
			return explode3_player
		"lsaucer":
			return lsaucer_player
		"ssaucer":
			return ssaucer_player
		"sfire":
			return sfire_player
		"extralife":
			return extralife_player
	return null

func load_sound(sound_name: String, path: String):
	"""Load a sound file"""
	var player = _get_player(sound_name)
	if player and FileAccess.file_exists(path):
		player.stream = load(path)
