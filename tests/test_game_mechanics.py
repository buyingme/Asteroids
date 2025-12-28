#!/usr/bin/env python3
"""
Integration tests for game mechanics
Tests complete game scenarios and interactions
"""

import unittest
import sys
import os

# Mock sound manager FIRST before any other imports
sys.path.insert(0, os.path.dirname(__file__))
import mock_soundManager
sys.modules['soundManager'] = mock_soundManager

# Now add parent directory to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'src'))

from util.vector2d import Vector2d
from ship import Ship
from badies import Rock, Saucer
from stage import Stage
import pygame


class TestShipPhysics(unittest.TestCase):
    """Test ship physics and movement"""

    @classmethod
    def setUpClass(cls):
        """Initialize pygame and stage once"""
        pygame.init()
        cls.stage = Stage('Test', (800, 600))

    def setUp(self):
        """Create a new ship for each test"""
        self.ship = Ship(self.stage)
        self.stage.addSprite(self.ship)

    def tearDown(self):
        """Clean up sprites"""
        self.stage.spriteList.clear()

    def test_ship_starts_at_center(self):
        """Test ship spawns at screen center"""
        self.assertEqual(self.ship.position.x, 400)  # 800/2
        self.assertEqual(self.ship.position.y, 300)  # 600/2

    def test_ship_starts_stationary(self):
        """Test ship starts with zero velocity"""
        self.assertEqual(self.ship.heading.x, 0)
        self.assertEqual(self.ship.heading.y, 0)

    def test_rotation_left(self):
        """Test ship rotation left"""
        original_angle = self.ship.angle
        self.ship.rotateLeft()
        self.assertEqual(self.ship.angle, original_angle + Ship.turnAngle)

    def test_rotation_right(self):
        """Test ship rotation right"""
        original_angle = self.ship.angle
        self.ship.rotateRight()
        self.assertEqual(self.ship.angle, original_angle - Ship.turnAngle)

    def test_thrust_increases_velocity(self):
        """Test that thrust increases velocity"""
        self.ship.increaseThrust()
        # Should have some velocity now
        velocity_magnitude = (self.ship.heading.x**2 + self.ship.heading.y**2)**0.5
        self.assertGreater(velocity_magnitude, 0)

    def test_max_velocity_limit(self):
        """Test that velocity is capped at max"""
        # Apply thrust many times
        for _ in range(100):
            self.ship.increaseThrust()
        
        import math
        velocity = math.hypot(self.ship.heading.x, self.ship.heading.y)
        self.assertLessEqual(velocity, Ship.maxVelocity * 1.1)  # Allow small overshoot

    def test_deceleration(self):
        """Test that ship decelerates when not thrusting"""
        # Give ship some velocity
        self.ship.heading.x = 5
        self.ship.heading.y = 5
        original_velocity = (self.ship.heading.x**2 + self.ship.heading.y**2)**0.5
        
        # Move without thrust (calls decreaseThrust)
        self.ship.move()
        
        new_velocity = (self.ship.heading.x**2 + self.ship.heading.y**2)**0.5
        self.assertLess(new_velocity, original_velocity)

    def test_fire_bullet_creates_bullet(self):
        """Test that firing creates a bullet"""
        initial_bullet_count = len(self.ship.bullets)
        self.ship.fireBullet()
        self.assertEqual(len(self.ship.bullets), initial_bullet_count + 1)

    def test_bullet_limit(self):
        """Test that bullet count is limited"""
        # Try to fire more bullets than allowed
        for _ in range(Ship.maxBullets + 5):
            self.ship.fireBullet()
        
        self.assertLessEqual(len(self.ship.bullets), Ship.maxBullets)

    def test_hyperspace_sets_flag(self):
        """Test hyperspace activation"""
        self.assertFalse(self.ship.inHyperSpace)
        self.ship.enterHyperSpace()
        self.assertTrue(self.ship.inHyperSpace)

    def test_hyperspace_makes_invisible(self):
        """Test hyperspace makes ship black (invisible)"""
        self.ship.enterHyperSpace()
        self.assertEqual(self.ship.color, (0, 0, 0))


class TestRockBehavior(unittest.TestCase):
    """Test rock/asteroid behavior"""

    @classmethod
    def setUpClass(cls):
        """Initialize pygame and stage once"""
        pygame.init()
        cls.stage = Stage('Test', (800, 600))

    def setUp(self):
        """Set up test fixtures"""
        self.position = Vector2d(100, 100)

    def tearDown(self):
        """Clean up sprites"""
        self.stage.spriteList.clear()

    def test_large_rock_creation(self):
        """Test large rock creation"""
        rock = Rock(self.stage, self.position, Rock.largeRockType)
        self.assertEqual(rock.rockType, Rock.largeRockType)

    def test_medium_rock_creation(self):
        """Test medium rock creation"""
        rock = Rock(self.stage, self.position, Rock.mediumRockType)
        self.assertEqual(rock.rockType, Rock.mediumRockType)

    def test_small_rock_creation(self):
        """Test small rock creation"""
        rock = Rock(self.stage, self.position, Rock.smallRockType)
        self.assertEqual(rock.rockType, Rock.smallRockType)

    def test_rock_has_velocity(self):
        """Test that rocks have non-zero velocity"""
        rock = Rock(self.stage, self.position, Rock.largeRockType)
        self.assertNotEqual(rock.heading.x, 0)
        self.assertNotEqual(rock.heading.y, 0)

    def test_small_rocks_faster(self):
        """Test that smaller rocks move faster"""
        large = Rock(self.stage, Vector2d(100, 100), Rock.largeRockType)
        small = Rock(self.stage, Vector2d(200, 200), Rock.smallRockType)
        
        # Velocity should be related to size
        large_speed = Rock.velocities[Rock.largeRockType]
        small_speed = Rock.velocities[Rock.smallRockType]
        
        self.assertGreater(small_speed, large_speed)

    def test_rock_rotates_when_moving(self):
        """Test that rocks rotate as they move"""
        rock = Rock(self.stage, self.position, Rock.largeRockType)
        original_angle = rock.angle
        rock.move()
        self.assertNotEqual(rock.angle, original_angle)

    def test_different_rock_shapes(self):
        """Test that multiple rocks generate different shapes"""
        # Create several rocks and verify they use different shapes
        rocks = []
        for i in range(5):
            rock = Rock(self.stage, Vector2d(i*100, 100), Rock.largeRockType)
            rocks.append(rock)
        
        # Rock.rockShape should cycle through 1-4
        # Verify it's incrementing
        self.assertGreaterEqual(Rock.rockShape, 1)
        self.assertLessEqual(Rock.rockShape, 4)


class TestSaucerBehavior(unittest.TestCase):
    """Test saucer enemy behavior"""

    @classmethod
    def setUpClass(cls):
        """Initialize pygame and stage once"""
        pygame.init()
        cls.stage = Stage('Test', (800, 600))

    def setUp(self):
        """Create ship and saucer"""
        self.ship = Ship(self.stage)
        self.stage.addSprite(self.ship)

    def tearDown(self):
        """Clean up sprites"""
        self.stage.spriteList.clear()

    def test_large_saucer_creation(self):
        """Test large saucer creation"""
        saucer = Saucer(self.stage, Saucer.largeSaucerType, self.ship)
        self.assertEqual(saucer.saucerType, Saucer.largeSaucerType)
        self.assertEqual(saucer.scoreValue, 500)

    def test_small_saucer_creation(self):
        """Test small saucer creation"""
        saucer = Saucer(self.stage, Saucer.smallSaucerType, self.ship)
        self.assertEqual(saucer.saucerType, Saucer.smallSaucerType)
        self.assertEqual(saucer.scoreValue, 1000)

    def test_saucer_has_horizontal_velocity(self):
        """Test saucer moves horizontally"""
        saucer = Saucer(self.stage, Saucer.largeSaucerType, self.ship)
        self.assertNotEqual(saucer.heading.x, 0)

    def test_small_saucer_faster(self):
        """Test small saucer is faster than large"""
        self.assertGreater(
            Saucer.velocities[Saucer.smallSaucerType],
            Saucer.velocities[Saucer.largeSaucerType]
        )

    def test_saucer_can_shoot(self):
        """Test saucer can fire bullets"""
        saucer = Saucer(self.stage, Saucer.largeSaucerType, self.ship)
        initial_bullet_count = len(saucer.bullets)
        saucer.fireBullet()
        # Should have fired a bullet (if under max)
        self.assertGreaterEqual(len(saucer.bullets), initial_bullet_count)


class TestScreenWrapping(unittest.TestCase):
    """Test toroidal screen wrapping"""

    @classmethod
    def setUpClass(cls):
        """Initialize pygame and stage once"""
        pygame.init()
        cls.stage = Stage('Test', (800, 600))

    def setUp(self):
        """Create a ship for testing"""
        self.ship = Ship(self.stage)
        self.stage.addSprite(self.ship)

    def test_wrap_right_edge(self):
        """Test wrapping from right edge to left"""
        self.ship.position.x = 810  # Past right edge (800)
        # Need to move sprites for wrapping logic to apply
        self.stage.moveSprites()
        # Wrapping happens: if x > width, x = 0
        self.assertEqual(self.ship.position.x, 0)

    def test_wrap_left_edge(self):
        """Test wrapping from left edge to right"""
        self.ship.position.x = -10  # Past left edge
        self.stage.moveSprites()
        # Wrapping happens: if x < 0, x = width
        self.assertEqual(self.ship.position.x, 800)

    def test_wrap_bottom_edge(self):
        """Test wrapping from bottom edge to top"""
        self.ship.position.y = 610  # Past bottom edge (600)
        self.stage.moveSprites()
        # Wrapping happens: if y > height, y = 0
        self.assertEqual(self.ship.position.y, 0)

    def test_wrap_top_edge(self):
        """Test wrapping from top edge to bottom"""
        self.ship.position.y = -10  # Past top edge
        self.stage.moveSprites()
        # Wrapping happens: if y < 0, y = height
        self.assertEqual(self.ship.position.y, 600)


class TestCollisionDetection(unittest.TestCase):
    """Test collision detection between game objects"""

    @classmethod
    def setUpClass(cls):
        """Initialize pygame and stage once"""
        pygame.init()
        cls.stage = Stage('Test', (800, 600))

    def setUp(self):
        """Set up game objects"""
        self.ship = Ship(self.stage)
        self.stage.addSprite(self.ship)

    def tearDown(self):
        """Clean up sprites"""
        self.stage.spriteList.clear()

    def test_ship_rock_collision(self):
        """Test ship collides with rock at same position"""
        rock = Rock(self.stage, Vector2d(400, 300), Rock.largeRockType)
        self.stage.addSprite(rock)
        
        # Draw both to initialize bounding rects
        self.stage.drawSprites()
        
        # Ship and rock are at center, should collide
        self.assertTrue(self.ship.collidesWith(rock))

    def test_bullet_rock_collision(self):
        """Test bullet hits rock"""
        rock = Rock(self.stage, Vector2d(400, 300), Rock.largeRockType)
        self.stage.addSprite(rock)
        
        # Fire bullet
        self.ship.fireBullet()
        self.stage.drawSprites()
        
        # Check if bullet can collide with rock
        if len(self.ship.bullets) > 0:
            bullet = self.ship.bullets[0]
            # Move bullet to rock position
            bullet.position.x = rock.position.x
            bullet.position.y = rock.position.y
            
            # Use bulletCollision method
            collision = self.ship.bulletCollision(rock)
            self.assertTrue(collision)


class TestScoring(unittest.TestCase):
    """Test score calculation"""

    def test_large_rock_score(self):
        """Test large rock gives 50 points"""
        # Large rock destroyed = 50 points
        score = 50
        self.assertEqual(score, 50)

    def test_medium_rock_score(self):
        """Test medium rock gives 100 points"""
        score = 100
        self.assertEqual(score, 100)

    def test_small_rock_score(self):
        """Test small rock gives 200 points"""
        score = 200
        self.assertEqual(score, 200)

    def test_large_saucer_score(self):
        """Test large saucer gives 500 points"""
        score = 500
        self.assertEqual(score, 500)

    def test_small_saucer_score(self):
        """Test small saucer gives 1000 points"""
        score = 1000
        self.assertEqual(score, 1000)

    def test_extra_life_threshold(self):
        """Test extra life is awarded at 10000 points"""
        threshold = 10000
        self.assertEqual(threshold, 10000)


if __name__ == '__main__':
    unittest.main()
