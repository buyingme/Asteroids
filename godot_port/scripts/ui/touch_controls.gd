extends CanvasLayer
## Touch controls overlay for mobile

var touch_controls_enabled: bool = false

func _ready():
	# Add to group for easy access
	add_to_group("touch_controls")
	
	# Connect button signals to touch input handler
	var fire_button = $LeftControls/FireButton
	var hyperspace_button = $LeftControls/HyperspaceButton
	var thrust_button = $LeftControls/ThrustButton
	
	var touch_handler = get_node_or_null("/root/TouchInputHandler")
	if touch_handler:
		fire_button.button_pressed.connect(func(): touch_handler.set_fire(true))
		hyperspace_button.button_pressed.connect(func(): touch_handler.set_hyperspace(true))
		thrust_button.button_pressed.connect(func(): touch_handler.set_thrust(true))
		thrust_button.button_released.connect(func(): touch_handler.set_thrust(false))
	
	# Auto-enable on mobile, hide on desktop (but can be toggled with Shift+T)
	if OS.has_feature("mobile"):
		touch_controls_enabled = true
		visible = true
	else:
		visible = false

func toggle_touch_controls():
	"""Toggle touch controls visibility (for testing on desktop)"""
	touch_controls_enabled = not touch_controls_enabled
	visible = touch_controls_enabled
	
	print("Touch controls toggled: ", "ON" if touch_controls_enabled else "OFF")
	
	# Get input handlers
	var touch_handler = get_node_or_null("/root/TouchInputHandler")
	var keyboard_handler = get_node_or_null("/root/KeyboardInputHandler")
	
	if not touch_handler or not keyboard_handler:
		push_error("Input handlers not found!")
		return
	
	# Clear any pending input state when switching
	if touch_controls_enabled:
		# Switching to touch - clear keyboard state
		if keyboard_handler.has_method("clear_state"):
			keyboard_handler.clear_state()
	else:
		# Switching to keyboard - clear touch state
		if touch_handler.has_method("clear_state"):
			touch_handler.clear_state()
	
	# Find the player ship and switch its input handler
	var ships = get_tree().get_nodes_in_group("player")
	if ships.size() > 0:
		var ship = ships[0]
		if ship.has_method("switch_input_handler"):
			if touch_controls_enabled:
				ship.switch_input_handler(touch_handler)
				print("Switched to TouchInputHandler")
			else:
				ship.switch_input_handler(keyboard_handler)
				print("Switched to KeyboardInputHandler")
		else:
			print("Ship doesn't have switch_input_handler method")
	else:
		print("No player ship found in group")
		# If no ship exists yet, the input handler will be set when ship is created
