extends Control

@onready var final_score_label = $CenterContainer/VBoxContainer/FinalScoreLabel
@onready var game_over_label = $CenterContainer/VBoxContainer/GameOverLabel
@onready var continue_label = $CenterContainer/VBoxContainer/ContinueLabel
@onready var return_timer = $ReturnTimer

var can_continue = false
var blink_timer = 0.0
var show_continue = true

func _ready():
	# Style labels
	game_over_label.add_theme_font_size_override("font_size", 48)
	final_score_label.add_theme_font_size_override("font_size", 24)
	continue_label.add_theme_font_size_override("font_size", 16)
	
	# Update score
	final_score_label.text = "SCORE: %d" % ScoreManager.score
	
	# Hide continue label initially
	continue_label.visible = false

func _process(delta):
	if can_continue:
		# Blink continue label
		blink_timer += delta
		if blink_timer >= 0.5:
			blink_timer = 0.0
			show_continue = !show_continue
			continue_label.visible = show_continue
		
		# Check for continue input
		if Input.is_action_just_pressed("fire"):
			return_to_menu()

func _on_return_timer_timeout():
	can_continue = true
	continue_label.visible = true

func return_to_menu():
	get_tree().change_scene_to_file("res://scenes/ui/menu.tscn")
