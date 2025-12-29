extends Node
## Screen wrapping utility for toroidal topology
## Autoload singleton that handles sprite wrapping at screen edges

var screen_size: Vector2

func _ready():
	screen_size = Vector2(
		ProjectSettings.get_setting("display/window/size/viewport_width"),
		ProjectSettings.get_setting("display/window/size/viewport_height")
	)

func wrap_position(pos: Vector2) -> Vector2:
	"""Wrap position to opposite edge when leaving screen"""
	var wrapped = pos
	
	if wrapped.x < 0:
		wrapped.x = screen_size.x
	elif wrapped.x > screen_size.x:
		wrapped.x = 0
		
	if wrapped.y < 0:
		wrapped.y = screen_size.y
	elif wrapped.y > screen_size.y:
		wrapped.y = 0
		
	return wrapped
