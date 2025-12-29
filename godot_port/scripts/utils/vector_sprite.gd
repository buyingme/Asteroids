extends Node2D
class_name VectorSprite
## Base class for vector-based sprites
## Renders polygons using line drawing, similar to original Asteroids

# Movement properties
var heading: Vector2 = Vector2.ZERO
var angle_velocity: float = 0.0

# Visual properties
var point_list: PackedVector2Array = []
var sprite_color: Color = Color.WHITE
var line_width: float = GraphicsConfig.LINE_WIDTH  # Centralized line width config

# Collision
var collision_area: Area2D

func _init(points: PackedVector2Array = PackedVector2Array()):
	point_list = points

func _ready():
	# Create collision area if points are defined
	if point_list.size() >= 3:
		setup_collision()

func setup_collision():
	"""Create collision shape from point list"""
	collision_area = Area2D.new()
	collision_area.monitoring = true
	collision_area.monitorable = true
	# Set collision layers - layer 1 for all game objects
	collision_area.collision_layer = 1
	collision_area.collision_mask = 1
	add_child(collision_area)
	
	var collision_poly = CollisionPolygon2D.new()
	collision_poly.polygon = point_list
	collision_area.add_child(collision_poly)

func _physics_process(delta: float):
	move_sprite(delta)
	queue_redraw()  # Trigger _draw() call

func move_sprite(delta: float):
	"""Move sprite by heading vector with screen wrapping"""
	# Apply velocity (scaled for 60 FPS reference)
	position += heading * delta * 60.0
	
	# Apply rotation
	rotation += deg_to_rad(angle_velocity) * delta * 60.0
	
	# Wrap around screen edges
	position = ScreenWrapper.wrap_position(position)

func _draw():
	"""Draw vector shape as line polygon"""
	if point_list.size() < 2:
		return
	
	# Draw closed polygon
	draw_polyline(point_list, sprite_color, line_width, true)
	
	# Close the polygon by connecting last to first
	if point_list.size() > 0:
		var first = point_list[0]
		var last = point_list[point_list.size() - 1]
		draw_line(last, first, sprite_color, line_width, true)

func scale_points(scale: float) -> PackedVector2Array:
	"""Scale all points by a factor"""
	var scaled = PackedVector2Array()
	for point in point_list:
		scaled.append(point * scale)
	return scaled

func rotate_point(point: Vector2, angle_deg: float) -> Vector2:
	"""Rotate a point by angle in degrees"""
	var angle_rad = deg_to_rad(angle_deg)
	var cos_val = cos(angle_rad)
	var sin_val = sin(angle_rad)
	return Vector2(
		point.x * cos_val - point.y * sin_val,
		point.y * cos_val + point.x * sin_val
	)

func collides_with(other: VectorSprite) -> bool:
	"""Check collision with another vector sprite"""
	if not collision_area or not other.collision_area:
		return false
	
	# Use Area2D overlap detection
	var overlapping = collision_area.get_overlapping_areas()
	return other.collision_area in overlapping
