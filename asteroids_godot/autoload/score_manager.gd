extends Node
## Score and lives management
## Global state for player progress

signal score_changed(new_score: int)
signal lives_changed(new_lives: int)
signal game_over

var score: int = 0
var lives: int = 0
var high_scores: Array = [
	{"name": "ACE", "score": 20000},
	{"name": "SND", "score": 10000},
	{"name": "TRD", "score": 5000}
]
var next_extra_life: int = 10000

func reset_game():
	"""Reset score and lives for new game"""
	score = 0
	lives = 3
	next_extra_life = 10000
	score_changed.emit(score)
	lives_changed.emit(lives)

func add_score(points: int):
	"""Add points to score"""
	score += points
	score_changed.emit(score)
	
	# Check for extra life
	if score >= next_extra_life:
		add_life()
		next_extra_life += 10000

func add_life():
	"""Add an extra life"""
	lives += 1
	lives_changed.emit(lives)
	AudioManager.play_sound("extra_life")

func lose_life():
	"""Remove a life"""
	lives -= 1
	lives_changed.emit(lives)
	if lives <= 0:
		game_over.emit()

func is_high_score() -> bool:
	"""Check if current score qualifies for high score table"""
	return score > high_scores[2]["score"]

func add_high_score(name: String):
	"""Add current score to high score table"""
	var new_entry = {"name": name, "score": score}
	high_scores.append(new_entry)
	high_scores.sort_custom(func(a, b): return a["score"] > b["score"])
	high_scores = high_scores.slice(0, 3)
	save_high_scores()

func save_high_scores():
	"""Save high scores to file"""
	var file = FileAccess.open("user://highscores.dat", FileAccess.WRITE)
	if file:
		file.store_var(high_scores)
		file.close()

func load_high_scores():
	"""Load high scores from file"""
	if FileAccess.file_exists("user://highscores.dat"):
		var file = FileAccess.open("user://highscores.dat", FileAccess.READ)
		if file:
			high_scores = file.get_var()
			file.close()
