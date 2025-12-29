extends VectorSprite
class_name Ship
## Player ship with physics-based movement
## Ported from Python ship.py

# Physics constants (from Python Ship class)
const ACCELERATION = 0.2
const DECELERATION = -0.005
const MAX_VELOCITY = 10.0
const TURN_SPEED = 6.0  # degrees per frame
const BULLET_VELOCITY = 13.0
const MAX_BULLETS = 5
const BULLET_TTL = 45  # frames (increased by 30% from 35)

# State
var in_hyperspace: bool = false
var hyperspace_timer: float = 0.0
var bullets: Array = []
var thrust_jet: ThrustJet
var visible_sprite: bool = true
var is_display_ship: bool = false  # True for lives display ships

# Bullet scene
var bullet_scene = preload("res://scenes/bullet.tscn")

func _init():
	# Ship shape from Python: [(0, -10), (6, 10), (3, 7), (-3, 7), (-6, 10)]
	point_list = PackedVector2Array([
		Vector2(0, -10),
		Vector2(6, 10),
		Vector2(3, 7),
		Vector2(-3, 7),
		Vector2(-6, 10),
		Vector2(0, -10)  # Close the shape
	])
	
	sprite_color = Color.WHITE

func _ready():
	super._ready()
	
	# Only setup gameplay for actual player ship
	if is_display_ship:
		queue_redraw()  # Static display ships need manual redraw
		return
	
	# Start at center of screen
	position = ScreenWrapper.screen_size / 2
	
	# Create thrust jet
	thrust_jet = ThrustJet.new(self)
	add_child(thrust_jet)

func _physics_process(delta: float):
	if is_display_ship:
		return  # Display ships don't move
	
	if not visible_sprite:
		return
	
	handle_input(delta)
	apply_deceleration(delta)
	
	# Handle hyperspace timer
	if in_hyperspace:
		hyperspace_timer -= delta
		if hyperspace_timer <= 0:
			exit_hyperspace()
	
	# Call parent physics
	super._physics_process(delta)

func handle_input(_delta: float):
	"""Process player input"""
	# Rotation
	if Input.is_action_pressed("rotate_left"):
		rotation_degrees -= TURN_SPEED
	
	if Input.is_action_pressed("rotate_right"):
		rotation_degrees += TURN_SPEED
	
	# Thrust
	if Input.is_action_pressed("thrust"):
		apply_thrust()
		if thrust_jet:
			thrust_jet.accelerating = true
	else:
		if thrust_jet:
			thrust_jet.accelerating = false
	
	# Fire
	if Input.is_action_just_pressed("fire"):
		fire_bullet()
	
	# Hyperspace
	if Input.is_action_just_pressed("hyperspace"):
		enter_hyperspace()

func apply_thrust():
	"""Increase velocity in facing direction"""
	if heading.length() > MAX_VELOCITY:
		return
	
	AudioManager.play_sound_continuous("thrust")
	
	# Calculate thrust vector from rotation (facing up is -Y)
	var thrust_dir = Vector2(0, -1).rotated(rotation)
	heading += thrust_dir * ACCELERATION

func apply_deceleration(_delta: float):
	"""Gradually slow down"""
	if heading.length() > 0:
		heading += heading * DECELERATION
	else:
		AudioManager.stop_sound("thrust")

func fire_bullet():
	"""Create and fire a bullet"""
	if bullets.size() >= MAX_BULLETS:
		return
	
	if in_hyperspace:
		return
	
	# Calculate bullet velocity
	var bullet_dir = Vector2(0, -1).rotated(rotation)
	var bullet_velocity = bullet_dir * BULLET_VELOCITY
	
	# Create bullet instance
	var bullet = bullet_scene.instantiate()
	bullet.position = position
	bullet.heading = bullet_velocity
	bullet.ttl = BULLET_TTL
	bullet.shooter = self
	
	# Add to scene
	get_parent().add_child(bullet)
	bullets.append(bullet)
	
	# Connect to bullet destruction
	bullet.tree_exiting.connect(_on_bullet_destroyed.bind(bullet))
	
	AudioManager.play_sound("fire")

func _on_bullet_destroyed(bullet):
	"""Remove bullet from tracking list"""
	bullets.erase(bullet)

func bullet_collision(target) -> bool:
	"""Check if any bullet hit the target"""
	for bullet in bullets:
		if bullet.ttl > 0 and target.collides_with(bullet):
			bullet.ttl = 0
			return true
	return false

func enter_hyperspace():
	"""Teleport to random location"""
	if in_hyperspace:
		return
	
	in_hyperspace = true
	hyperspace_timer = 100.0 / 60.0  # 100 frames at 60 FPS
	sprite_color = Color.TRANSPARENT
	modulate.a = 0.0
	
	if thrust_jet:
		thrust_jet.sprite_color = Color.TRANSPARENT

func exit_hyperspace():
	"""Return from hyperspace at random position"""
	in_hyperspace = false
	sprite_color = Color.WHITE
	modulate.a = 1.0
	
	if thrust_jet:
		thrust_jet.sprite_color = Color.WHITE
	
	# Random position
	position = Vector2(
		randf_range(0, ScreenWrapper.screen_size.x),
		randf_range(0, ScreenWrapper.screen_size.y)
	)

func explode():
	"""Break ship into debris lines"""
	# Create debris from ship segments
	var segments = [
		[Vector2(0, -10), Vector2(6, 10)],
		[Vector2(6, 10), Vector2(3, 7)],
		[Vector2(3, 7), Vector2(-3, 7)],
		[Vector2(-3, 7), Vector2(-6, 10)],
		[Vector2(-6, 10), Vector2(0, -10)]
	]
	
	for segment in segments:
		create_debris(segment[0], segment[1])

func create_debris(p1: Vector2, p2: Vector2):
	"""Create a debris line segment"""
	var debris = VectorSprite.new()
	debris.point_list = PackedVector2Array([p1, p2])
	debris.position = position
	debris.sprite_color = Color.WHITE
	
	# Calculate velocity away from center
	var center = (p1 + p2) / 2
	debris.heading = center.normalized() * randf_range(1, 3)
	debris.angle_velocity = randf_range(-5, 5)
	
	get_parent().add_child(debris)
	
	# Auto-remove after time
	var timer = get_tree().create_timer(3.0)
	timer.timeout.connect(debris.queue_free)


## ThrustJet - Exhaust visual when accelerating
class ThrustJet extends VectorSprite:
	var ship: Ship
	var accelerating: bool = false
	
	func _init(parent_ship: Ship):
		ship = parent_ship
		# Thrust jet shape from Python: [(-3, 7), (0, 13), (3, 7)]
		point_list = PackedVector2Array([
			Vector2(-3, 7),
			Vector2(0, 13),
			Vector2(3, 7)
		])
		sprite_color = Color.WHITE
	
	func _draw():
		if accelerating and not ship.in_hyperspace:
			sprite_color = Color.WHITE
			super._draw()
		else:
			# Don't draw when not accelerating
			pass
