extends VectorSprite
class_name Bullet
## Projectile fired by ship or saucer

var ttl: int = 30
var owner_ship: Node = null
var collision_area: Area2D

func _ready():
	# Small point for bullet
	point_list = PackedVector2Array([
		Vector2(-1, -1),
		Vector2(1, -1),
		Vector2(1, 1),
		Vector2(-1, 1)
	])
	
	sprite_color = Color.WHITE
	
	# Create collision area
	collision_area = Area2D.new()
	add_child(collision_area)
	
	var collision_shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = 3
	collision_shape.shape = circle
	collision_area.add_child(collision_shape)
	
	super._ready()

func _physics_process(delta: float):
	ttl -= 1
	if ttl <= 0:
		remove_from_owner()
		queue_free()
	
	super._physics_process(delta)

func hit_target():
	"""Bullet hit something, remove it"""
	remove_from_owner()
	queue_free()

func remove_from_owner():
	"""Remove bullet from owner's tracking"""
	if owner_ship and owner_ship.has_method("remove_bullet"):
		owner_ship.remove_bullet(self)
