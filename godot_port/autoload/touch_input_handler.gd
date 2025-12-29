extends Node
## Touch input handler for mobile devices

# Input state structure (same as InputHandler)
class InputState:
	var rotate_left: bool = false
	var rotate_right: bool = false
	var thrust: bool = false
	var fire_pressed: bool = false
	var hyperspace_pressed: bool = false

var current_state: InputState = InputState.new()
var joystick_direction: Vector2 = Vector2.ZERO
var thrust_pressed: bool = false
var fire_just_pressed: bool = false
var hyperspace_just_pressed: bool = false

func _ready():
	print("TouchInputHandler initialized")

func get_input_state() -> InputState:
	"""Get current touch input state"""
	# Joystick controls rotation
	if joystick_direction.x < -0.3:
		current_state.rotate_left = true
		current_state.rotate_right = false
	elif joystick_direction.x > 0.3:
		current_state.rotate_left = false
		current_state.rotate_right = true
	else:
		current_state.rotate_left = false
		current_state.rotate_right = false
	
	current_state.thrust = thrust_pressed
	current_state.fire_pressed = fire_just_pressed
	current_state.hyperspace_pressed = hyperspace_just_pressed
	
	# Reset just_pressed states after reading
	fire_just_pressed = false
	hyperspace_just_pressed = false
	
	return current_state

func set_joystick_direction(direction: Vector2):
	"""Called by virtual joystick"""
	joystick_direction = direction
	print("Joystick direction: ", direction)

func set_thrust(pressed: bool):
	"""Called by thrust button"""
	thrust_pressed = pressed
	print("Thrust: ", pressed)

func set_fire(pressed: bool):
	"""Called by fire button"""
	if pressed:
		fire_just_pressed = true
		print("Fire pressed!")

func set_hyperspace(pressed: bool):
	"""Called by hyperspace button"""
	if pressed:
		hyperspace_just_pressed = true
		print("Hyperspace pressed!")

func clear_state():
	"""Clear input state when switching handlers"""
	joystick_direction = Vector2.ZERO
	thrust_pressed = false
	fire_just_pressed = false
	hyperspace_just_pressed = false
	current_state.rotate_left = false
	current_state.rotate_right = false
	current_state.thrust = false
	current_state.fire_pressed = false
	current_state.hyperspace_pressed = false
	print("TouchInputHandler state cleared")
