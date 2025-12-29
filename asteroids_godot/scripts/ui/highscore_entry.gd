extends Control

@onready var score_label = $CenterContainer/VBoxContainer/ScoreLabel
@onready var initials_label = $CenterContainer/VBoxContainer/InitialsLabel
@onready var new_high_score_label = $CenterContainer/VBoxContainer/NewHighScoreLabel
@onready var enter_initials_label = $CenterContainer/VBoxContainer/EnterInitialsLabel
@onready var instructions_label = $CenterContainer/VBoxContainer/InstructionsLabel

var initials = ["_", "_", "_"]
var current_position = 0
var blink_timer = 0.0
var show_cursor = true

func _ready():
	# Style labels
	new_high_score_label.add_theme_font_size_override("font_size", 36)
	score_label.add_theme_font_size_override("font_size", 24)
	enter_initials_label.add_theme_font_size_override("font_size", 20)
	initials_label.add_theme_font_size_override("font_size", 48)
	instructions_label.add_theme_font_size_override("font_size", 16)
	
	# Update score
	score_label.text = "SCORE: %d" % ScoreManager.score
	
	update_initials_display()

func _process(delta):
	# Blink cursor
	blink_timer += delta
	if blink_timer >= 0.3:
		blink_timer = 0.0
		show_cursor = !show_cursor
		update_initials_display()
	
	# Handle input
	if Input.is_action_just_pressed("ui_accept"):  # Enter
		if current_position == 3:
			submit_initials()
	
	# Letter selection
	if Input.is_action_just_pressed("ui_up"):
		cycle_letter(1)
	elif Input.is_action_just_pressed("ui_down"):
		cycle_letter(-1)
	elif Input.is_action_just_pressed("ui_right"):
		if current_position < 2:
			current_position += 1
			update_initials_display()
	elif Input.is_action_just_pressed("ui_left"):
		if current_position > 0:
			current_position -= 1
			update_initials_display()
	
	# Direct letter input
	var key_event = Input.get_action_strength("ui_text_input")
	if Input.is_anything_pressed():
		for i in range(65, 91):  # A-Z
			var key = char(i)
			if Input.is_physical_key_pressed(i):
				initials[current_position] = key
				if current_position < 2:
					current_position += 1
				else:
					current_position = 3
				update_initials_display()
				break

func cycle_letter(direction: int):
	if current_position < 3:
		var current_char = initials[current_position]
		var char_code = 65  # Start with 'A'
		
		if current_char != "_":
			char_code = current_char.unicode_at(0)
		
		char_code += direction
		
		# Wrap around A-Z
		if char_code < 65:
			char_code = 90
		elif char_code > 90:
			char_code = 65
		
		initials[current_position] = char(char_code)
		update_initials_display()

func update_initials_display():
	var display_text = ""
	for i in range(3):
		if i == current_position and show_cursor and current_position < 3:
			display_text += "[" + initials[i] + "]"
		else:
			display_text += " " + initials[i] + " "
	
	initials_label.text = display_text
	
	# Check if all positions filled
	if current_position == 3 or (initials[0] != "_" and initials[1] != "_" and initials[2] != "_"):
		current_position = 3

func submit_initials():
	# Save high score with initials
	var initials_string = ""
	for initial in initials:
		if initial != "_":
			initials_string += initial
		else:
			initials_string += " "
	
	# TODO: Save to high score table
	# For now, just save the high score
	ScoreManager.high_score = ScoreManager.score
	
	# Return to menu
	get_tree().change_scene_to_file("res://scenes/ui/menu.tscn")
