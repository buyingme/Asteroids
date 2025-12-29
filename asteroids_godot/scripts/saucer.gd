extends VectorSprite
class_name Saucer
## Flying saucer enemy that shoots at player

enum SaucerType { LARGE, SMALL }

# Constants from Python
const VELOCITIES = [1.5, 2.5]
const SCALES = [1.5, 1.0]
const SCORES = [500, 1000]
const MAX_BULLETS = 1
const BULLET_TTL = [60, 90]
const BULLET_VELOCITY = 5.0

var saucer_type: SaucerType
var score_value: int
var target_ship: Node = null
var bullets: Array = []
var fire_timer: float = 0.0
var laps: int = 0
var last_x: float = 0.0
var collision_area: Area2D

func _init(type: SaucerType = SaucerType.LARGE, ship: Node = null):
	saucer_type = type
	score_value = SCORES[saucer_type]
	target_ship = ship

func _ready():
	# Saucer shape from Python
	point_list = PackedVector2Array([
		Vector2(-9, 0), Vector2(-3, -3), Vector2(-2, -6),
		Vector2(2, -6), Vector2(3, -3), Vector2(9, 0),
		Vector2(-9, 0), Vector2(-3, 4), Vector2(3, 4), Vector2(9, 0)
	])
	
	# Scale based on type
	point_list = scale_points(SCALES[saucer_type])
	
	sprite_color = Color.WHITE
	
	# Start from left edge
	position.x = 0
	position.y = randf_range(50, ScreenWrapper.screen_size.y - 50)
	
	# Move horizontally
	heading = Vector2(VELOCITIES[saucer_type], 0)
	
	# Play sound
	if saucer_type == SaucerType.LARGE:
		AudioManager.play_continuous("large_saucer")
	else:
		AudioManager.play_continuous("small_saucer")
	
	# Create collision area
	collision_area = Area2D.new()
	add_child(collision_area)
	
	var collision_shape = CollisionPolygon2D.new()
	collision_shape.polygon = point_list
	collision_area.add_child(collision_shape)
	
	collision_area.area_entered.connect(_on_area_entered)
	
	super._ready()

func _physics_process(delta: float):
	# Sine wave motion
	if position.x > ScreenWrapper.screen_size.x * 0.33 and \
	   position.x < ScreenWrapper.screen_size.x * 0.66:
		heading.y = heading.x
	else:
		heading.y = 0
	
	# Track laps
	if last_x > position.x:
		last_x = 0
		laps += 1
	else:
		last_x = position.x
	
	# Check if too many laps
	if laps >= 2:
		destroy()
		return
	
	# Fire at ship
	fire_timer -= delta
	if fire_timer <= 0:
		fire_bullet()
		fire_timer = randf_range(1.0, 3.0)
	
	super._physics_process(delta)

func fire_bullet():
	"""Fire bullet at player ship"""
	if bullets.size() >= MAX_BULLETS:
		return
	
	if not target_ship:
		return
	
	# Calculate direction to ship
	var to_ship = target_ship.global_position - global_position
	var direction = to_ship.normalized()
	
	# Add inaccuracy for large saucer
	if saucer_type == SaucerType.LARGE:
		direction = direction.rotated(randf_range(-0.5, 0.5))
	
	# Create bullet
	var bullet = preload("res://scenes/bullet.tscn").instantiate()
	bullet.position = global_position
	bullet.heading = direction * BULLET_VELOCITY
	bullet.ttl = BULLET_TTL[saucer_type]
	bullet.owner_ship = self
	bullet.sprite_color = Color.RED  # Different color for saucer bullets
	
	get_parent().add_child(bullet)
	bullets.append(bullet)
	
	AudioManager.play_sound("saucer_fire")

func remove_bullet(bullet):
	"""Remove bullet from tracking"""
	if bullet in bullets:
		bullets.erase(bullet)

func _on_area_entered(area: Area2D):
	"""Handle collision"""
	if area.get_parent() is Bullet:
		var bullet = area.get_parent()
		if bullet.owner_ship != self:  # Don't collide with own bullets
			bullet.hit_target()
			destroy()
	elif area.get_parent() is Ship:
		# Let game manager handle ship collision
		pass

func destroy():
	"""Destroy saucer"""
	AudioManager.stop_sound("large_saucer")
	AudioManager.stop_sound("small_saucer")
	AudioManager.play_sound("explode2")
	
	ScoreManager.add_score(score_value)
	
	# Create debris
	for i in range(20):
		var debris = preload("res://scenes/debris.tscn").instantiate()
		debris.position = global_position
		debris.heading = Vector2(randf_range(-2, 2), randf_range(-2, 2))
		get_parent().add_child(debris)
	
	queue_free()
