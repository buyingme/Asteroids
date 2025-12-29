# Godot Port - Quick Start Guide

## Step 1: Install Godot

Download and install Godot Engine 4.2 or later from:
https://godotengine.org/download

## Step 2: Open the Project

1. Launch Godot Engine
2. Click "Import" on the project manager
3. Click "Browse" and navigate to: `/Users/Katharina/python/ast_atari/godot_port`
4. Select the `project.godot` file
5. Click "Import & Edit"

## Step 3: Optional - Add Sound Files

For full audio experience, copy sound files from your original `res/` directory:

```bash
# From terminal, run:
cd /Users/Katharina/python/ast_atari
cp res/*.wav godot_port/assets/sounds/
```

Required sound files:
- fire.wav
- thrust.wav
- explode1.wav
- explode2.wav
- explode3.wav
- lsaucer.wav
- ssaucer.wav
- sfire.wav
- extralife.wav

Then in Godot, update [audio_manager.gd](godot_port/autoload/audio_manager.gd) to load them in `_ready()`:

```gdscript
func _ready():
    # ... existing code ...
    
    # Load sound files
    load_sound("fire", "res://assets/sounds/fire.wav")
    load_sound("thrust", "res://assets/sounds/thrust.wav")
    load_sound("explode1", "res://assets/sounds/explode1.wav")
    load_sound("explode2", "res://assets/sounds/explode2.wav")
    load_sound("explode3", "res://assets/sounds/explode3.wav")
    load_sound("lsaucer", "res://assets/sounds/lsaucer.wav")
    load_sound("ssaucer", "res://assets/sounds/ssaucer.wav")
    load_sound("sfire", "res://assets/sounds/sfire.wav")
    load_sound("extralife", "res://assets/sounds/extralife.wav")
```

## Step 4: Run the Game

1. In Godot editor, press **F5** or click the **Play** button (▶)
2. The game window should open showing the title screen
3. Press **ENTER** to start playing

## Step 5: Play!

### Controls:
- **W** or **Up Arrow** - Thrust forward
- **A** or **Left Arrow** - Rotate left
- **D** or **Right Arrow** - Rotate right
- **Space** - Fire bullets
- **H** - Hyperspace (random teleport)
- **Enter** - Start game / Continue after game over

### Gameplay:
- Destroy asteroids to score points
- Large asteroids split into medium, medium into small
- Watch out for flying saucers (they shoot at you!)
- Earn extra life every 10,000 points
- Hyperspace can save you but teleports you randomly

## Troubleshooting

### Game won't start
- Make sure you selected the correct `project.godot` file
- Check Godot version is 4.2 or later
- Look for errors in Godot's Output panel (bottom of editor)

### No sound
- Sound files need to be manually added (Step 3)
- Game will work fine without sounds
- Check Output panel for audio loading errors

### Ship not moving correctly
- All physics constants match Python version
- Check that input actions are properly configured in Project Settings
- Try closing and reopening the project

### Can't see anything
- Make sure [main.tscn](godot_port/scenes/main.tscn) is set as the main scene
- Check that TitleScreen is visible in the scene tree
- Verify screen_wrapper.gd is loaded in autoload settings

## Debugging

To see debug output:
1. Open [game_manager.gd](godot_port/scripts/game_manager.gd)
2. Add `print()` statements where needed
3. View output in Godot's Output panel while running

Example:
```gdscript
func check_collisions():
    print("Checking collisions, rocks: ", rocks.size())
    # ... rest of function
```

## Comparing with Python Version

To verify the port matches the original:

1. **Run Python version**: `python src/asteroids.py`
2. **Run Godot version**: Press F5 in Godot
3. **Compare**:
   - Ship movement feel
   - Asteroid behavior
   - Collision detection
   - Scoring
   - Saucer AI

All game constants (speeds, sizes, scores) are identical between versions.

## Next Steps

Once the basic game runs:

1. **Tweak settings** in `project.godot`:
   - Window size
   - Display mode (fullscreen/windowed)
   - Input mappings

2. **Customize visuals** in the scripts:
   - Change `sprite_color` values
   - Modify `line_width` for thicker/thinner lines
   - Add trails or particle effects

3. **Export game**:
   - Go to Project → Export
   - Configure export templates
   - Build for Windows/Mac/Linux/Web

## Getting Help

If you encounter issues:

1. Check IMPLEMENTATION_NOTES.md for technical details
2. Review the Python test suite for expected behavior
3. Compare GDScript to Python source line-by-line
4. Check Godot documentation: https://docs.godotengine.org/

## Success Checklist

- [ ] Godot 4.2+ installed
- [ ] Project imported successfully
- [ ] Game runs (title screen visible)
- [ ] Ship responds to controls
- [ ] Asteroids appear and move
- [ ] Collision detection works
- [ ] Score increments correctly
- [ ] Saucer appears and shoots
- [ ] (Optional) Sounds play

Enjoy your vector Asteroids game in Godot! 🚀
