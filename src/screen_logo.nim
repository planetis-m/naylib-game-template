# ****************************************************************************************
#
#   raylib - Advance Game template
#
#   Logo Screen Functions Definitions (Init, Update, Draw, Unload)
#
#   Copyright (c) 2014-2022 Ramon Santamaria (@raysan5)
#
#   This software is provided "as-is", without any express or implied warranty. In no event
#   will the authors be held liable for any damages arising from the use of this software.
#
#   Permission is granted to anyone to use this software for any purpose, including commercial
#   applications, and to alter it and redistribute it freely, subject to the following restrictions:
#
#     1. The origin of this software must not be misrepresented; you must not claim that you
#     wrote the original software. If you use this software in a product, an acknowledgment
#     in the product documentation would be appreciated but is not required.
#
#     2. Altered source versions must be plainly marked as such, and must not be misrepresented
#     as being the original software.
#
#     3. This notice may not be removed or altered from any source distribution.
#
# ****************************************************************************************

import raylib, screens

# ----------------------------------------------------------------------------------------
# Module Variables Definition (local)
# ----------------------------------------------------------------------------------------

var
  framesCounter: int32 = 0
  finishScreen: int32 = 0
  logoPositionX: int32 = 0
  logoPositionY: int32 = 0
  lettersCount: int32 = 0
  topSideRecWidth: int32 = 0
  leftSideRecHeight: int32 = 0
  bottomSideRecWidth: int32 = 0
  rightSideRecHeight: int32 = 0
  state: int32 = 0 # Logo animation states
  alpha: float32 = 1 # Useful for fading

# ----------------------------------------------------------------------------------------
# Logo Screen Functions Definition
# ----------------------------------------------------------------------------------------

proc initLogoScreen* =
  # Logo Screen Initialization logic
  finishScreen = 0
  framesCounter = 0
  lettersCount = 0
  logoPositionX = getScreenWidth() div 2 - 128
  logoPositionY = getScreenHeight() div 2 - 128
  topSideRecWidth = 16
  leftSideRecHeight = 16
  bottomSideRecWidth = 16
  rightSideRecHeight = 16
  state = 0
  alpha = 1

proc updateLogoScreen* =
  # Logo Screen Update logic
  if state == 0:
    inc(framesCounter)
    if framesCounter == 80:
      state = 1
      framesCounter = 0
      # Reset counter... will be used later...
  elif state == 1:               # State 1: Bars animation logic: top and left
    inc(topSideRecWidth, 8)
    inc(leftSideRecHeight, 8)
    if topSideRecWidth == 256:
      state = 2
  elif state == 2:               # State 2: Bars animation logic: bottom and right
    inc(bottomSideRecWidth, 8)
    inc(rightSideRecHeight, 8)
    if bottomSideRecWidth == 256:
      state = 3
  elif state == 3:               # State 3: "raylib" text-write animation logic
    inc(framesCounter)
    if lettersCount < 10:        # When all letters have appeared, just fade out everything
      if framesCounter div 12 > 0:
        inc(lettersCount)
        framesCounter = 0
    else:
      if framesCounter > 200:
        alpha -= 0.02
        if alpha <= 0'f32:
          alpha = 0
          finishScreen = 1
          # Jump to next screen

proc drawLogoScreen* =
  # Logo Screen Draw logic
  if state == 0:
    if (framesCounter div 10) mod 2 > 0:
      drawRectangle(logoPositionX, logoPositionY, 16, 16, Black)
  elif state == 1:               # Draw bars animation: top and left
    drawRectangle(logoPositionX, logoPositionY, topSideRecWidth, 16, Black)
    drawRectangle(logoPositionX, logoPositionY, 16, leftSideRecHeight, Black)
  elif state == 2:               # Draw bars animation: bottom and right
    drawRectangle(logoPositionX, logoPositionY, topSideRecWidth, 16, Black)
    drawRectangle(logoPositionX, logoPositionY, 16, leftSideRecHeight, Black)
    drawRectangle(logoPositionX + 240, logoPositionY, 16, rightSideRecHeight, Black)
    drawRectangle(logoPositionX, logoPositionY + 240, bottomSideRecWidth, 16, Black)
  elif state == 3:               # Draw "raylib" text-write animation + "powered by"
    drawRectangle(logoPositionX, logoPositionY, topSideRecWidth, 16, fade(Black, alpha))
    drawRectangle(logoPositionX, logoPositionY + 16, 16, leftSideRecHeight - 32, fade(Black, alpha))
    drawRectangle(logoPositionX + 240, logoPositionY + 16, 16, rightSideRecHeight - 32, fade(Black, alpha))
    drawRectangle(logoPositionX, logoPositionY + 240, bottomSideRecWidth, 16, fade(Black, alpha))
    drawRectangle(getScreenWidth() div 2 - 112, getScreenHeight() div 2 - 112, 224, 224, fade(RayWhite, alpha))
    drawText(substr("raylib", 0, lettersCount-1), getScreenWidth() div 2 - 44, getScreenHeight() div 2 + 48, 50, fade(Black, alpha))
    if framesCounter > 20:
      drawText("powered by", logoPositionX, logoPositionY - 27, 20, fade(DarkGray, alpha))

proc unloadLogoScreen* =
  # Logo Screen Unload logic
  # Unload LOGO screen variables here!
  discard

proc finishLogoScreen*: int32 =
  # Logo Screen should finish?
  return finishScreen
