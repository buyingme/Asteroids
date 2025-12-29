extends VectorSprite
class_name Debris
## Small particle for explosion effects

var ttl: int = 50

func _ready():
	# If no point list provided, create a small point
	if point_list.size() == 0:
		point_list = PackedVector2Array([
			Vector2(0, 0),
			Vector2(1, 1),
			Vector2(1, 0),
			Vector2(0, 1)
		])
	
	sprite_color = Color.WHITE
	super._ready()

func _physics_process(delta: float):
	ttl -= 1
	
	# Fade out
	var fade = float(ttl) / 50.0
	sprite_color = Color(fade, fade, fade)
	
	if ttl <= 0:
		queue_free()
	
	super._physics_process(delta)
