extends VectorSprite
class_name Ship
## Player ship with physics-based movement

# Physics constants from Python
const ACCELERATION = 0.2
const DECELERATION = -0.005
const MAX_VELOCITY = 10.0
const TURN_SPEED = 6.0
const BULLET_VELOCITY = 13.0
const MAX_BULLETS = 4
const BULLET_TTL = 35

# State
var in_hyperspace: bool = false
var hyperspace_timer: float = 0.0
var bullets: Array = []
var thrust_jet: ThrustJet
var visible_sprite: bool = true

# Collision area
var collision_area: Area2D

func _ready():
	# Ship shape from Python: [(0, -10), (6, 10), (3, 7), (-3, 7), (-6, 10)]
	point_list = PackedVector2Array([
		Vector2(0, -10),
		Vector2(6, 10),
		Vector2(3, 7),
		Vector2(-3, 7),
		Vector2(-6, 10)
	])
	
	sprite_color = Color.WHITE
	
	# Create collision area
	collision_area = Area2D.new()
	add_child(collision_area)
	
	var collision_shape = CollisionPolygon2D.new()
	collision_shape.polygon = point_list
	collision_area.add_child(collision_shape)
	
	# Create thrust jet
	thrust_jet = ThrustJet.new()
	add_child(thrust_jet)
	
	super._ready()

func _physics_process(delta: float):
	if in_hyperspace:
		hyperspace_timer -= delta
		if hyperspace_timer <= 0:
			exit_hyperspace()
	else:
		handle_input(delta)
		apply_deceleration(delta)
	
	super._physics_process(delta)

func _draw():
	if visible_sprite and not in_hyperspace:
		super._draw()

func handle_input(delta: float):
	"""Process player input"""
	# Rotation
	if Input.is_action_pressed("rotate_left"):
		rotation_degrees += TURN_SPEED
	if Input.is_action_pressed("rotate_right"):
		rotation_degrees -= TURN_SPEED
	
	# Thrust
	if Input.is_action_pressed("thrust"):
		apply_thrust()
		thrust_jet.set_visible_thrust(true)
	else:
		thrust_jet.set_visible_thrust(false)
	
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
	
	# Calculate thrust vector from rotation (Godot uses different angle convention)
	var thrust_dir = Vector2(0, -1).rotated(rotation)
	heading += thrust_dir * ACCELERATION
	
	AudioManager.play_continuous("thrust")

func apply_deceleration(delta: float):
	"""Gradually slow down"""
	if heading.length() > 0:
		heading += heading * DECELERATION
		if heading.length() < 0.01:
			heading = Vector2.ZERO
	
	AudioManager.stop_sound("thrust")

func fire_bullet():
	"""Create a bullet"""
	if bullets.size() >= MAX_BULLETS:
		return
	
	if in_hyperspace:
		return
	
	# Create bullet
	var bullet = preload("res://scenes/bullet.tscn").instantiate()
	var bullet_dir = Vector2(0, -1).rotated(rotation)
	bullet.position = global_position
	bullet.heading = bullet_dir * BULLET_VELOCITY + heading  # Add ship velocity
	bullet.ttl = BULLET_TTL
	bullet.owner_ship = self
	
	get_parent().add_child(bullet)
	bullets.append(bullet)
	
	AudioManager.play_sound("fire")

func remove_bullet(bullet):
	"""Remove bullet from tracking"""
	if bullet in bullets:
		bullets.erase(bullet)

func enter_hyperspace():
	"""Teleport to random location"""
	if in_hyperspace:
		return
	
	in_hyperspace = true
	hyperspace_timer = 100.0 / 60.0  # 100 frames at 60 FPS
	sprite_color = Color.TRANSPARENT
	modulate.a = 0.0
	collision_area.monitoring = false

func exit_hyperspace():
	"""Return from hyperspace"""
	in_hyperspace = false
	sprite_color = Color.WHITE
	modulate.a = 1.0
	collision_area.monitoring = true
	
	# Random position
	var viewport_size = ScreenWrapper.screen_size
	position = Vector2(
		randf_range(0, viewport_size.x),
		randf_range(0, viewport_size.y)
	)

func explode():
	"""Break ship into debris"""
	# Create debris from ship segments
	var segments = [
		[Vector2(0, -10), Vector2(6, 10)],
		[Vector2(6, 10), Vector2(3, 7)],
		[Vector2(3, 7), Vector2(-3, 7)],
		[Vector2(-3, 7), Vector2(-6, 10)],
		[Vector2(-6, 10), Vector2(0, -10)]
	]
	
	for segment in segments:
		var debris = preload("res://scenes/debris.tscn").instantiate()
		debris.position = global_position
		debris.point_list = segment
		debris.heading = (segment[0] + segment[1]) / 2.0 / 20.0  # Expand outward
		get_parent().add_child(debris)
	
	visible_sprite = false
	collision_area.monitoring = false

# Thrust jet visual effect
class ThrustJet extends VectorSprite:
	var is_thrusting: bool = false
	
	func _ready():
		# Jet shape: [(-3, 7), (0, 13), (3, 7)]
		point_list = PackedVector2Array([
			Vector2(-3, 7),
			Vector2(0, 13),
			Vector2(3, 7)
		])
		sprite_color = Color.WHITE
		super._ready()
	
	func _draw():
		if is_thrusting:
			super._draw()
	
	func set_visible_thrust(visible: bool):
		is_thrusting = visible
		queue_redraw()
