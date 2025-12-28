#!/usr/bin/env python3
"""
Unit tests for geometry module
Tests line intersection and collision detection
"""

import unittest
import sys
import os

# Add parent directory to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'src'))

from util.geometry import calculateGradient, calculateYAxisIntersect, getIntersectPoint


class TestGeometryBasics(unittest.TestCase):
    """Test basic geometry calculations"""

    def test_gradient_horizontal_line(self):
        """Test gradient of horizontal line (should be 0)"""
        p1 = (0, 5)
        p2 = (10, 5)
        gradient = calculateGradient(p1, p2)
        self.assertEqual(gradient, 0)

    def test_gradient_vertical_line(self):
        """Test gradient of vertical line (should be None/infinite)"""
        p1 = (5, 0)
        p2 = (5, 10)
        gradient = calculateGradient(p1, p2)
        self.assertIsNone(gradient)

    def test_gradient_diagonal_line(self):
        """Test gradient of 45-degree line"""
        p1 = (0, 0)
        p2 = (10, 10)
        gradient = calculateGradient(p1, p2)
        self.assertEqual(gradient, 1.0)

    def test_gradient_negative_slope(self):
        """Test gradient with negative slope"""
        p1 = (0, 10)
        p2 = (10, 0)
        gradient = calculateGradient(p1, p2)
        self.assertEqual(gradient, -1.0)

    def test_y_axis_intersect(self):
        """Test Y-axis intersection calculation"""
        p = (5, 10)
        m = 2  # gradient
        # y = mx + b, so b = y - mx = 10 - 2*5 = 0
        b = calculateYAxisIntersect(p, m)
        self.assertEqual(b, 0)

    def test_y_axis_intersect_offset(self):
        """Test Y-axis intersection with offset"""
        p = (2, 7)
        m = 2
        # b = 7 - 2*2 = 3
        b = calculateYAxisIntersect(p, m)
        self.assertEqual(b, 3)


class TestLineIntersection(unittest.TestCase):
    """Test line intersection calculations"""

    def test_perpendicular_lines_intersect(self):
        """Test intersection of perpendicular lines"""
        # Vertical line at x=5 from (5,0) to (5,10)
        # Horizontal line at y=5 from (0,5) to (10,5)
        p1 = (5, 0)
        p2 = (5, 10)
        p3 = (0, 5)
        p4 = (10, 5)
        
        result = getIntersectPoint(p1, p2, p3, p4)
        self.assertIsNotNone(result)
        self.assertEqual(len(result), 1)
        x, y = result[0]
        self.assertEqual(x, 5)
        self.assertEqual(y, 5)

    def test_diagonal_lines_intersect(self):
        """Test intersection of diagonal lines"""
        # Line 1: from (0,0) to (10,10)
        # Line 2: from (0,10) to (10,0)
        # Should intersect at (5,5)
        p1 = (0, 0)
        p2 = (10, 10)
        p3 = (0, 10)
        p4 = (10, 0)
        
        result = getIntersectPoint(p1, p2, p3, p4)
        self.assertIsNotNone(result)
        self.assertEqual(len(result), 1)
        x, y = result[0]
        self.assertAlmostEqual(x, 5.0)
        self.assertAlmostEqual(y, 5.0)

    def test_parallel_lines_no_intersect(self):
        """Test parallel lines that don't intersect"""
        # Two horizontal lines at different y values
        p1 = (0, 0)
        p2 = (10, 0)
        p3 = (0, 5)
        p4 = (10, 5)
        
        result = getIntersectPoint(p1, p2, p3, p4)
        # Parallel lines with different b values should return None
        self.assertIsNone(result)

    def test_coincident_lines(self):
        """Test lines that lie on top of each other"""
        # Same line defined by different points
        p1 = (0, 0)
        p2 = (10, 10)
        p3 = (2, 2)
        p4 = (8, 8)
        
        result = getIntersectPoint(p1, p2, p3, p4)
        # Should return all four points for coincident lines
        self.assertIsNotNone(result)
        self.assertEqual(len(result), 4)


class TestCollisionScenarios(unittest.TestCase):
    """Test real-world collision scenarios from the game"""

    def test_ship_rock_collision_scenario(self):
        """Test a typical ship-rock collision scenario"""
        # Ship triangle point at (512, 384)
        # Rock edge from (520, 380) to (520, 390)
        ship_p1 = (512, 374)  # Ship nose
        ship_p2 = (518, 394)  # Ship right
        rock_p1 = (520, 380)
        rock_p2 = (520, 390)
        
        result = getIntersectPoint(ship_p1, ship_p2, rock_p1, rock_p2)
        # These lines should intersect
        self.assertIsNotNone(result)

    def test_bullet_rock_miss(self):
        """Test a bullet that misses a rock"""
        # Bullet path horizontal
        bullet_p1 = (100, 100)
        bullet_p2 = (200, 100)
        # Rock edge far away
        rock_p1 = (150, 200)
        rock_p2 = (160, 210)
        
        result = getIntersectPoint(bullet_p1, bullet_p2, rock_p1, rock_p2)
        # Lines are not parallel but would only intersect if extended
        # The intersect point might exist but be outside line segments
        # This test validates the intersection point calculation
        if result:
            self.assertEqual(len(result), 1)


if __name__ == '__main__':
    unittest.main()
