extends Control

@onready var high_score_label = $CenterContainer/VBoxContainer/HighScoreLabel
@onready var title = $CenterContainer/VBoxContainer/Title
@onready var instructions = [
	$CenterContainer/VBoxContainer/Instructions1,
	$CenterContainer/VBoxContainer/Instructions2,
	$CenterContainer/VBoxContainer/Instructions3,
	$CenterContainer/VBoxContainer/Instructions4,
	$CenterContainer/VBoxContainer/Instructions5
]

var blink_timer = 0.0
var show_instructions = true

func _ready():
	# Update high score display
	update_high_score()
	
	# Connect to score manager signals
	ScoreManager.high_score_changed.connect(_on_high_score_changed)
	
	# Style the title
	title.add_theme_font_size_override("font_size", 48)
	
	# Style instructions
	for label in instructions:
		label.add_theme_font_size_override("font_size", 16)
	
	high_score_label.add_theme_font_size_override("font_size", 20)

func _process(delta):
	# Blink instructions
	blink_timer += delta
	if blink_timer >= 0.5:
		blink_timer = 0.0
		show_instructions = !show_instructions
		
		for label in instructions:
			label.visible = show_instructions
	
	# Check for start input
	if Input.is_action_just_pressed("fire"):
		start_game()

func start_game():
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func update_high_score():
	high_score_label.text = "HIGH SCORE: %d" % ScoreManager.high_score

func _on_high_score_changed(new_high_score):
	update_high_score()
