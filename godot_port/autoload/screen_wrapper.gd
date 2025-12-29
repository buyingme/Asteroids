extends Node
## Autoload singleton for screen wrapping (toroidal topology)
## Wraps sprite positions when they leave the screen edges

var screen_size: Vector2

func _ready():
	# Get viewport size
	var viewport = get_viewport()
	if viewport:
		screen_size = viewport.get_visible_rect().size
	else:
		screen_size = Vector2(1024, 768)  # Fallback
	
	# Listen for viewport size changes
	get_tree().root.size_changed.connect(_on_viewport_size_changed)

func _on_viewport_size_changed():
	screen_size = get_viewport().get_visible_rect().size

func wrap_position(position: Vector2) -> Vector2:
	"""Wrap position to opposite edge when leaving screen"""
	var wrapped = position
	
	# Horizontal wrapping
	if wrapped.x < 0:
		wrapped.x = screen_size.x
	elif wrapped.x > screen_size.x:
		wrapped.x = 0
	
	# Vertical wrapping
	if wrapped.y < 0:
		wrapped.y = screen_size.y
	elif wrapped.y > screen_size.y:
		wrapped.y = 0
	
	return wrapped
