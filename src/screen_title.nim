# ****************************************************************************************
#
#   raylib - Advance Game template
#
#   Title Screen Functions Definitions (Init, Update, Draw, Unload)
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

import raylib

# ----------------------------------------------------------------------------------------
# Module Variables Definition (local)
# ----------------------------------------------------------------------------------------

var
  framesCounter: int32 = 0
  finishScreen: int32 = 0

# ----------------------------------------------------------------------------------------
# Title Screen Functions Definition
# ----------------------------------------------------------------------------------------

proc initTitleScreen* =
  # Title Screen Initialization logic
  # TODO: Initialize TITLE screen variables here!
  framesCounter = 0
  finishScreen = 0

proc updateTitleScreen* =
  # Title Screen Update logic
  # TODO: Update TITLE screen variables here!
  # Press enter or tap to change to GAMEPLAY screen
  if isKeyPressed(KeyEnter) or isGestureDetected(GestureTap):
    # finishScreen = 1   # OPTIONS
    finishScreen = 2
    # GAMEPLAY
    playSound(fxCoin)

proc drawTitleScreen* =
  # Title Screen Draw logic
  # TODO: Draw TITLE screen here!
  drawRectangle(0, 0, getScreenWidth(), getScreenHeight(), Green)
  var pos: Vector2 = [20, 10]
  drawTextEx(font, "TITLE SCREEN", pos, font.baseSize * 3.0f, 4, DarkGreen)
  drawText("PRESS ENTER or TAP to JUMP to GAMEPLAY SCREEN", 120, 220, 20, DarkGreen)

proc unloadTitleScreen* =
  # Title Screen Unload logic
  # TODO: Unload TITLE screen variables here!

proc finishTitleScreen*: int32 =
  # Title Screen should finish?
  return finishScreen
