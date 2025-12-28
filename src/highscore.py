#   Highscore-Class
#   Copyright (C) 2022 Alexander Killi

import pygame
import sys
import os
from stage import *
from asteroids import *


class Highscore():

    def __init__(self):
        self.highscoreTab = [ ['ACE', 10000], ['SND', 5000], ['TRD', 2000] ]
        self.preInitials = 'AAA'
        self.scorePos = 0
        
    def iniAscii(self):
        self.initialsNum = 0
        self.asciiNum = [0,0,0]    
        help = 0
        for item in self.preInitials:
            self.asciiNum[help] = ord(item)
            help += 1
        #print(self.asciiNum)

    def checkScore(self, score):
        hlp = self.highscoreTab
        if score <= self.highscoreTab[2][1]
            self.gameState = 'attract_mode'
        if score > self.highscoreTab[2][1] and score <= self.highscoreTab[1][1]:
            hlp[2][0] = self.preInitials
            hlp[2][1] = score
            self.scorePos = 2
            self.highscoreSet()
            self.highscoreTab = hlp
        if score > self.highscoreTab[1][1] and score <= self.highscoreTab[0][1]:
            hlp[2][0] = self.highscoreTab[1][0]
            hlp[2][1] = self.highscoreTab[1][1]
            hlp[1][0] = self.preInitials
            hlp[1][1] = score
            self.scorePos = 1
            self.highscoreSet()
            self.highscoreTab = hlp
        if score > self.highscoreTab[0][1]:
            hlp[2][0] = self.highscoreTab[1][0]
            hlp[2][1] = self.highscoreTab[1][1]
            hlp[1][0] = self.highscoreTab[0][0]
            hlp[1][1] = self.highscoreTab[0][1]
            hlp[0][0] = self.preInitials
            hlp[0][1] = score
            self.scorePos = 0
            self.highscoreSet()
            self.highscoreTab = hlp
        
    def highscoreSet(self):
        self.gameState = 'highscore_set'
        self.iniAscii()

# Should move the ship controls into the ship class
    def input(self, events):
        self.frameAdvance = False
        for event in events:
            if event.type == QUIT:
                sys.exit(0)
            elif event.type == KEYDOWN:
                if event.key == K_ESCAPE:
                    sys.exit(0)
                if self.gameState == 'highscore_set':
                    if event.key == K_UP and self.asciiNum[self.initialsNum] < 90:
                        self.asciiNum[self.initialsNum] += 1
                    elif event.key == K_DOWN and self.asciiNum[self.initialsNum] > 65:
                        self.asciiNum[self.initialsNum] -= 1
                    elif event.key == K_RIGHT and self.initialsNum < 2:
                        self.initialsNum += 1
                    elif event.key == K_LEFT and self.initialsNum > 0:
                        self.initialsNum -= 1
                    elif event.key == K_RETURN:
                        self.gameState = 'attract_mode'
                    itemStr = ''
                    for i in range(0, 3):
                        itemStr += chr(self.asciiNum[i])
                    self.highscoreTab[self.scorePos][0] = itemStr
                # print(self.asciiNum)        
                if event.key == K_j:
                    if self.showingFPS:  # (is True)
                        self.showingFPS = False
                    else:
                        self.showingFPS = True

                if event.key == K_f:
                    pygame.display.toggle_fullscreen()

                # if event.key == K_k:
                    # self.killShip()
            elif event.type == KEYUP:
                if event.key == K_o:
                    self.frameAdvance = True

    def displayHighscore(self):
        font1 = pygame.font.Font('../res/Hyperspace.otf', 30)
        y_pos = self.stage.height/2
        x_pos = self.stage.width/2
        for item in self.highscoreTab:
            itemStr = item[0] + ':    ' + str('%6d' % item[1])
            itemTxt = font1.render(itemStr, True, (200, 200, 200))
            itemTxtRect = itemTxt.get_rect(centerx=x_pos, centery=y_pos)
            self.stage.screen.blit(itemTxt, itemTxtRect)
            y_pos += 50
        
    def testScore(self):
        self.stage = Stage('Highscore', (1024, 768))
        clock = pygame.time.Clock()
        frameCount = 0.0
        timePassed = 0.0
        self.fps = 0.0
        while True:
            self.input(pygame.event.get())
            self.stage.screen.fill((10, 10, 10))
            self.stage.moveSprites()
            self.stage.drawSprites()
            self.displayHighscore()
            pygame.display.flip()


# Test script below...
if __name__ == "__main__":
    score = 12500
    test = Highscore()  # test class Highscore    
    test.checkScore(score)
    test.testScore()
