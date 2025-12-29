extends VectorSprite
class_name Bullet
## Bullet/projectile with time-to-live
## Ported from Python shooter.py and vectorsprites.py

var ttl: int = 30  # Time to live in frames
var shooter = null  # Reference to who shot the bullet
var velocity_magnitude: float = 0.0

func _init():
	# Simple point/small square for bullet
	point_list = PackedVector2Array([
		Vector2(0, 0),
		Vector2(1, 1),
		Vector2(1, 0),
		Vector2(0, 1)
	])
	sprite_color = Color.WHITE

func _ready():
	super._ready()
	velocity_magnitude = heading.length()

func _physics_process(delta: float):
	# Decrement TTL
	ttl -= 1
	
	if ttl <= 0:
		queue_free()
		return
	
	# Move bullet
	super._physics_process(delta)

func _on_hit():
	"""Called when bullet hits something"""
	ttl = 0
	queue_free()
