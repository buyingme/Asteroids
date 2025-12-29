extends Node
## Keyboard input handler for desktop

# Input state structure (same as InputHandler)
class InputState:
	var rotate_left: bool = false
	var rotate_right: bool = false
	var thrust: bool = false
	var fire_pressed: bool = false
	var hyperspace_pressed: bool = false

var current_state: InputState = InputState.new()

func _ready():
	print("KeyboardInputHandler initialized")

func get_input_state() -> InputState:
	"""Get current keyboard input state"""
	current_state.rotate_left = Input.is_action_pressed("rotate_left")
	current_state.rotate_right = Input.is_action_pressed("rotate_right")
	current_state.thrust = Input.is_action_pressed("thrust")
	current_state.fire_pressed = Input.is_action_just_pressed("fire")
	current_state.hyperspace_pressed = Input.is_action_just_pressed("hyperspace")
	
	return current_state

func clear_state():
	"""Clear input state when switching handlers"""
	current_state.rotate_left = false
	current_state.rotate_right = false
	current_state.thrust = false
	current_state.fire_pressed = false
	current_state.hyperspace_pressed = false
	print("KeyboardInputHandler state cleared")
