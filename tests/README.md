# Asteroids Game - Testing Suite

This directory contains unit and integration tests for the Asteroids game.

## Test Structure

```
tests/
├── run_tests.py              # Main test runner
├── test_vector2d.py          # Vector2d class tests
├── test_geometry.py          # Geometry and collision math tests
├── test_vectorsprites.py     # VectorSprite transformation tests
└── test_game_mechanics.py    # Integration tests for gameplay
```

## Running Tests

### Run All Tests
```bash
cd tests
python3 run_tests.py
```

### Run Specific Test Module
```bash
python3 test_vector2d.py
python3 test_geometry.py
python3 test_vectorsprites.py
python3 test_game_mechanics.py
```

### Run Specific Test Class
```bash
python3 -m unittest test_vector2d.TestVector2d
```

### Run Specific Test Method
```bash
python3 -m unittest test_vector2d.TestVector2d.test_initialization
```

## Test Coverage

### Unit Tests

**test_vector2d.py**
- Vector initialization
- Zero vectors
- Negative and float values
- Vector independence
- Magnitude calculations
- Distance calculations

**test_geometry.py**
- Gradient calculations (horizontal, vertical, diagonal lines)
- Y-axis intersection
- Line intersection scenarios
- Parallel lines
- Perpendicular lines
- Coincident lines
- Real-world collision scenarios

**test_vectorsprites.py**
- Sprite initialization
- Movement and velocity
- Rotation transformations
- Point translation and scaling
- Collision detection
- Bounding box collisions

### Integration Tests

**test_game_mechanics.py**
- Ship physics (thrust, rotation, deceleration)
- Max velocity enforcement
- Bullet firing and limits
- Hyperspace mechanics
- Rock creation (3 sizes, 4 shapes)
- Rock velocity by size
- Rock rotation
- Saucer behavior (2 types)
- Saucer AI and shooting
- Screen wrapping (toroidal topology)
- Collision detection (ship-rock, bullet-rock)
- Score calculation

## Test Requirements

The tests require:
- Python 3.x
- pygame library

Install pygame if needed:
```bash
pip3 install pygame
```

## Writing New Tests

When adding new features, follow these patterns:

### Unit Test Template
```python
import unittest
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'src'))

from module_name import ClassName

class TestFeature(unittest.TestCase):
    def setUp(self):
        """Set up test fixtures"""
        pass
    
    def test_behavior(self):
        """Test specific behavior"""
        # Arrange
        # Act
        # Assert
        pass

if __name__ == '__main__':
    unittest.main()
```

### Integration Test Template
```python
class TestGameFeature(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        """Initialize pygame and stage once"""
        pygame.init()
        cls.stage = Stage('Test', (800, 600))
    
    def setUp(self):
        """Create game objects"""
        pass
    
    def tearDown(self):
        """Clean up sprites"""
        self.stage.spriteList.clear()
    
    def test_interaction(self):
        """Test object interactions"""
        pass
```

## Test Best Practices

1. **Isolation**: Each test should be independent
2. **Clarity**: Use descriptive test names
3. **Coverage**: Test both success and failure cases
4. **Speed**: Keep tests fast (mock heavy operations if needed)
5. **Assertions**: Use appropriate assertion methods

## Continuous Integration

These tests can be integrated into CI/CD pipelines:

```yaml
# Example GitHub Actions workflow
name: Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Set up Python
        uses: actions/setup-python@v2
        with:
          python-version: '3.9'
      - name: Install dependencies
        run: pip install pygame
      - name: Run tests
        run: python tests/run_tests.py
```

## Known Issues

- Some tests require pygame display initialization
- Collision tests depend on bounding rect calculations
- Sound tests are excluded (would require audio output)

## Future Test Additions

Consider adding tests for:
- [ ] Game state transitions
- [ ] High score management
- [ ] Lives system
- [ ] Level progression
- [ ] Sound manager
- [ ] Input handling
- [ ] Frame rate stability
- [ ] Memory leaks (sprite cleanup)

## For Godot Port

When porting to Godot, consider using:
- **GUT (Godot Unit Test)** framework
- **WAT (WAT Tester)** for scene testing
- Built-in Godot test runner

The test structure and coverage here should guide Godot test creation.
