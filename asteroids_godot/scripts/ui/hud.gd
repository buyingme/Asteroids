extends CanvasLayer
## HUD display for score and lives

@onready var score_label = $ScoreLabel
@onready var lives_container = $LivesContainer

func _ready():
	ScoreManager.score_changed.connect(_on_score_changed)
	ScoreManager.lives_changed.connect(_on_lives_changed)
	
	# Initialize display
	_on_score_changed(ScoreManager.score)
	_on_lives_changed(ScoreManager.lives)

func _on_score_changed(new_score: int):
	"""Update score display"""
	score_label.text = "%05d" % new_score

func _on_lives_changed(new_lives: int):
	"""Update lives display"""
	# Clear existing life icons
	for child in lives_container.get_children():
		child.queue_free()
	
	# Create life icons (mini ships)
	for i in range(new_lives - 1):  # -1 because current ship doesn't count
		var life_icon = Control.new()
		life_icon.custom_minimum_size = Vector2(30, 30)
		life_icon.draw.connect(_draw_life_icon.bind(life_icon))
		lives_container.add_child(life_icon)

func _draw_life_icon(icon: Control):
	"""Draw a small ship icon for a life"""
	var points = PackedVector2Array([
		Vector2(15, 5),
		Vector2(21, 20),
		Vector2(18, 17),
		Vector2(12, 17),
		Vector2(9, 20)
	])
	icon.draw_polyline(points, Color.WHITE, 1.0, true)
