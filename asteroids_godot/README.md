# Asteroids - Godot Port

A complete port of the classic Atari Asteroids game from Python/Pygame to Godot 4.2+.

## Project Structure

```
asteroids_godot/
├── project.godot           # Main project configuration
├── autoload/              # Global singletons
│   ├── screen_wrapper.gd  # Screen edge wrapping
│   ├── audio_manager.gd   # Sound effects
│   └── score_manager.gd   # Score and lives tracking
├── scripts/               # Game logic
│   ├── vector_sprite.gd   # Base class for vector graphics
│   ├── ship.gd           # Player ship
│   ├── rock.gd           # Asteroids
│   ├── bullet.gd         # Projectiles
│   ├── debris.gd         # Explosion particles
│   ├── saucer.gd         # Enemy saucer
│   ├── game_manager.gd   # Main game controller
│   └── ui/
│       └── hud.gd        # Score and lives display
├── scenes/               # Scene files
│   ├── main.tscn         # Main game scene
│   ├── ship.tscn         # Ship scene
│   ├── bullet.tscn       # Bullet scene
│   ├── debris.tscn       # Debris scene
│   └── ui/
│       └── hud.tscn      # HUD scene
└── assets/               # Audio and fonts
    ├── sounds/           # Sound effects (copy from ../res/)
    └── fonts/            # Fonts (copy from ../res/)
```

## Setup Instructions

### 1. Install Godot

Download Godot 4.2 or later from https://godotengine.org/

### 2. Copy Assets

Copy audio and font files from the Python version:

```bash
# From the python project root
mkdir -p asteroids_godot/assets/sounds
mkdir -p asteroids_godot/assets/fonts

# Copy sound files
cp res/*.WAV asteroids_godot/assets/sounds/
# Rename to lowercase for consistency
cd asteroids_godot/assets/sounds
for f in *.WAV; do mv "$f" "${f%.WAV}.wav"; done

# Copy font
cp res/Hyperspace.otf asteroids_godot/assets/fonts/
```

### 3. Open in Godot

1. Launch Godot Engine
2. Click "Import"
3. Browse to `asteroids_godot/project.godot`
4. Click "Import & Edit"

### 4. Run the Game

- Press **F5** or click the Play button
- Or set `scenes/main.tscn` as the main scene if not already set

## Controls

- **W / Up Arrow** - Thrust
- **A / Left Arrow** - Rotate Left
- **D / Right Arrow** - Rotate Right
- **Space** - Fire
- **H** - Hyperspace
- **Enter** - Start Game / Restart
- **P** - Pause (to be implemented)

## Features Implemented

✅ **Core Gameplay**
- Vector-based graphics (polygon rendering)
- Physics-based ship movement
- Screen wrapping (toroidal topology)
- Ship rotation and thrust
- Bullet firing with limit
- Hyperspace teleport

✅ **Asteroids**
- 4 different rock shapes
- 3 size variants (large, medium, small)
- Rock splitting on destruction
- Increasing difficulty per level

✅ **Enemy Saucer**
- Two types (large and small)
- AI targeting with accuracy based on type
- Shoots at player
- Different scores

✅ **Game Systems**
- Score tracking
- Lives system
- Extra life at 10,000 points
- High score table (persistence)
- Game states (attract, playing, game over)

✅ **Visual Effects**
- Explosion debris particles
- Thrust jet animation
- Fading debris

✅ **Audio**
- Sound effects for all actions
- Continuous sounds (thrust, saucer)
- Explosion sounds

## Differences from Python Version

1. **Scene-based Architecture** - Uses Godot's scene system instead of manual sprite lists
2. **Signal System** - Uses signals for score/lives events instead of direct calls
3. **Built-in Physics** - Uses Godot's delta time for frame-rate independence
4. **Autoloads** - Global singletons for screen wrapping, audio, and score
5. **Collision Detection** - Uses Godot's Area2D instead of custom polygon collision

## To-Do / Future Enhancements

- [ ] High score name entry screen
- [ ] Pause functionality
- [ ] Sound volume controls
- [ ] Particle effects for thrust
- [ ] Screen shake on collisions
- [ ] Mobile touch controls
- [ ] Gamepad support
- [ ] Web export optimization
- [ ] Advanced polygon collision (currently using Area2D)

## Development Notes

### Performance

- Game runs at 60 FPS equivalent (delta time scaled by 60)
- Physics updates use `_physics_process` for consistency
- Drawing uses `queue_redraw()` for efficient rendering

### Code Organization

- **VectorSprite** - Base class handles movement and drawing
- **Autoloads** - Three global singletons manage cross-cutting concerns
- **Signals** - Clean communication between game manager and UI

### Porting Details

The port maintains the original game's feel while leveraging Godot's features:

- Original Python constants preserved (acceleration, velocities, etc.)
- Rock shapes copied exactly from Python version
- Scoring system matches original
- Physics tuned to feel identical

## Credits

Original Python/Pygame version:
- Nick Redshaw (2008)
- Francisco Sanchez Arroyo (2018)

Godot Port:
- 2025

Based on:
- Atari Asteroids (1979)

## License

GPL-3.0 (same as original Python version)
