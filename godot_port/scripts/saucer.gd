extends VectorSprite
class_name Saucer
## Flying saucer enemy that shoots at player
## Ported from Python badies.py

enum SaucerType { LARGE = 0, SMALL = 1 }

# Constants from Python Saucer class
const VELOCITIES = [1.5, 2.5]
const SCALES = [1.5, 1.0]
const SCORES = [500, 1000]
const MAX_BULLETS = 1
const BULLET_TTL = [78, 117]  # frames (increased by 30% from [60, 90])
const BULLET_VELOCITY = 5.0

var saucer_type: SaucerType
var score_value: int
var ship = null  # Reference to player ship
var bullets: Array = []
var laps: int = 0
var last_x: float = 0.0
var shoot_timer: float = 0.0

# Bullet scene
var bullet_scene = preload("res://scenes/bullet.tscn")

# Saucer shape from Python
const SAUCER_SHAPE = [
	Vector2(-9, 0), Vector2(-3, -3), Vector2(-2, -6),
	Vector2(2, -6), Vector2(3, -3), Vector2(9, 0),
	Vector2(-9, 0), Vector2(-3, 4), Vector2(3, 4),
	Vector2(9, 0)
]

func _init(type: SaucerType, player_ship):
	saucer_type = type
	ship = player_ship
	score_value = SCORES[saucer_type]
	
	# Create saucer shape
	point_list = PackedVector2Array(SAUCER_SHAPE)
	var scale = SCALES[saucer_type]
	point_list = scale_points(scale)
	
	# Start at left edge, random Y
	position = Vector2(0, randf_range(0, ScreenWrapper.screen_size.y))
	heading = Vector2(VELOCITIES[saucer_type], 0)
	
	sprite_color = Color.WHITE
	
	# Play appropriate sound
	AudioManager.stop_sound("ssaucer")
	AudioManager.stop_sound("lsaucer")
	if saucer_type == SaucerType.LARGE:
		AudioManager.play_sound_continuous("lsaucer")
	else:
		AudioManager.play_sound_continuous("ssaucer")
	
	# Set shoot timer
	shoot_timer = randf_range(1.0, 3.0)

func setup_collision():
	"""Override parent's collision setup - we'll create our own in _ready()"""
	pass  # Do nothing - prevents "Convex decomposing failed" error

func _ready():
	# Don't call super._ready() - it would try to create collision from invalid polygon
	# Instead, manually create the collision area we need
	
	collision_area = Area2D.new()
	collision_area.monitoring = true
	collision_area.monitorable = true
	collision_area.collision_layer = 1
	collision_area.collision_mask = 1
	add_child(collision_area)
	
	# Create a simple rectangle collision (saucer is roughly 18x12)
	var scale_factor = SCALES[saucer_type]
	var rect = CollisionPolygon2D.new()
	rect.polygon = PackedVector2Array([
		Vector2(-9, -6) * scale_factor,
		Vector2(9, -6) * scale_factor,
		Vector2(9, 4) * scale_factor,
		Vector2(-9, 4) * scale_factor
	])
	collision_area.add_child(rect)

func _physics_process(delta: float):
	# Move with sine wave pattern in middle third of screen
	var screen_width = ScreenWrapper.screen_size.x
	if position.x > screen_width * 0.33 and position.x < screen_width * 0.66:
		heading.y = heading.x
	else:
		heading.y = 0
	
	# Check for screen wrap (lap counter)
	if last_x > position.x:
		laps += 1
		last_x = 0
	else:
		last_x = position.x
	
	# Shoot at player periodically
	shoot_timer -= delta
	if shoot_timer <= 0:
		fire_bullet()
		shoot_timer = randf_range(1.0, 2.0)
	
	super._physics_process(delta)

func fire_bullet():
	"""Fire bullet at player"""
	# Don't fire if no ship (e.g., in attract mode)
	if not ship:
		return
	
	if bullets.size() >= MAX_BULLETS:
		return
	
	# Calculate direction to ship
	var dx = ship.position.x - position.x
	var dy = ship.position.y - position.y
	var distance = sqrt(dx * dx + dy * dy)
	
	if distance < 0.1:
		return
	
	# Normalize and scale by bullet velocity
	var bullet_heading = Vector2(
		BULLET_VELOCITY * (dx / distance),
		BULLET_VELOCITY * (dy / distance)
	)
	
	# Add inaccuracy for large saucer
	if saucer_type == SaucerType.LARGE:
		bullet_heading += Vector2(
			randf_range(-1, 1),
			randf_range(-1, 1)
		)
	
	# Create bullet
	var bullet = bullet_scene.instantiate()
	bullet.position = position
	bullet.heading = bullet_heading
	bullet.ttl = BULLET_TTL[saucer_type]
	bullet.shooter = self
	
	get_parent().add_child(bullet)
	bullets.append(bullet)
	
	bullet.tree_exiting.connect(_on_bullet_destroyed.bind(bullet))
	
	AudioManager.play_sound("sfire")

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

func destroy():
	"""Clean up saucer"""
	AudioManager.stop_sound("lsaucer")
	AudioManager.stop_sound("ssaucer")
	queue_free()
