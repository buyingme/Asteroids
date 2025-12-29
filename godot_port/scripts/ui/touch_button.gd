extends Control
## Touch button for mobile controls

signal button_pressed
signal button_released

@export var button_text: String = "FIRE"
@export var button_radius: float = 60.0

var is_pressed: bool = false
var touch_index: int = -1

func _ready():
	custom_minimum_size = Vector2(button_radius * 2, button_radius * 2)

func _draw():
	var center = size / 2
	var color = Color(1, 1, 1, 0.6 if is_pressed else 0.3)
	var border_color = Color(1, 1, 1, 0.8)
	
	# Draw button circle
	draw_circle(center, button_radius, color)
	draw_arc(center, button_radius, 0, TAU, 32, border_color, 3.0)
	
	# Draw text (simple - Godot doesn't have draw_text_centered, we'll position it)
	var font = ThemeDB.fallback_font
	var font_size = 20
	var text_size = font.get_string_size(button_text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
	var text_pos = center - text_size / 2
	draw_string(font, text_pos, button_text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, Color.WHITE)

func _gui_input(event: InputEvent):
	if event is InputEventScreenTouch:
		if event.pressed and not is_pressed:
			is_pressed = true
			touch_index = event.index
			button_pressed.emit()
			queue_redraw()
		elif event.index == touch_index and not event.pressed:
			is_pressed = false
			touch_index = -1
			button_released.emit()
			queue_redraw()
	
	elif event is InputEventScreenDrag:
		if event.index == touch_index:
			# Check if still within button area
			var center = size / 2
			if event.position.distance_to(center) > button_radius * 1.5:
				if is_pressed:
					is_pressed = false
					touch_index = -1
					button_released.emit()
					queue_redraw()
