extends Node
## Base input handler - provides abstraction for keyboard and touch input

# Input state structure
class InputState:
	var rotate_left: bool = false
	var rotate_right: bool = false
	var thrust: bool = false
	var fire_pressed: bool = false
	var hyperspace_pressed: bool = false

var current_state: InputState = InputState.new()

func get_input_state() -> InputState:
	"""Override this in subclasses"""
	return current_state
