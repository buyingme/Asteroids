# Asteroids Godot Port - Setup Instructions

## Quick Start

### 1. Prerequisites
- **Godot Engine 4.2+** - Download from https://godotengine.org/

### 2. Asset Setup

The project needs audio and font assets from the original Python project:

```bash
# Audio files (should already be copied)
asteroids_godot/assets/sounds/
  ├── bang.wav
  ├── bangLarge.wav
  ├── bangMedium.wav
  ├── bangSmall.wav
  ├── beat1.wav
  ├── beat2.wav
  ├── extraShip.wav
  ├── fire.wav
  ├── saucerBig.wav
  ├── saucerSmall.wav
  └── thrust.wav

# Font file
asteroids_godot/assets/fonts/
  └── Hyperspace.otf
```

### 3. Open Project in Godot

1. Launch Godot Engine
2. Click "Import"
3. Navigate to `/Users/Katharina/python/ast_atari/asteroids_godot/`
4. Select `project.godot`
5. Click "Import & Edit"

### 4. Initial Scene Setup

The project will open with the menu scene. To test the game:

1. Press **F5** or click the **Play** button to run the project
2. Select `scenes/ui/menu.tscn` as the main scene if prompted

### 5. Game Controls

- **← →** - Rotate ship
- **↑** - Thrust
- **Space** - Fire
- **H** - Hyperspace jump

## Project Structure

```
asteroids_godot/
├── project.godot          # Project configuration
├── icon.svg              # Project icon
├── README.md             # Main documentation
├── SETUP.md             # This file
│
├── autoload/             # Singleton/autoload scripts
│   ├── screen_wrapper.gd
│   ├── audio_manager.gd
│   └── score_manager.gd
│
├── scripts/              # Game logic
│   ├── vector_sprite.gd  # Base class
│   ├── ship.gd
│   ├── rock.gd
│   ├── bullet.gd
│   ├── debris.gd
│   ├── saucer.gd
│   ├── game_manager.gd
│   └── ui/
│       ├── hud.gd
│       ├── menu.gd
│       ├── game_over.gd
│       └── highscore_entry.gd
│
├── scenes/               # Scene files
│   ├── main.tscn        # Main game scene
│   ├── ship.tscn
│   ├── rock.tscn
│   ├── bullet.tscn
│   ├── debris.tscn
│   ├── saucer.tscn
│   └── ui/
│       ├── hud.tscn
│       ├── menu.tscn
│       ├── game_over.tscn
│       └── highscore_entry.tscn
│
└── assets/               # Game assets
    ├── sounds/          # Audio files (.wav)
    └── fonts/           # Font files (.otf)
```

## Testing the Game

### Run Individual Scenes

You can test individual components by opening and running specific scenes:

- **Menu**: `scenes/ui/menu.tscn` (F6)
- **Main Game**: `scenes/main.tscn` (F6)
- **Game Over**: `scenes/ui/game_over.tscn` (F6)

### Debugging Tips

1. **Check Console Output**: View > Output panel shows print statements and errors
2. **Remote Debugger**: Opens automatically when running (F5)
3. **Scene Tree**: Shows all active nodes in the current scene
4. **Inspector**: Select a node to view/edit its properties

### Common Issues

**No Sound Playing**:
- Verify audio files are in `assets/sounds/`
- Check AudioManager autoload is enabled
- Ensure audio files are imported (check .import folder)

**Ship Not Moving**:
- Check input map in Project Settings > Input Map
- Verify ship scene is properly instantiated in main.tscn

**Collisions Not Working**:
- Ensure collision polygons are set up in scenes
- Check GameManager collision detection logic

## Customization

### Adjusting Game Parameters

Edit constants in respective scripts:

**Ship Physics** ([scripts/ship.gd](scripts/ship.gd)):
```gdscript
const ACCELERATION = 200.0
const MAX_SPEED = 400.0
const ROTATION_SPEED = 4.0
```

**Rock Spawning** ([scripts/game_manager.gd](scripts/game_manager.gd)):
```gdscript
var rocks_per_wave = 4
var current_wave = 1
```

**Audio Levels** ([autoload/audio_manager.gd](autoload/audio_manager.gd)):
```gdscript
var master_volume = 0.7
```

### Adding New Features

The codebase is structured for easy extension:

1. **New Enemy Types**: Extend VectorSprite class
2. **Power-ups**: Create new scene + script
3. **Visual Effects**: Add debris particles or shaders
4. **Sound Effects**: Add to AudioManager autoload

## Export Configuration

### Export for Desktop

1. Go to **Project > Export**
2. Add export template for your platform:
   - Windows Desktop
   - macOS
   - Linux/X11
3. Configure export settings
4. Click **Export Project**

### Export for Web

1. Add HTML5 export template
2. Configure export settings:
   - Head Include: Add any custom HTML
   - Custom HTML Shell: Optional custom template
3. Export to folder
4. Serve via HTTP server (required for Web Assembly)

```bash
# Simple HTTP server for testing
python3 -m http.server 8000
```

Then open http://localhost:8000 in your browser.

## Performance Optimization

For optimal performance:

1. **Enable V-Sync**: Project Settings > Display > Window > Vsync Mode
2. **Reduce Particles**: Lower debris count in Rock.gd
3. **Optimize Collision**: Reduce polygon complexity if needed
4. **Audio Streaming**: For larger sounds, enable streaming in import settings

## Next Steps

- **Play the game!** Press F5 and enjoy
- **Modify gameplay**: Adjust constants for different feel
- **Add features**: Implement power-ups, different enemy types
- **Polish**: Add particle effects, screen shake, better UI
- **Share**: Export and share your version!

## Troubleshooting

If you encounter issues:

1. Check the Godot console for error messages
2. Verify all asset files are present
3. Ensure autoload scripts are configured
4. Try reimporting the project
5. Check that Godot version is 4.2 or higher

## Support

For questions about the original Python implementation, see:
- `/src/` directory for original code
- `GODOT_PORT_PLAN.md` for architecture details
- `ANALYSIS_SUMMARY.md` for game mechanics

For Godot-specific questions:
- Official Docs: https://docs.godotengine.org/
- Community: https://godotengine.org/community

---

**Have fun playing and modifying your Asteroids game!**
