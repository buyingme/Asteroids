#!/usr/bin/env python3
"""
Unit tests for Vector2d class
Tests basic vector operations and functionality
"""

import unittest
import sys
import os

# Add parent directory to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'src'))

from util.vector2d import Vector2d


class TestVector2d(unittest.TestCase):
    """Test cases for the Vector2d class"""

    def setUp(self):
        """Set up test fixtures"""
        self.v1 = Vector2d(3, 4)
        self.v2 = Vector2d(1, 2)
        self.zero = Vector2d(0, 0)

    def test_initialization(self):
        """Test vector initialization"""
        self.assertEqual(self.v1.x, 3)
        self.assertEqual(self.v1.y, 4)
        
    def test_zero_vector(self):
        """Test zero vector creation"""
        self.assertEqual(self.zero.x, 0)
        self.assertEqual(self.zero.y, 0)

    def test_negative_values(self):
        """Test negative coordinate values"""
        v = Vector2d(-5, -10)
        self.assertEqual(v.x, -5)
        self.assertEqual(v.y, -10)

    def test_float_values(self):
        """Test float coordinate values"""
        v = Vector2d(3.5, 4.7)
        self.assertAlmostEqual(v.x, 3.5)
        self.assertAlmostEqual(v.y, 4.7)

    def test_vector_copy(self):
        """Test that vectors are independent instances"""
        v1 = Vector2d(10, 20)
        v2 = Vector2d(v1.x, v1.y)
        v2.x = 30
        self.assertEqual(v1.x, 10)  # v1 should be unchanged
        self.assertEqual(v2.x, 30)


class TestVector2dOperations(unittest.TestCase):
    """Test vector operations that should be implemented"""

    def setUp(self):
        """Set up test fixtures"""
        self.v1 = Vector2d(3, 4)
        self.v2 = Vector2d(1, 2)

    def test_magnitude(self):
        """Test vector magnitude calculation (to be implemented)"""
        # For vector (3, 4), magnitude should be 5
        import math
        magnitude = math.hypot(self.v1.x, self.v1.y)
        self.assertAlmostEqual(magnitude, 5.0)

    def test_distance(self):
        """Test distance between two vectors"""
        import math
        distance = math.hypot(self.v1.x - self.v2.x, self.v1.y - self.v2.y)
        self.assertAlmostEqual(distance, math.sqrt(8))  # sqrt((3-1)^2 + (4-2)^2)


if __name__ == '__main__':
    unittest.main()
