extends Node2D
## Main game controller
## Manages game state, spawning, and collision detection

enum GameState { ATTRACT, PLAYING, EXPLODING, GAME_OVER }

var current_state: GameState = GameState.ATTRACT
var ship: Ship = null
var rocks: Array = []
var saucer: Saucer = null
var num_rocks: int = 3
var exploding_timer: float = 0.0
var exploding_duration: float = 3.0  # 180 frames at 60fps
var saucer_spawn_timer: float = 0.0
var frame_count: int = 0

# UI references
@onready var hud = $HUD
@onready var title_screen = $TitleScreen

func _ready():
	ScoreManager.load_high_scores()
	show_title_screen()

func _process(delta: float):
	frame_count += 1
	
	match current_state:
		GameState.ATTRACT:
			if Input.is_action_just_pressed("start_game"):
				start_game()
		
		GameState.PLAYING:
			update_playing(delta)
		
		GameState.EXPLODING:
			update_exploding(delta)
		
		GameState.GAME_OVER:
			if Input.is_action_just_pressed("start_game"):
				start_game()

func show_title_screen():
	"""Display title screen"""
	current_state = GameState.ATTRACT
	if title_screen:
		title_screen.visible = true
	if hud:
		hud.visible = false
	
	# Create some floating rocks for visual effect
	for i in range(3):
		var rock = Rock.new(Rock.RockType.LARGE)
		rock.position = Vector2(
			randf_range(0, ScreenWrapper.screen_size.x),
			randf_range(0, ScreenWrapper.screen_size.y)
		)
		add_child(rock)
		rocks.append(rock)

func start_game():
	"""Initialize new game"""
	current_state = GameState.PLAYING
	
	if title_screen:
		title_screen.visible = false
	if hud:
		hud.visible = true
	
	# Clear any existing objects
	clear_all_objects()
	
	# Reset game state
	ScoreManager.reset_game()
	num_rocks = 3
	
	# Create ship
	create_ship()
	
	# Create initial rocks
	spawn_rocks(num_rocks)
	
	saucer_spawn_timer = randf_range(20.0, 30.0)

func create_ship():
	"""Create player ship"""
	if ship:
		ship.queue_free()
	
	ship = preload("res://scenes/ship.tscn").instantiate()
	ship.position = ScreenWrapper.screen_size / 2.0
	add_child(ship)
	
	# Connect collision
	ship.collision_area.area_entered.connect(_on_ship_collision)

func spawn_rocks(count: int):
	"""Spawn asteroids"""
	for i in range(count):
		var rock = Rock.new(Rock.RockType.LARGE)
		
		# Spawn away from ship
		var safe_spawn = false
		var attempts = 0
		while not safe_spawn and attempts < 10:
			rock.position = Vector2(
				randf_range(0, ScreenWrapper.screen_size.x),
				randf_range(0, ScreenWrapper.screen_size.y)
			)
			
			if ship and rock.position.distance_to(ship.position) < 150:
				attempts += 1
				continue
			
			safe_spawn = true
		
		add_child(rock)
		rocks.append(rock)

func update_playing(delta: float):
	"""Update game during playing state"""
	# Check for level complete
	rocks = rocks.filter(func(r): return is_instance_valid(r))
	if rocks.size() == 0:
		level_complete()
	
	# Spawn saucer
	saucer_spawn_timer -= delta
	if saucer_spawn_timer <= 0 and not saucer:
		spawn_saucer()
		saucer_spawn_timer = randf_range(20.0, 30.0)
	
	# Check if saucer is still valid
	if saucer and not is_instance_valid(saucer):
		saucer = null

func spawn_saucer():
	"""Spawn enemy saucer"""
	if not ship:
		return
	
	var type = Saucer.SaucerType.LARGE
	if ScoreManager.score > 10000:
		type = Saucer.SaucerType.SMALL if randf() > 0.5 else Saucer.SaucerType.LARGE
	
	saucer = Saucer.new(type, ship)
	add_child(saucer)

func level_complete():
	"""Progress to next level"""
	num_rocks += 1
	spawn_rocks(num_rocks)

func _on_ship_collision(area: Area2D):
	"""Handle ship collision with rock or saucer"""
	if current_state != GameState.PLAYING:
		return
	
	var other = area.get_parent()
	if other is Rock or other is Saucer:
		ship_destroyed()

func ship_destroyed():
	"""Handle ship destruction"""
	if not ship:
		return
	
	AudioManager.stop_sound("thrust")
	AudioManager.play_sound("explode2")
	
	ship.explode()
	current_state = GameState.EXPLODING
	exploding_timer = exploding_duration
	
	ScoreManager.lose_life()

func update_exploding(delta: float):
	"""Update during ship explosion"""
	exploding_timer -= delta
	
	if exploding_timer <= 0:
		if ScoreManager.lives > 0:
			# Respawn ship
			create_ship()
			current_state = GameState.PLAYING
		else:
			# Game over
			game_over()

func game_over():
	"""Handle game over"""
	current_state = GameState.GAME_OVER
	
	# Check for high score
	if ScoreManager.is_high_score():
		# TODO: Show high score entry screen
		pass
	
	# Show title screen after delay
	await get_tree().create_timer(3.0).timeout
	clear_all_objects()
	show_title_screen()

func clear_all_objects():
	"""Remove all game objects"""
	for rock in rocks:
		if is_instance_valid(rock):
			rock.queue_free()
	rocks.clear()
	
	if ship and is_instance_valid(ship):
		ship.queue_free()
	ship = null
	
	if saucer and is_instance_valid(saucer):
		saucer.queue_free()
	saucer = null
	
	# Clear any remaining debris and bullets
	for child in get_children():
		if child is Debris or child is Bullet:
			child.queue_free()
