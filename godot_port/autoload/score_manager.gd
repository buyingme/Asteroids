extends Node
## Global score and lives manager
## Maintains game state across scenes

signal score_changed(new_score: int)
signal lives_changed(new_lives: int)
signal extra_life_earned

var score: int = 0:
	set(value):
		score = value
		score_changed.emit(score)
		check_extra_life()

var lives: int = 3:
	set(value):
		lives = value
		lives_changed.emit(lives)

# Default high scores - single source of truth
const DEFAULT_HIGH_SCORES: Array = [
	{"name": "ACE", "score": 20000},
	{"name": "SND", "score": 10000},
	{"name": "TRD", "score": 5000}
]

var high_scores: Array = []

var next_extra_life: int = 10000

# High score entry state
var entering_high_score: bool = false
var high_score_position: int = -1
var high_score_initials: Array = [65, 65, 65]  # ASCII codes for 'AAA'
var current_initial_index: int = 0

const SAVE_PATH = "user://high_scores.save"

func _ready():
	# Initialize with defaults if no save file exists
	if not FileAccess.file_exists(SAVE_PATH):
		high_scores = DEFAULT_HIGH_SCORES.duplicate(true)
	load_high_scores()

func reset_game():
	"""Reset score and lives for new game"""
	score = 0
	lives = 3
	next_extra_life = 10000

func add_score(points: int):
	"""Add points to score"""
	print("ScoreManager.add_score called with points=%d, current score=%d" % [points, score])
	score += points
	print("New score: %d" % score)

func lose_life():
	"""Decrease life count"""
	if lives > 0:
		lives -= 1

func add_life():
	"""Increase life count"""
	lives += 1
	AudioManager.play_sound("extralife")

func check_extra_life():
	"""Check if player earned an extra life"""
	if score >= next_extra_life:
		add_life()
		next_extra_life += 10000
		extra_life_earned.emit()

func is_high_score(test_score: int) -> bool:
	"""Check if score qualifies for high score table"""
	return test_score > high_scores[2]["score"]

func start_high_score_entry(player_score: int):
	"""Start high score entry mode"""
	entering_high_score = true
	high_score_initials = [65, 65, 65]  # Reset to 'AAA'
	current_initial_index = 0
	
	# Determine position in high score table
	if player_score > high_scores[0]["score"]:
		high_score_position = 0
	elif player_score > high_scores[1]["score"]:
		high_score_position = 1
	else:
		high_score_position = 2

func finish_high_score_entry():
	"""Complete high score entry and update table"""
	if not entering_high_score:
		return
	
	var player_name = ""
	for ascii_code in high_score_initials:
		player_name += char(ascii_code)
	
	var player_score = score
	
	# Insert at correct position and shift others down
	if high_score_position == 0:
		high_scores[2] = high_scores[1]
		high_scores[1] = high_scores[0]
		high_scores[0] = {"name": player_name, "score": player_score}
	elif high_score_position == 1:
		high_scores[2] = high_scores[1]
		high_scores[1] = {"name": player_name, "score": player_score}
	else:
		high_scores[2] = {"name": player_name, "score": player_score}
	
	save_high_scores()
	entering_high_score = false
	high_score_position = -1

func add_high_score(player_name: String, player_score: int):
	"""Add new high score to table (legacy method)"""
	high_scores.append({"name": player_name, "score": player_score})
	high_scores.sort_custom(func(a, b): return a["score"] > b["score"])
	high_scores = high_scores.slice(0, 3)  # Keep top 3
	save_high_scores()

func save_high_scores():
	"""Save high scores to disk"""
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_var(high_scores)
		file.close()

func load_high_scores():
	"""Load high scores from disk"""
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			high_scores = file.get_var()
			file.close()

func reset_high_scores():
	"""Reset high scores to default values"""
	high_scores = DEFAULT_HIGH_SCORES.duplicate(true)
	save_high_scores()
	print("High scores reset to default values")
