extends Control
## Virtual joystick for touch controls - horizontal only for ship rotation

@export var joystick_width: float = 160.0  # Width of the slot
@export var joystick_height: float = 60.0  # Height of the slot
@export var stick_radius: float = 25.0

var base_position: Vector2
var stick_position: Vector2
var is_pressed: bool = false
var touch_index: int = -1

func _ready():
	base_position = size / 2
	stick_position = base_position

func _draw():
	var half_width = joystick_width / 2
	var half_height = joystick_height / 2
	
	# Draw slot shape (rectangle with semicircles on ends)
	# Create filled semicircles using polygons
	var segments = 16
	
	# Left semicircle (facing left) - filled
	var left_circle_points = PackedVector2Array()
	var left_center = base_position - Vector2(half_width, 0)
	left_circle_points.append(left_center)
	for i in range(segments + 1):
		var angle = PI/2 + (PI * i / segments)
		var point = left_center + Vector2(cos(angle), sin(angle)) * half_height
		left_circle_points.append(point)
	draw_colored_polygon(left_circle_points, Color(1, 1, 1, 0.2))
	
	# Right semicircle (facing right) - filled
	var right_circle_points = PackedVector2Array()
	var right_center = base_position + Vector2(half_width, 0)
	right_circle_points.append(right_center)
	for i in range(segments + 1):
		var angle = -PI/2 + (PI * i / segments)
		var point = right_center + Vector2(cos(angle), sin(angle)) * half_height
		right_circle_points.append(point)
	draw_colored_polygon(right_circle_points, Color(1, 1, 1, 0.2))
	
	# Rectangle in the middle - filled
	var rect = Rect2(base_position - Vector2(half_width, half_height), Vector2(joystick_width, joystick_height))
	draw_rect(rect, Color(1, 1, 1, 0.2))
	
	# Now draw the outlines
	# Left semicircle outline
	draw_arc(left_center, half_height, PI/2, 3*PI/2, segments, Color(1, 1, 1, 0.5), 2.0)
	
	# Right semicircle outline
	draw_arc(right_center, half_height, -PI/2, PI/2, segments, Color(1, 1, 1, 0.5), 2.0)
	
	# Rectangle top and bottom lines
	draw_line(Vector2(base_position.x - half_width, base_position.y - half_height), 
			  Vector2(base_position.x + half_width, base_position.y - half_height), 
			  Color(1, 1, 1, 0.5), 2.0)
	draw_line(Vector2(base_position.x - half_width, base_position.y + half_height), 
			  Vector2(base_position.x + half_width, base_position.y + half_height), 
			  Color(1, 1, 1, 0.5), 2.0)
	
	# Draw stick
	draw_circle(stick_position, stick_radius, Color(1, 1, 1, 0.6))
	draw_arc(stick_position, stick_radius, 0, TAU, 16, Color(1, 1, 1, 0.8), 2.0)

func _gui_input(event: InputEvent):
	if event is InputEventScreenTouch:
		if event.pressed:
			is_pressed = true
			touch_index = event.index
			_update_stick_position(event.position)
		elif event.index == touch_index:
			is_pressed = false
			touch_index = -1
			stick_position = base_position
			_send_input(Vector2.ZERO)
			queue_redraw()
	
	elif event is InputEventScreenDrag and event.index == touch_index:
		_update_stick_position(event.position)

func _update_stick_position(touch_pos: Vector2):
	# Only horizontal movement for rotation
	var offset_x = touch_pos.x - base_position.x
	var half_width = joystick_width / 2
	
	# Clamp to horizontal range
	offset_x = clamp(offset_x, -half_width, half_width)
	
	# Update stick position (only X changes, Y stays at base)
	stick_position = Vector2(base_position.x + offset_x, base_position.y)
	
	# Send normalized direction (only X component, Y is always 0)
	var normalized_x = offset_x / half_width
	_send_input(Vector2(normalized_x, 0))
	
	queue_redraw()

func _send_input(direction: Vector2):
	var touch_handler = get_node_or_null("/root/TouchInputHandler")
	if touch_handler:
		touch_handler.set_joystick_direction(direction)
