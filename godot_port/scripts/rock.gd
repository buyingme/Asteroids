extends VectorSprite
class_name Rock
## Asteroid rock with splitting behavior
## Ported from Python badies.py

enum RockType { LARGE = 0, MEDIUM = 1, SMALL = 2 }

# Constants from Python Rock class
const VELOCITIES = [1.5, 3.0, 4.5]
const SCALES = [2.5, 1.5, 0.6]
const SCORES = [50, 100, 200]

var rock_type: RockType
var score_value: int
var initial_position: Vector2 = Vector2.ZERO

# Track rock shape generation
static var rock_shape_counter: int = 1

func _init(type: RockType = RockType.LARGE, pos: Vector2 = Vector2.ZERO):
	rock_type = type
	score_value = SCORES[rock_type]
	initial_position = pos
	
	print("Rock created: type=%d, score_value=%d, position=(%f,%f)" % [rock_type, score_value, pos.x, pos.y])
	
	# Create rock shape
	point_list = create_rock_shape()
	
	# Scale points based on rock size
	var scale = SCALES[rock_type]
	point_list = scale_points(scale)
	
	# Random velocity based on size
	var velocity = VELOCITIES[rock_type]
	heading = Vector2(
		randf_range(-velocity, velocity),
		randf_range(-velocity, velocity)
	)
	
	# Ensure non-zero velocity
	if abs(heading.x) < 0.1:
		heading.x = 0.1 if heading.x >= 0 else -0.1
	if abs(heading.y) < 0.1:
		heading.y = 0.1 if heading.y >= 0 else -0.1
	
	# Random rotation
	angle_velocity = randf_range(-1.0, 1.0)
	
	sprite_color = Color.WHITE

func _ready():
	super._ready()
	# Apply initial position if set
	if initial_position != Vector2.ZERO:
		position = initial_position

func create_rock_shape() -> PackedVector2Array:
	"""Create one of 4 rock shapes from Python"""
	var shape_num = rock_shape_counter
	rock_shape_counter = (rock_shape_counter % 4) + 1  # Cycle 1-4
	
	match shape_num:
		1:  # Shape 1
			return PackedVector2Array([
				Vector2(-4, -12), Vector2(6, -12), Vector2(13, -4),
				Vector2(13, 5), Vector2(6, 13), Vector2(0, 13),
				Vector2(0, 4), Vector2(-8, 13), Vector2(-15, 4),
				Vector2(-7, 1), Vector2(-15, -3)
			])
		2:  # Shape 2
			return PackedVector2Array([
				Vector2(-6, -12), Vector2(1, -5), Vector2(8, -12),
				Vector2(15, -5), Vector2(12, 0), Vector2(15, 6),
				Vector2(5, 13), Vector2(-7, 13), Vector2(-14, 7),
				Vector2(-14, -5)
			])
		3:  # Shape 3
			return PackedVector2Array([
				Vector2(-7, -12), Vector2(1, -9), Vector2(8, -12),
				Vector2(15, -5), Vector2(8, -3), Vector2(15, 4),
				Vector2(8, 12), Vector2(-3, 10), Vector2(-6, 12),
				Vector2(-14, 7), Vector2(-10, 0), Vector2(-14, -5)
			])
		4:  # Shape 4
			return PackedVector2Array([
				Vector2(-7, -11), Vector2(3, -11), Vector2(13, -5),
				Vector2(13, -2), Vector2(2, 2), Vector2(13, 8),
				Vector2(6, 14), Vector2(2, 10), Vector2(-7, 14),
				Vector2(-15, 5), Vector2(-15, -5), Vector2(-5, -5),
				Vector2(-7, -11)
			])
		_:
			return PackedVector2Array()

func split() -> Array:
	"""Split rock into two smaller rocks"""
	if rock_type == RockType.SMALL:
		return []  # Don't split small rocks
	
	var new_rocks = []
	var new_type = rock_type + 1 as RockType
	
	# Create two new smaller rocks
	for i in range(2):
		var rock = Rock.new(new_type, position)
		new_rocks.append(rock)
	
	# Play appropriate explosion sound
	match rock_type:
		RockType.LARGE:
			AudioManager.play_sound("explode1")
		RockType.MEDIUM:
			AudioManager.play_sound("explode2")
		RockType.SMALL:
			AudioManager.play_sound("explode3")
	
	return new_rocks
