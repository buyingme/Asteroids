#!/usr/bin/env python3
"""
Mock sound manager for testing
Provides no-op implementations of sound functions
"""

# Mock sounds dictionary
sounds = {}


def initSoundManager():
    """Initialize sound manager (no-op for tests)"""
    pass


def playSound(soundName):
    """Play a sound (no-op for tests)"""
    pass


def playSoundContinuous(soundName):
    """Play a looping sound (no-op for tests)"""
    pass


def stopSound(soundName):
    """Stop a sound (no-op for tests)"""
    pass
