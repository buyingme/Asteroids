extends Node2D
class_name VectorSprite
## Base class for vector-based sprites
## Handles movement, rotation, and screen wrapping

var heading: Vector2 = Vector2.ZERO
var angle_velocity: float = 0.0
var point_list: PackedVector2Array = []
var sprite_color: Color = Color.WHITE
var line_width: float = 2.0

func _init(points: PackedVector2Array = PackedVector2Array()):
	point_list = points

func _physics_process(delta: float):
	move_sprite(delta)
	queue_redraw()

func move_sprite(delta: float):
	"""Move sprite by heading vector"""
	position += heading * delta * 60.0  # Scale for 60 FPS equivalent
	rotation += deg_to_rad(angle_velocity * delta * 60.0)
	
	# Wrap around screen
	position = ScreenWrapper.wrap_position(position)

func _draw():
	"""Draw vector shape"""
	if point_list.size() < 2:
		return
	
	# Draw polygon outline
	draw_polyline(point_list, sprite_color, line_width, true)

func scale_points(scale: float) -> PackedVector2Array:
	"""Scale all points by factor"""
	var scaled = PackedVector2Array()
	for point in point_list:
		scaled.append(point * scale)
	return scaled

func get_bounding_rect() -> Rect2:
	"""Calculate bounding rectangle for collision"""
	if point_list.size() == 0:
		return Rect2()
	
	var min_pos = point_list[0]
	var max_pos = point_list[0]
	
	for point in point_list:
		min_pos.x = min(min_pos.x, point.x)
		min_pos.y = min(min_pos.y, point.y)
		max_pos.x = max(max_pos.x, point.x)
		max_pos.y = max(max_pos.y, point.y)
	
	return Rect2(min_pos, max_pos - min_pos)
