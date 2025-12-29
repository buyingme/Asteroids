extends Node2D
## Main game manager - controls game flow and state
## Ported from Python asteroids.py

enum GameState { ATTRACT_MODE, PLAYING, EXPLODING, GAME_OVER, HIGHSCORE_SET }

var current_state: GameState = GameState.ATTRACT_MODE

# Game objects
var ship: Ship = null
var rocks: Array = []
var saucer: Saucer = null

# Game state
var exploding_count: int = 0
var exploding_ttl: int = 180
var game_over_timer: float = 0.0
var num_rocks: int = 3
var seconds_count: int = 1
var lives_display: Array = []

# Scenes
var ship_scene = preload("res://scenes/ship.tscn")
var rock_scene = preload("res://scripts/rock.gd")
var debris_scene = preload("res://scripts/debris.gd")

# UI references
var score_label: Label
var high_score_label: Label
var lives_label: Label

func _ready():
	# Get UI references
	score_label = $HUD/ScoreLabel
	high_score_label = $HUD/HighScoreLabel
	
	# Connect to ScoreManager signals
	ScoreManager.score_changed.connect(_on_score_changed)
	ScoreManager.lives_changed.connect(_on_lives_changed)
	
	# Initialize score manager
	ScoreManager.reset_game()
	
	# Update initial UI
	update_hud()
	
	# Start in attract mode
	print("GameManager _ready() - Setting state to ATTRACT_MODE")
	current_state = GameState.ATTRACT_MODE
	
	# Create rocks for attract mode (matches Python: createRocks(3) in __init__)
	create_rocks(3)
	
	display_title_screen()

func _process(_delta: float):
	# Handle ESC key to quit (matches Python: K_ESCAPE -> sys.exit(0))
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	
	seconds_count += 1
	
	# Saucer logic runs in all states (matches Python main loop)
	do_saucer_logic()
	
	# Debug: print state every 60 frames
	if seconds_count % 60 == 0:
		print("Current state: %s" % GameState.keys()[current_state])
	
	match current_state:
		GameState.ATTRACT_MODE:
			handle_attract_mode()
		GameState.PLAYING:
			handle_playing()
		GameState.EXPLODING:
			handle_exploding()
		GameState.GAME_OVER:
			handle_game_over()
	
	# Handle high score entry (can happen during GAME_OVER state)
	if ScoreManager.entering_high_score:
		handle_high_score_entry()

func handle_attract_mode():
	"""Handle attract mode input"""
	if Input.is_action_just_pressed("start_game"):
		print("Start game pressed!")
		# Consume the input event to prevent ship from firing
		Input.action_release("fire")
		Input.action_release("ui_accept")
		start_new_game()
	# Also check for Space/Fire as alternative
	elif Input.is_action_just_pressed("fire") or Input.is_action_just_pressed("ui_accept"):
		print("Fire/Accept pressed - starting game")
		# Consume the input event to prevent ship from firing
		Input.action_release("fire")
		Input.action_release("ui_accept")
		start_new_game()
	# Reset high scores with Shift+R
	if Input.is_physical_key_pressed(KEY_SHIFT) and Input.is_physical_key_pressed(KEY_R):
		ScoreManager.reset_high_scores()
		display_title_screen()  # Refresh the display

func handle_playing():
	"""Handle main gameplay"""
	if not ship:
		return
	
	# Check collisions
	check_collisions()
	
	# Check for extra life
	check_extra_life()
	
	# Check if level complete
	if rocks.size() == 0:
		level_up()
	
	# Check if game over
	if ScoreManager.lives <= 0:
		game_over()

func handle_exploding():
	"""Handle ship explosion state"""
	exploding_count += 1
	
	if exploding_count > exploding_ttl:
		current_state = GameState.PLAYING
		exploding_count = 0
		
		if ScoreManager.lives <= 0:
			game_over()
		else:
			create_new_ship()

func handle_game_over():
	"""Handle game over state"""
	# Check if we should enter high score entry mode
	if not ScoreManager.entering_high_score and ScoreManager.is_high_score(ScoreManager.score):
		ScoreManager.start_high_score_entry(ScoreManager.score)
		show_high_score_entry_screen()
		return
	
	# If not entering high score, auto-return to attract mode after 3 seconds
	if not ScoreManager.entering_high_score:
		game_over_timer += get_process_delta_time()
		if game_over_timer >= 3.0:
			game_over_timer = 0.0
			current_state = GameState.ATTRACT_MODE
			display_title_screen()

func handle_high_score_entry():
	"""Handle high score name entry input"""
	if Input.is_action_just_pressed("ui_up"):
		# Increment letter (A-Z)
		if ScoreManager.high_score_initials[ScoreManager.current_initial_index] < 90:
			ScoreManager.high_score_initials[ScoreManager.current_initial_index] += 1
		update_high_score_entry_display()
	
	elif Input.is_action_just_pressed("ui_down"):
		# Decrement letter (A-Z)
		if ScoreManager.high_score_initials[ScoreManager.current_initial_index] > 65:
			ScoreManager.high_score_initials[ScoreManager.current_initial_index] -= 1
		update_high_score_entry_display()
	
	elif Input.is_action_just_pressed("ui_right"):
		# Move to next letter
		if ScoreManager.current_initial_index < 2:
			ScoreManager.current_initial_index += 1
		update_high_score_entry_display()
	
	elif Input.is_action_just_pressed("ui_left"):
		# Move to previous letter
		if ScoreManager.current_initial_index > 0:
			ScoreManager.current_initial_index -= 1
		update_high_score_entry_display()
	
	elif Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("start_game"):
		# Confirm entry
		ScoreManager.finish_high_score_entry()
		hide_high_score_entry_screen()
		current_state = GameState.ATTRACT_MODE
		display_title_screen()

func start_new_game():
	"""Initialize new game"""
	current_state = GameState.PLAYING
	
	# Hide title screen
	var title_screen = get_node("HUD/TitleScreen")
	if title_screen:
		title_screen.visible = false
	
	# Show HUD elements
	if score_label:
		score_label.visible = true
	if high_score_label:
		high_score_label.visible = true
	# Lives will be shown by create_lives_list()
	
	# Clear old objects
	clear_game_objects()
	
	# Reset scores and lives
	ScoreManager.reset_game()
	
	# Create ship
	create_new_ship()
	
	# Create lives display
	create_lives_list()
	
	# Create initial rocks
	num_rocks = 3
	create_rocks(num_rocks)
	
	seconds_count = 1

func create_new_ship():
	"""Create player ship"""
	if ship:
		ship.queue_free()
	
	ship = ship_scene.instantiate()
	add_child(ship)

func create_lives_list():
	"""Create visual lives display (mini ships)"""
	# Clear old lives
	for life_ship in lives_display:
		life_ship.queue_free()
	lives_display.clear()
	
	# Create mini ships for remaining lives
	for i in range(ScoreManager.lives - 1):
		var life_ship = ship_scene.instantiate()
		life_ship.is_display_ship = true  # Mark as display-only
		life_ship.heading = Vector2.ZERO  # No movement
		# Position with proper spacing (ship width is about 20 units)
		life_ship.position = Vector2(
			ScreenWrapper.screen_size.x - (i + 1) * 35 - 10,
			30
		)
		life_ship.set_physics_process(false)  # Don't process physics
		# Show lives only when not in attract mode
		life_ship.visible = (current_state != GameState.ATTRACT_MODE)
		add_child(life_ship)
		lives_display.append(life_ship)

func create_rocks(count: int):
	"""Spawn rocks at random positions"""
	for i in range(count):
		var rock = Rock.new(Rock.RockType.LARGE)
		rock.position = Vector2(
			randf_range(0, ScreenWrapper.screen_size.x),
			randf_range(0, ScreenWrapper.screen_size.y)
		)
		add_child(rock)
		rocks.append(rock)

func check_collisions():
	"""Check for collisions between game objects"""
	var ship_hit = false
	var saucer_hit = false
	var rocks_to_remove = []
	
	for rock in rocks:
		var rock_hit = false
		
		# Ship-rock collision
		if not ship.in_hyperspace and ship.collides_with(rock):
			ship_hit = true
			rock_hit = true
		
		# Saucer-rock collision
		if saucer and rock.collides_with(saucer):
			saucer_hit = true
			rock_hit = true
		
		# Saucer bullets hit rock
		if saucer and saucer.bullet_collision(rock):
			rock_hit = true
		
		# Ship bullets hit rock
		if ship.bullet_collision(rock):
			rock_hit = true
		
		if rock_hit:
			rocks_to_remove.append(rock)
			
			# Add score
			print("Rock destroyed! Adding score: %d" % rock.score_value)
			ScoreManager.add_score(rock.score_value)
			
			# Split rock if not smallest
			if rock.rock_type != Rock.RockType.SMALL:
				var new_rocks = rock.split()
				for new_rock in new_rocks:
					add_child(new_rock)
					rocks.append(new_rock)
			else:
				AudioManager.play_sound("explode3")
			
			# Create debris
			create_debris_burst(rock.position)
	
	# Remove destroyed rocks
	for rock in rocks_to_remove:
		rocks.erase(rock)
		rock.queue_free()
	
	# Saucer-ship collisions
	if saucer:
		if not ship.in_hyperspace and saucer.bullet_collision(ship):
			ship_hit = true
		
		if saucer.collides_with(ship):
			ship_hit = true
			saucer_hit = true
		
		# Ship bullets hit saucer
		for bullet in ship.bullets:
			if bullet.ttl > 0:
				if bullet.collision_area and saucer.collision_area:
					if saucer.collision_area in bullet.collision_area.get_overlapping_areas():
						print("*** BULLET OVERLAPS SAUCER! ***")
						print("  Bullet at ", bullet.position)
						print("  Saucer at ", saucer.position)
						print("  Bullet collision layer: ", bullet.collision_area.collision_layer)
						print("  Bullet collision mask: ", bullet.collision_area.collision_mask)
						print("  Saucer collision layer: ", saucer.collision_area.collision_layer)
						print("  Saucer collision mask: ", saucer.collision_area.collision_mask)
		
		if ship.bullet_collision(saucer):
			print("SAUCER HIT BY SHIP BULLET!")
			saucer_hit = true
			ScoreManager.add_score(saucer.score_value)
	
	if saucer_hit and saucer:
		create_debris_burst(saucer.position)
		kill_saucer()
	
	if ship_hit:
		kill_ship()

func check_extra_life():
	"""Extra life logic - already handled by ScoreManager"""
	# This is called automatically by ScoreManager when score changes
	# Just here for compatibility with Python structure
	pass

func do_saucer_logic():
	"""Handle saucer spawning and lifecycle"""
	# Remove saucer if it completed 2 laps
	if saucer and saucer.laps >= 2:
		kill_saucer()
	
	# Spawn saucer periodically (ship can be null in attract mode)
	if seconds_count % 2000 == 0 and saucer == null:
		var saucer_type = Saucer.SaucerType.SMALL if randf() < 0.3 else Saucer.SaucerType.LARGE
		saucer = Saucer.new(saucer_type, ship)
		add_child(saucer)

func kill_ship():
	"""Handle ship destruction"""
	AudioManager.stop_sound("thrust")
	AudioManager.play_sound("explode2")
	
	exploding_count = 0
	current_state = GameState.EXPLODING
	
	# Lose a life (this will trigger lives_changed signal which updates display)
	ScoreManager.lose_life()
	
	# Create explosion debris first (before removing ship)
	if ship:
		var ship_pos = ship.position
		var ship_rot = ship.rotation
		print("Creating ship explosion at position: (%f, %f), rotation: %f" % [ship_pos.x, ship_pos.y, ship_rot])
		create_ship_explosion(ship_pos, ship_rot)
		
		# Now remove the ship completely
		ship.queue_free()
		ship = null

func kill_saucer():
	"""Destroy saucer"""
	if saucer:
		saucer.destroy()
		saucer = null

func create_debris_burst(pos: Vector2):
	"""Create explosion debris at position"""
	for i in range(25):
		var debris = Debris.new(pos)
		add_child(debris)

func create_ship_explosion(ship_position: Vector2, ship_rotation: float):
	"""Create ship debris from line segments - matches Python ship.explode()"""
	print("create_ship_explosion called")
	# Ship shape: [(0, -10), (6, 10), (3, 7), (-3, 7), (-6, 10)]
	# Break into 5 line segments
	var segments = [
		PackedVector2Array([Vector2(0, -10), Vector2(6, 10)]),
		PackedVector2Array([Vector2(6, 10), Vector2(3, 7)]),
		PackedVector2Array([Vector2(3, 7), Vector2(-3, 7)]),
		PackedVector2Array([Vector2(-3, 7), Vector2(-6, 10)]),
		PackedVector2Array([Vector2(-6, 10), Vector2(0, -10)])
	]
	
	for i in range(segments.size()):
		var segment = segments[i]
		print("Creating debris segment %d" % i)
		var debris = Debris.new(ship_position, segment, ship_rotation)
		add_child(debris)
		print("Debris %d added as child" % i)

func level_up():
	"""Progress to next level"""
	num_rocks += 1
	create_rocks(num_rocks)

func game_over():
	"""Handle game over"""
	current_state = GameState.GAME_OVER
	game_over_timer = 0.0  # Reset timer for auto-return
	# TODO: Show game over screen

func display_title_screen():
	"""Show title/attract screen"""
	var title_screen = get_node("HUD/TitleScreen")
	if title_screen:
		title_screen.visible = true
		# Update high score display
		for i in range(3):
			var label = title_screen.get_node("VBoxContainer/HighScore" + str(i + 1))
			if label and i < ScoreManager.high_scores.size():
				var entry = ScoreManager.high_scores[i]
				var score_str = "%06d" % entry["score"]  # 6-digit padding
				label.text = entry["name"] + ":    " + score_str
	
	# Hide HUD elements in attract mode
	if score_label:
		score_label.visible = false
	if high_score_label:
		high_score_label.visible = false
	# Hide lives display
	for ship in lives_display:
		ship.visible = false

func update_hud():
	"""Update HUD display"""
	if score_label:
		score_label.text = "SCORE: %d" % ScoreManager.score
	if high_score_label:
		high_score_label.text = "HIGH: %d" % ScoreManager.high_scores[0]["score"]

func show_high_score_entry_screen():
	"""Show high score entry screen"""
	var entry_screen = get_node("HUD/HighScoreEntryScreen")
	if entry_screen:
		entry_screen.visible = true
		# Hide game over screen
		var game_over_screen = get_node("HUD/GameOverScreen")
		if game_over_screen:
			game_over_screen.visible = false
		# Update display
		update_high_score_entry_display()

func hide_high_score_entry_screen():
	"""Hide high score entry screen"""
	var entry_screen = get_node("HUD/HighScoreEntryScreen")
	if entry_screen:
		entry_screen.visible = false

func update_high_score_entry_display():
	"""Update high score entry screen with current initials"""
	var entry_screen = get_node("HUD/HighScoreEntryScreen")
	if not entry_screen:
		return
	
	# Update score
	var score_label = entry_screen.get_node("VBoxContainer/ScoreLabel")
	if score_label:
		score_label.text = "SCORE: %d" % ScoreManager.score
	
	# Update initials
	var initials_label = entry_screen.get_node("VBoxContainer/InitialsLabel")
	if initials_label:
		var initials_str = ""
		for i in range(ScoreManager.high_score_initials.size()):
			initials_str += char(ScoreManager.high_score_initials[i])
			if i < 2:
				initials_str += "  "  # Two spaces between letters
		initials_label.text = initials_str
	
	# Update cursor position
	var cursor_label = entry_screen.get_node("VBoxContainer/CursorLabel")
	if cursor_label:
		# Position cursor under the selected letter
		var cursor_str = ""
		for i in range(3):
			if i == ScoreManager.current_initial_index:
				cursor_str += "^"
			else:
				cursor_str += " "
			if i < 2:
				cursor_str += "  "  
		cursor_label.text = cursor_str

func _on_score_changed(new_score: int):
	"""Handle score change signal"""
	update_hud()

func _on_lives_changed(new_lives: int):
	"""Handle lives change signal"""
	create_lives_list()

func clear_game_objects():
	"""Remove all game objects"""
	if ship:
		ship.queue_free()
		ship = null
	
	for rock in rocks:
		rock.queue_free()
	rocks.clear()
	
	if saucer:
		kill_saucer()
	
	for life_ship in lives_display:
		life_ship.queue_free()
	lives_display.clear()
