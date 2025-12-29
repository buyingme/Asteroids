extends VectorSprite
class_name Debris
## Small debris particles for explosions
## Fades out over time

var ttl: float = 180.0  # Time to live in frames (matches Python explodingTtl)
var fade_rate: float = 0.0  # No fading for ship debris (matches Python VectorSprite behavior)
var initial_position: Vector2 = Vector2.ZERO

func _init(pos: Vector2, points: PackedVector2Array = PackedVector2Array(), initial_angle: float = 0.0):
	super._init(points)  # Initialize parent with points
	sprite_color = Color.WHITE  # White debris
	line_width = GraphicsConfig.DEBRIS_LINE_WIDTH  # Centralized debris line width config
	
	initial_position = pos
	rotation = initial_angle
	
	if points.size() >= 2:
		# Line segment debris (for ship explosion) - point_list already set by parent
		
		# Calculate center of the line segment AFTER rotation (matches Python's boundingRect.center)
		# First rotate the points, then find center
		var center = Vector2.ZERO
		for point in points:
			var rotated_point = point.rotated(initial_angle)
			center += rotated_point
		center /= points.size()
		
		# Velocity moving away from ship center (matches Python implementation)
		# debris.heading.x = ((centerX - self.position.x) + 0.1) / random.uniform(20, 40)
		heading = Vector2(
			(center.x + 0.1) / randf_range(20, 40),
			(center.y + 0.1) / randf_range(20, 40)
		)
	else:
		# Point debris (for rock/saucer explosions)
		heading = Vector2(
			randf_range(-1.5, 1.5),
			randf_range(-1.5, 1.5)
		)
		
		point_list = PackedVector2Array([
			Vector2(0, 0),
			Vector2(1, 1)
		])
	
	# Don't set rotation again - already set above
	# Ensure color is WHITE (set again for safety)
	sprite_color = Color.WHITE

func _ready():
	super._ready()
	# Always apply the initial position
	position = initial_position

func _physics_process(delta: float):
	ttl -= 1
	
	if ttl <= 0:
		queue_free()
		return
	
	# Fade color (keep alpha at 1.0)
	var r = maxf(sprite_color.r - fade_rate, 0)
	var g = maxf(sprite_color.g - fade_rate, 0)
	var b = maxf(sprite_color.b - fade_rate, 0)
	sprite_color = Color(r, g, b, 1.0)
	
	super._physics_process(delta)

func _draw():
	"""Draw debris line segment"""
	if point_list.size() >= 2:
		# For line segments (ship explosion), draw each line with antialiasing
		for i in range(point_list.size() - 1):
			draw_line(point_list[i], point_list[i + 1], sprite_color, line_width, true)  # true = antialiased
	elif point_list.size() == 2:
		# Single point debris
		draw_line(point_list[0], point_list[1], sprite_color, line_width, true)
