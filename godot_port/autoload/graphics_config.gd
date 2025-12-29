extends Node
## Global graphics configuration
## Controls line widths and point sizes for all vector graphics

# Line width for all vector sprites (ships, rocks, saucers)
# Python original uses pygame.draw.aalines() which is 1 pixel
# Godot default was 2.0, recommend 1.0 to match original
const LINE_WIDTH: float = 0.7

# Line width for debris/explosions
# Can be thicker for visual emphasis
const DEBRIS_LINE_WIDTH: float = 0.7

# Point size for bullets
# Python draws bullets as small rectangles
const BULLET_POINT_SIZE: float = 0.7
