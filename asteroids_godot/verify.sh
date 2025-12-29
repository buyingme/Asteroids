#!/bin/bash

# Asteroids Godot Port - Verification Script
# Run this to verify all files are present and ready

echo "═══════════════════════════════════════════════════"
echo "  ASTEROIDS GODOT PORT - VERIFICATION"
echo "═══════════════════════════════════════════════════"
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counters
total_checks=0
passed_checks=0

check_file() {
    total_checks=$((total_checks + 1))
    if [ -f "$1" ]; then
        echo -e "${GREEN}✓${NC} $2"
        passed_checks=$((passed_checks + 1))
        return 0
    else
        echo -e "${RED}✗${NC} $2 - MISSING: $1"
        return 1
    fi
}

check_dir() {
    total_checks=$((total_checks + 1))
    if [ -d "$1" ]; then
        echo -e "${GREEN}✓${NC} $2"
        passed_checks=$((passed_checks + 1))
        return 0
    else
        echo -e "${RED}✗${NC} $2 - MISSING: $1"
        return 1
    fi
}

# Change to script directory
cd "$(dirname "$0")"

echo "📁 PROJECT STRUCTURE"
echo "─────────────────────"
check_dir "autoload" "Autoload directory"
check_dir "scripts" "Scripts directory"
check_dir "scripts/ui" "UI scripts directory"
check_dir "scenes" "Scenes directory"
check_dir "scenes/ui" "UI scenes directory"
check_dir "assets" "Assets directory"
check_dir "assets/sounds" "Sounds directory"
check_dir "assets/fonts" "Fonts directory"
echo ""

echo "⚙️  CONFIGURATION FILES"
echo "─────────────────────"
check_file "project.godot" "Project configuration"
check_file "icon.svg" "Project icon"
check_file "README.md" "README documentation"
check_file "SETUP.md" "Setup guide"
echo ""

echo "🔧 AUTOLOAD SCRIPTS"
echo "─────────────────────"
check_file "autoload/screen_wrapper.gd" "Screen wrapper singleton"
check_file "autoload/audio_manager.gd" "Audio manager singleton"
check_file "autoload/score_manager.gd" "Score manager singleton"
echo ""

echo "📜 GAME SCRIPTS"
echo "─────────────────────"
check_file "scripts/vector_sprite.gd" "Vector sprite base class"
check_file "scripts/ship.gd" "Ship controller"
check_file "scripts/rock.gd" "Rock/asteroid class"
check_file "scripts/bullet.gd" "Bullet projectile"
check_file "scripts/debris.gd" "Explosion debris"
check_file "scripts/saucer.gd" "Enemy saucer"
check_file "scripts/game_manager.gd" "Main game manager"
echo ""

echo "📜 UI SCRIPTS"
echo "─────────────────────"
check_file "scripts/ui/hud.gd" "HUD controller"
check_file "scripts/ui/menu.gd" "Menu controller"
check_file "scripts/ui/game_over.gd" "Game over controller"
check_file "scripts/ui/highscore_entry.gd" "High score entry"
echo ""

echo "🎬 GAME SCENES"
echo "─────────────────────"
check_file "scenes/main.tscn" "Main game scene"
check_file "scenes/ship.tscn" "Ship scene"
check_file "scenes/rock.tscn" "Rock scene"
check_file "scenes/bullet.tscn" "Bullet scene"
check_file "scenes/debris.tscn" "Debris scene"
check_file "scenes/saucer.tscn" "Saucer scene"
echo ""

echo "🎬 UI SCENES"
echo "─────────────────────"
check_file "scenes/ui/hud.tscn" "HUD scene"
check_file "scenes/ui/menu.tscn" "Menu scene"
check_file "scenes/ui/game_over.tscn" "Game over scene"
check_file "scenes/ui/highscore_entry.tscn" "High score entry scene"
echo ""

echo "🔊 AUDIO ASSETS"
echo "─────────────────────"
check_file "assets/sounds/fire.wav" "Fire sound"
check_file "assets/sounds/thrust.wav" "Thrust sound"
check_file "assets/sounds/explode1.wav" "Explosion 1"
check_file "assets/sounds/explode2.wav" "Explosion 2"
check_file "assets/sounds/explode3.wav" "Explosion 3"
check_file "assets/sounds/sfire.wav" "Saucer fire"
check_file "assets/sounds/lsaucer.wav" "Large saucer"
check_file "assets/sounds/ssaucer.wav" "Small saucer"
check_file "assets/sounds/life.wav" "Extra life"
echo ""

echo "🔤 FONT ASSETS"
echo "─────────────────────"
check_file "assets/fonts/Hyperspace.otf" "Hyperspace font"
echo ""

echo "═══════════════════════════════════════════════════"
echo "  VERIFICATION COMPLETE"
echo "═══════════════════════════════════════════════════"
echo ""
echo "Results: ${passed_checks}/${total_checks} checks passed"
echo ""

if [ $passed_checks -eq $total_checks ]; then
    echo -e "${GREEN}✓ ALL CHECKS PASSED!${NC}"
    echo ""
    echo "🚀 Ready to launch!"
    echo ""
    echo "Next steps:"
    echo "  1. Open Godot Engine 4.2+"
    echo "  2. Click 'Import' and select project.godot"
    echo "  3. Press F5 to run the game"
    echo "  4. Enjoy your Asteroids game!"
    echo ""
    exit 0
else
    missing=$((total_checks - passed_checks))
    echo -e "${RED}✗ ${missing} CHECKS FAILED${NC}"
    echo ""
    echo "Some files are missing. Please check the output above."
    echo ""
    exit 1
fi
