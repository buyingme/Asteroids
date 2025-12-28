# Asteroids Godot Port - Quick Start Guide

## Prerequisites

- Godot Engine 4.2+ installed
- Familiarity with GDScript (similar to Python)
- Basic understanding of Godot's node system

## Step-by-Step Implementation

### Step 1: Create New Godot Project (15 mins)

```bash
# Create project directory
mkdir asteroids_godot
cd asteroids_godot
```

In Godot Editor:
1. **Project > New Project**
2. Set name to "Asteroids"
3. Set renderer to "Forward+" or "Mobile"
4. Create project

### Step 2: Project Structure (10 mins)

Create folder structure:
```
asteroids_godot/
├── scenes/
│   ├── main.tscn
│   ├── ship.tscn
│   ├── rock.tscn
│   ├── bullet.tscn
│   └── ui/
├── scripts/
│   ├── game_manager.gd
│   ├── ship.gd
│   ├── rock.gd
│   └── utils/
├── assets/
│   ├── fonts/
│   └── sounds/
└── autoload/
    ├── screen_wrapper.gd
    └── audio_manager.gd
```

### Step 3: Core Utility - ScreenWrapper (30 mins)

**File:** `autoload/screen_wrapper.gd`

```gdscript
extends Node
# Autoload singleton for screen wrapping

var screen_size: Vector2

func _ready():
    screen_size = get_viewport().get_visible_rect().size

func wrap_position(position: Vector2) -> Vector2:
    """Wrap position to opposite edge when leaving screen"""
    var wrapped = position
    
    if wrapped.x < 0:
        wrapped.x = screen_size.x
    elif wrapped.x > screen_size.x:
        wrapped.x = 0
        
    if wrapped.y < 0:
        wrapped.y = screen_size.y
    elif wrapped.y > screen_size.y:
        wrapped.y = 0
        
    return wrapped
```

**Register as Autoload:**
1. Project > Project Settings > Autoload
2. Add `screen_wrapper.gd` with name "ScreenWrapper"

### Step 4: Base VectorSprite Class (1 hour)

**File:** `scripts/utils/vector_sprite.gd`

```gdscript
extends Node2D
class_name VectorSprite

# Properties from Python VectorSprite
var heading: Vector2 = Vector2.ZERO
var angle_velocity: float = 0.0
var point_list: PackedVector2Array = []
var sprite_color: Color = Color.WHITE

# Collision
var collision_shape: CollisionShape2D

func _init(points: PackedVector2Array = PackedVector2Array()):
    point_list = points

func _ready():
    pass

func _physics_process(delta: float):
    move_sprite(delta)
    queue_redraw()  # Trigger _draw()

func move_sprite(delta: float):
    """Move sprite by heading vector"""
    position += heading * delta * 60.0  # Scale for 60 FPS
    rotation_degrees += angle_velocity * delta * 60.0
    
    # Wrap around screen
    position = ScreenWrapper.wrap_position(position)

func _draw():
    """Draw vector shape"""
    if point_list.size() < 2:
        return
    
    # Draw polygon outline
    draw_polyline(point_list, sprite_color, 1.0, true)

func scale_points(scale: float) -> PackedVector2Array:
    """Scale all points by factor"""
    var scaled = PackedVector2Array()
    for point in point_list:
        scaled.append(point * scale)
    return scaled
```

### Step 5: Ship Implementation (2 hours)

**File:** `scripts/ship.gd`

```gdscript
extends VectorSprite
class_name Ship

# Physics constants (from Python Ship class)
const ACCELERATION = 0.2
const DECELERATION = -0.005
const MAX_VELOCITY = 10.0
const TURN_SPEED = 6.0  # degrees per frame
const BULLET_VELOCITY = 13.0
const MAX_BULLETS = 4

# State
var in_hyperspace: bool = false
var hyperspace_timer: float = 0.0
var bullets: Array = []

func _ready():
    # Ship shape from Python: [(0, -10), (6, 10), (3, 7), (-3, 7), (-6, 10)]
    point_list = PackedVector2Array([
        Vector2(0, -10),
        Vector2(6, 10),
        Vector2(3, 7),
        Vector2(-3, 7),
        Vector2(-6, 10)
    ])
    
    sprite_color = Color.WHITE
    
    # Start at center
    position = get_viewport_rect().size / 2
    
    super._ready()

func _physics_process(delta: float):
    handle_input(delta)
    apply_deceleration(delta)
    super._physics_process(delta)
    
    # Hyperspace timer
    if in_hyperspace:
        hyperspace_timer -= delta
        if hyperspace_timer <= 0:
            exit_hyperspace()

func handle_input(delta: float):
    """Process player input"""
    # Rotation
    if Input.is_action_pressed("ui_left"):
        rotation_degrees += TURN_SPEED
    if Input.is_action_pressed("ui_right"):
        rotation_degrees -= TURN_SPEED
    
    # Thrust
    if Input.is_action_pressed("ui_up"):
        apply_thrust()
    
    # Fire
    if Input.is_action_just_pressed("ui_accept"):  # Space
        fire_bullet()
    
    # Hyperspace
    if Input.is_action_just_pressed("ui_cancel"):  # Escape -> remap to H
        enter_hyperspace()

func apply_thrust():
    """Increase velocity in facing direction"""
    if heading.length() > MAX_VELOCITY:
        return
    
    # Calculate thrust vector from rotation
    var thrust_dir = Vector2(0, -1).rotated(rotation)
    heading += thrust_dir * ACCELERATION

func apply_deceleration(delta: float):
    """Gradually slow down"""
    if heading.length() > 0:
        heading += heading * DECELERATION

func fire_bullet():
    """Create a bullet"""
    if bullets.size() >= MAX_BULLETS:
        return
    
    if in_hyperspace:
        return
    
    # Create bullet (to be implemented)
    var bullet = preload("res://scenes/bullet.tscn").instantiate()
    var bullet_dir = Vector2(0, -1).rotated(rotation)
    bullet.position = position
    bullet.heading = bullet_dir * BULLET_VELOCITY
    
    get_parent().add_child(bullet)
    bullets.append(bullet)
    
    # TODO: Play sound

func enter_hyperspace():
    """Teleport to random location"""
    if in_hyperspace:
        return
    
    in_hyperspace = true
    hyperspace_timer = 100.0 / 60.0  # 100 frames at 60 FPS
    sprite_color = Color.TRANSPARENT
    modulate.a = 0.0

func exit_hyperspace():
    """Return from hyperspace"""
    in_hyperspace = false
    sprite_color = Color.WHITE
    modulate.a = 1.0
    
    # Random position
    var viewport_size = get_viewport_rect().size
    position = Vector2(
        randf_range(0, viewport_size.x),
        randf_range(0, viewport_size.y)
    )

func explode():
    """Break ship into debris"""
    # TODO: Create line segment debris
    pass
```

**Create Ship Scene:**
1. Scene > New Scene > Node2D (rename to "Ship")
2. Attach `ship.gd` script
3. Add `Area2D` child for collision
4. Add `CollisionPolygon2D` to Area2D
5. Set collision points to match ship shape
6. Save as `scenes/ship.tscn`

### Step 6: Rock Implementation (1.5 hours)

**File:** `scripts/rock.gd`

```gdscript
extends VectorSprite
class_name Rock

enum RockType { LARGE, MEDIUM, SMALL }

# Constants from Python Rock class
const VELOCITIES = [1.5, 3.0, 4.5]
const SCALES = [2.5, 1.5, 0.6]
const SCORES = [50, 100, 200]

var rock_type: RockType
var score_value: int

func _init(type: RockType = RockType.LARGE):
    rock_type = type
    score_value = SCORES[rock_type]
    
    # Create rock shape
    point_list = create_rock_shape()
    
    # Scale points
    var scale = SCALES[rock_type]
    point_list = scale_points(scale)
    
    # Random velocity
    var velocity = VELOCITIES[rock_type]
    heading = Vector2(
        randf_range(-velocity, velocity),
        randf_range(-velocity, velocity)
    )
    
    # Ensure non-zero velocity
    if heading.x == 0:
        heading.x = 0.1
    if heading.y == 0:
        heading.y = 0.1
    
    # Random rotation
    angle_velocity = randf_range(-1.0, 1.0)

func create_rock_shape() -> PackedVector2Array:
    """Create one of 4 rock shapes"""
    var shape_num = randi() % 4
    
    match shape_num:
        0:  # Shape 1
            return PackedVector2Array([
                Vector2(-4, -12), Vector2(6, -12), Vector2(13, -4),
                Vector2(13, 5), Vector2(6, 13), Vector2(0, 13),
                Vector2(0, 4), Vector2(-8, 13), Vector2(-15, 4),
                Vector2(-7, 1), Vector2(-15, -3)
            ])
        1:  # Shape 2
            return PackedVector2Array([
                Vector2(-6, -12), Vector2(1, -5), Vector2(8, -12),
                Vector2(15, -5), Vector2(12, 0), Vector2(15, 6),
                Vector2(5, 13), Vector2(-7, 13), Vector2(-14, 7),
                Vector2(-14, -5)
            ])
        2:  # Shape 3
            return PackedVector2Array([
                Vector2(-7, -12), Vector2(1, -9), Vector2(8, -12),
                Vector2(15, -5), Vector2(8, -3), Vector2(15, 4),
                Vector2(8, 12), Vector2(-3, 10), Vector2(-6, 12),
                Vector2(-14, 7), Vector2(-10, 0), Vector2(-14, -5)
            ])
        3:  # Shape 4
            return PackedVector2Array([
                Vector2(-7, -11), Vector2(3, -11), Vector2(13, -5),
                Vector2(13, -2), Vector2(2, 2), Vector2(13, 8),
                Vector2(6, 14), Vector2(2, 10), Vector2(-7, 14),
                Vector2(-15, 5), Vector2(-15, -5), Vector2(-5, -5),
                Vector2(-7, -11)
            ])
    
    return PackedVector2Array()

func split() -> Array:
    """Split rock into two smaller rocks"""
    if rock_type == RockType.SMALL:
        return []  # Don't split small rocks
    
    var new_rocks = []
    var new_type = rock_type + 1  # Next smaller size
    
    for i in range(2):
        var rock = Rock.new(new_type)
        rock.position = position
        new_rocks.append(rock)
    
    return new_rocks
```

### Step 7: Main Game Scene (1 hour)

**File:** `scripts/game_manager.gd`

```gdscript
extends Node2D

# Game state
enum GameState { ATTRACT, PLAYING, EXPLODING }
var current_state: GameState = GameState.ATTRACT

# Game objects
var ship: Ship
var rocks: Array = []
var score: int = 0
var lives: int = 3

func _ready():
    start_game()

func start_game():
    current_state = GameState.PLAYING
    score = 0
    lives = 3
    
    # Create ship
    ship = preload("res://scenes/ship.tscn").instantiate()
    add_child(ship)
    
    # Create initial rocks
    spawn_rocks(3)

func spawn_rocks(count: int):
    for i in range(count):
        var rock = Rock.new(Rock.RockType.LARGE)
        rock.position = Vector2(
            randf_range(0, get_viewport_rect().size.x),
            randf_range(0, get_viewport_rect().size.y)
        )
        add_child(rock)
        rocks.append(rock)

func _process(delta: float):
    match current_state:
        GameState.PLAYING:
            check_collisions()
            
            # Level complete?
            if rocks.size() == 0:
                next_level()

func check_collisions():
    """Check for collisions between game objects"""
    # TODO: Implement collision checking
    pass

func next_level():
    """Progress to next level with more rocks"""
    spawn_rocks(rocks.size() + 1)
```

**Create Main Scene:**
1. Scene > New Scene > Node2D (rename to "Main")
2. Attach `game_manager.gd`
3. Save as `scenes/main.tscn`
4. Set as main scene: Project > Project Settings > Application > Run > Main Scene

### Step 8: Input Mapping (10 mins)

**Project > Project Settings > Input Map:**

Add actions:
- `thrust` → W / Up Arrow
- `rotate_left` → A / Left Arrow
- `rotate_right` → D / Right Arrow
- `fire` → Space
- `hyperspace` → H

### Step 9: Testing & Iteration (ongoing)

**Run the game:**
- Press F5 or click Play button
- Test ship controls
- Add rocks
- Iterate on feel

### Quick Reference: Python → GDScript

```python
# Python
class Ship(Shooter):
    def __init__(self, stage):
        position = Vector2d(x, y)
        self.heading = Vector2d(0, 0)
    
    def move(self):
        self.position.x += self.heading.x
        self.position.y += self.heading.y
```

```gdscript
# GDScript
extends Shooter
class_name Ship

func _ready():
    position = Vector2(x, y)
    heading = Vector2.ZERO

func _physics_process(delta):
    position += heading * delta * 60.0
```

## Next Steps

1. ✅ Complete ship with thrust jet visual
2. ✅ Implement bullet system
3. ✅ Add collision detection
4. ✅ Implement rock splitting
5. ✅ Add saucer enemy
6. ✅ Create UI (score, lives)
7. ✅ Add sound effects
8. ✅ Polish and juice

## Helpful Godot Resources

- **Official Docs:** https://docs.godotengine.org/
- **2D Movement Tutorial:** https://docs.godotengine.org/en/stable/tutorials/2d/2d_movement.html
- **Signal System:** https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html
- **GDScript Basics:** https://docs.godotengine.org/en/stable/getting_started/scripting/gdscript/gdscript_basics.html

## Tips

1. **Use Signals:** Instead of direct method calls, use Godot's signal system
2. **Scene Instancing:** Create separate scenes for each game object
3. **Autoloads:** Use for global state (score, audio, etc.)
4. **Delta Time:** Always use `delta` for frame-rate independent movement
5. **Vector Math:** Godot's Vector2 has built-in methods (length(), normalized(), etc.)

---

**Ready to start?** Open Godot and begin with Step 1! 🚀
