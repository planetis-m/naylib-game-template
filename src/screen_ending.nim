# ****************************************************************************************
#
#   raylib - Advance Game template
#
#   Ending Screen Functions Definitions (Init, Update, Draw, Unload)
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

import raylib, screens, std/lenientops

# ----------------------------------------------------------------------------------------
# Module Variables Definition (local)
# ----------------------------------------------------------------------------------------

var
  framesCounter: int32 = 0
  finishScreen: int32 = 0

# ----------------------------------------------------------------------------------------
# Ending Screen Functions Definition
# ----------------------------------------------------------------------------------------

proc initEndingScreen* =
  # Ending Screen Initialization logic
  # TODO: Initialize ENDING screen variables here!
  framesCounter = 0
  finishScreen = 0

proc updateEndingScreen* =
  # Ending Screen Update logic
  # TODO: Update ENDING screen variables here!
  # Press enter or tap to return to TITLE screen
  if isKeyPressed(KeyEnter) or isGestureDetected(GestureTap):
    finishScreen = 1
    playSound(fxCoin)

proc drawEndingScreen* =
  # Ending Screen Draw logic
  # TODO: Draw ENDING screen here!
  drawRectangle(0, 0, getScreenWidth(), getScreenHeight(), Blue)
  drawText(font, "ENDING SCREEN", Vector2(x: 20, y: 10), font.baseSize*3'f32, 4, DarkBlue)
  drawText("PRESS ENTER or TAP to RETURN to TITLE SCREEN", 120, 220, 20, DarkBlue)

proc unloadEndingScreen* =
  # Ending Screen Unload logic
  # TODO: Unload ENDING screen variables here!
  discard

proc finishEndingScreen*: int32 =
  # Ending Screen should finish?
  return finishScreen
