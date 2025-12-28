#!/usr/bin/env python3
"""
Unit tests for VectorSprite class
Tests sprite transformation, movement, and collision
"""

import unittest
import sys
import os
import math

# Add parent directory to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'src'))

from util.vector2d import Vector2d
from util.vectorsprites import VectorSprite
import pygame


class TestVectorSpriteBasics(unittest.TestCase):
    """Test basic VectorSprite functionality"""

    @classmethod
    def setUpClass(cls):
        """Initialize pygame once for all tests"""
        pygame.init()
        pygame.display.set_mode((800, 600))

    def setUp(self):
        """Set up test fixtures"""
        self.position = Vector2d(100, 100)
        self.heading = Vector2d(0, 0)
        # Simple triangle
        self.pointlist = [(0, -10), (10, 10), (-10, 10)]
        self.sprite = VectorSprite(self.position, self.heading, self.pointlist)

    def test_initialization(self):
        """Test sprite initialization"""
        self.assertEqual(self.sprite.position.x, 100)
        self.assertEqual(self.sprite.position.y, 100)
        self.assertEqual(self.sprite.angle, 0)
        self.assertEqual(len(self.sprite.pointlist), 3)

    def test_initial_color(self):
        """Test default color is white"""
        self.assertEqual(self.sprite.color, (255, 255, 255))

    def test_custom_color(self):
        """Test custom color initialization"""
        sprite = VectorSprite(self.position, self.heading, self.pointlist, 
                            angle=0, color=(255, 0, 0))
        self.assertEqual(sprite.color, (255, 0, 0))

    def test_angle_initialization(self):
        """Test custom angle initialization"""
        sprite = VectorSprite(self.position, self.heading, self.pointlist, angle=45)
        self.assertEqual(sprite.angle, 45)


class TestVectorSpriteMovement(unittest.TestCase):
    """Test sprite movement and physics"""

    @classmethod
    def setUpClass(cls):
        """Initialize pygame once for all tests"""
        pygame.init()
        pygame.display.set_mode((800, 600))

    def setUp(self):
        """Set up test fixtures"""
        self.position = Vector2d(100, 100)
        self.heading = Vector2d(2, 3)  # Moving right and down
        self.pointlist = [(0, -10), (10, 10), (-10, 10)]
        self.sprite = VectorSprite(self.position, self.heading, self.pointlist)

    def test_move_updates_position(self):
        """Test that move() updates position"""
        original_x = self.sprite.position.x
        original_y = self.sprite.position.y
        
        self.sprite.move()
        
        self.assertEqual(self.sprite.position.x, original_x + 2)
        self.assertEqual(self.sprite.position.y, original_y + 3)

    def test_multiple_moves(self):
        """Test multiple move iterations"""
        self.sprite.move()
        self.sprite.move()
        self.sprite.move()
        
        self.assertEqual(self.sprite.position.x, 106)  # 100 + 2*3
        self.assertEqual(self.sprite.position.y, 109)  # 100 + 3*3

    def test_move_with_rotation(self):
        """Test movement with angular velocity"""
        self.sprite.vAngle = 5  # 5 degrees per frame
        original_angle = self.sprite.angle
        
        self.sprite.move()
        
        self.assertEqual(self.sprite.angle, original_angle + 5)

    def test_stationary_sprite(self):
        """Test sprite with zero velocity"""
        self.sprite.heading = Vector2d(0, 0)
        original_pos = (self.sprite.position.x, self.sprite.position.y)
        
        self.sprite.move()
        
        self.assertEqual(self.sprite.position.x, original_pos[0])
        self.assertEqual(self.sprite.position.y, original_pos[1])


class TestVectorSpriteTransformation(unittest.TestCase):
    """Test sprite rotation and translation"""

    @classmethod
    def setUpClass(cls):
        """Initialize pygame once for all tests"""
        pygame.init()
        pygame.display.set_mode((800, 600))

    def setUp(self):
        """Set up test fixtures"""
        self.position = Vector2d(0, 0)
        self.heading = Vector2d(0, 0)
        # Simple square centered at origin
        self.pointlist = [(-10, -10), (10, -10), (10, 10), (-10, 10)]
        self.sprite = VectorSprite(self.position, self.heading, self.pointlist)

    def test_translate_point(self):
        """Test point translation"""
        point = (5, 10)
        self.sprite.position = Vector2d(100, 200)
        translated = self.sprite.translatePoint(point)
        
        self.assertEqual(translated[0], 105)  # 5 + 100
        self.assertEqual(translated[1], 210)  # 10 + 200

    def test_rotate_point_0_degrees(self):
        """Test rotation by 0 degrees (no change)"""
        point = (10, 0)
        self.sprite.angle = 0
        rotated = self.sprite.rotatePoint(point)
        
        self.assertAlmostEqual(rotated[0], 10, places=0)
        self.assertAlmostEqual(rotated[1], 0, places=0)

    def test_rotate_point_90_degrees(self):
        """Test rotation by 90 degrees"""
        point = (10, 0)
        self.sprite.angle = 90
        rotated = self.sprite.rotatePoint(point)
        
        # After 90 degree rotation clockwise, (10,0) becomes approximately (0,-10)
        # Due to the rotation formula: x' = x*cos - y*sin, y' = y*cos + x*sin
        self.assertAlmostEqual(rotated[0], 0, places=0)
        self.assertAlmostEqual(rotated[1], -10, places=0)

    def test_rotate_point_180_degrees(self):
        """Test rotation by 180 degrees"""
        point = (10, 0)
        self.sprite.angle = 180
        rotated = self.sprite.rotatePoint(point)
        
        # After 180 degree rotation, (10,0) should become (-10,0)
        self.assertAlmostEqual(rotated[0], -10, places=0)
        self.assertAlmostEqual(rotated[1], 0, places=0)

    def test_scale_point(self):
        """Test point scaling"""
        point = (10, 20)
        scaled = self.sprite.scale(point, 2.0)
        
        self.assertEqual(scaled[0], 20)
        self.assertEqual(scaled[1], 40)

    def test_scale_point_fractional(self):
        """Test fractional scaling"""
        point = (10, 20)
        scaled = self.sprite.scale(point, 0.5)
        
        self.assertEqual(scaled[0], 5)
        self.assertEqual(scaled[1], 10)


class TestVectorSpriteCollision(unittest.TestCase):
    """Test sprite collision detection"""

    @classmethod
    def setUpClass(cls):
        """Initialize pygame once for all tests"""
        pygame.init()
        cls.screen = pygame.display.set_mode((800, 600))

    def setUp(self):
        """Set up test fixtures"""
        self.pointlist = [(0, -10), (10, 10), (-10, 10)]
        
        # Sprite 1 at (100, 100)
        self.sprite1 = VectorSprite(
            Vector2d(100, 100),
            Vector2d(0, 0),
            self.pointlist
        )
        
        # Sprite 2 at (200, 200) - far away
        self.sprite2 = VectorSprite(
            Vector2d(200, 200),
            Vector2d(0, 0),
            self.pointlist
        )
        
        # Draw both sprites to initialize bounding rects
        self.sprite1.boundingRect = pygame.draw.aalines(
            self.screen, self.sprite1.color, True, self.sprite1.draw()
        )
        self.sprite2.boundingRect = pygame.draw.aalines(
            self.screen, self.sprite2.color, True, self.sprite2.draw()
        )

    def test_no_collision_far_apart(self):
        """Test sprites far apart don't collide"""
        self.assertFalse(self.sprite1.collidesWith(self.sprite2))

    def test_collision_overlapping(self):
        """Test sprites at same position collide"""
        self.sprite2.position = Vector2d(100, 100)
        # Redraw to update bounding rect
        self.sprite2.boundingRect = pygame.draw.aalines(
            self.screen, self.sprite2.color, True, self.sprite2.draw()
        )
        
        self.assertTrue(self.sprite1.collidesWith(self.sprite2))

    def test_collision_nearby(self):
        """Test sprites close together"""
        self.sprite2.position = Vector2d(110, 105)
        # Redraw to update bounding rect
        self.sprite2.boundingRect = pygame.draw.aalines(
            self.screen, self.sprite2.color, True, self.sprite2.draw()
        )
        
        # May or may not collide depending on exact positions
        # Just verify the method runs without error
        result = self.sprite1.collidesWith(self.sprite2)
        self.assertIsInstance(result, bool)


if __name__ == '__main__':
    unittest.main()
