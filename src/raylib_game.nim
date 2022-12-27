# ****************************************************************************************
#
#   raylib game template
#
#   <Game title>
#   <Game description>
#
#   This game has been created using raylib (www.raylib.com)
#   raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
#   Copyright (c) 2021 Ramon Santamaria (@raysan5)
#
# ****************************************************************************************

import
  raylib, screens, screen_logo, screen_title, screen_options, screen_gameplay, screen_ending

# ----------------------------------------------------------------------------------------
# Local Variables Definition (local to this module)
# ----------------------------------------------------------------------------------------

const
  screenWidth = 800
  screenHeight = 450

# Required variables to manage screen transitions (fade-in, fade-out)

var
  transAlpha: float32 = 0
  onTransition: bool = false
  transFadeOut: bool = false
  transFromScreen: GameScreen = Unknown
  transToScreen: GameScreen = Unknown

# ----------------------------------------------------------------------------------------
# Module specific Functions Definition
# ----------------------------------------------------------------------------------------

proc changeToScreen(screen: GameScreen) =
  # Change to next screen, no transition
  # Unload current screen
  case currentScreen
  of Logo:
    unloadLogoScreen()
  of Title:
    unloadTitleScreen()
  of Gameplay:
    unloadGameplayScreen()
  of Ending:
    unloadEndingScreen()
  else:
    discard
  # Init next screen
  case screen
  of Logo:
    initLogoScreen()
  of Title:
    initTitleScreen()
  of Gameplay:
    initGameplayScreen()
  of Ending:
    initEndingScreen()
  else:
    discard
  currentScreen = screen

proc transitionToScreen(screen: GameScreen) =
  # Request transition to next screen
  onTransition = true
  transFadeOut = false
  transFromScreen = currentScreen
  transToScreen = screen
  transAlpha = 0

proc updateTransition =
  # Update transition effect (fade-in, fade-out)
  if not transFadeOut:          # Transition fade out logic
    transAlpha += 0.05
    # NOTE: Due to float internal representation, condition jumps on 1.0f instead of 1.05f
    # For that reason we compare against 1.01f, to avoid last frame loading stop
    if transAlpha > 1.01'f32:
      transAlpha = 1
      # Unload current screen
      case transFromScreen
      of Logo:
        unloadLogoScreen()
      of Title:
        unloadTitleScreen()
      of Gameplay:
        unloadGameplayScreen()
      of Ending:
        unloadEndingScreen()
      else:
        discard
      # Init next screen
      case transToScreen
      of Logo:
        initLogoScreen()
      of Title:
        initTitleScreen()
      of Gameplay:
        initGameplayScreen()
      of Ending:
        initEndingScreen()
      else:
        discard
      currentScreen = transToScreen
      # Activate fade out effect to next loaded screen
      transFadeOut = true
  else:
    transAlpha -= 0.02
    if transAlpha < -0.01'f32:
      transAlpha = 0
      transFadeOut = false
      onTransition = false
      transFromScreen = Unknown
      transToScreen = Unknown

proc drawTransition =
  # Draw transition effect (full-screen rectangle)
  drawRectangle(0, 0, getScreenWidth(), getScreenHeight(), fade(Black, transAlpha))

proc updateDrawFrame {.cdecl.} =
  # Update and draw game frame
  # Update
  # --------------------------------------------------------------------------------------
  updateMusicStream(music)
  # NOTE: Music keeps playing between screens
  if not onTransition:
    case currentScreen
    of Logo:
      updateLogoScreen()
      if finishLogoScreen() == 1:
        transitionToScreen(Title)
    of Title:
      updateTitleScreen()
      if finishTitleScreen() == 1:
        transitionToScreen(Options)
      elif finishTitleScreen() == 2:
        transitionToScreen(Gameplay)
    of Options:
      updateOptionsScreen()
      if finishOptionsScreen() == 1:
        transitionToScreen(Title)
    of Gameplay:
      updateGameplayScreen()
      if finishGameplayScreen() == 1:
        transitionToScreen(Ending)
    of Ending:
      updateEndingScreen()
      if finishEndingScreen() == 1:
        transitionToScreen(Title)
    else:
      discard
  else:
    updateTransition()
  # Update transition (fade-in, fade-out)
  # --------------------------------------------------------------------------------------
  # Draw
  # --------------------------------------------------------------------------------------
  beginDrawing()
  clearBackground(RayWhite)
  case currentScreen
  of Logo:
    drawLogoScreen()
  of Title:
    drawTitleScreen()
  of Options:
    drawOptionsScreen()
  of Gameplay:
    drawGameplayScreen()
  of Ending:
    drawEndingScreen()
  else:
    discard
  # Draw full screen rectangle in front of everything
  if onTransition:
    drawTransition()
  endDrawing()
  # --------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------
# Main entry point
# ----------------------------------------------------------------------------------------

proc main =
  # Initialization
  # --------------------------------------------------------------------------------------
  initWindow(screenWidth, screenHeight, "raylib game template")
  initAudioDevice() # Initialize audio device
  try:
    # Load global data (assets that must be available in all screens, i.e. font)
    font = loadFont("resources/mecha.png")
    music = loadMusicStream("resources/ambient.ogg")
    fxCoin = loadSound("resources/coin.wav")
    setMusicVolume(music, 1)
    playMusicStream(music)
    # Setup and init first screen
    currentScreen = Logo
    initLogoScreen()
    when defined(emscripten):
      emscriptenSetMainLoop(updateDrawFrame, 60, 1)
    else:
      setTargetFPS(60) # Set our game to run at 60 frames-per-second
      # ----------------------------------------------------------------------------------
      # Main game loop
      while not windowShouldClose(): # Detect window close button or ESC key
        updateDrawFrame()
    # De-Initialization
    # ------------------------------------------------------------------------------------
    # Unload current screen data before closing
    case currentScreen
    of Logo:
      unloadLogoScreen()
    of Title:
      unloadTitleScreen()
    of Gameplay:
      unloadGameplayScreen()
    of Ending:
      unloadEndingScreen()
    else:
      discard
    # Unload global data loaded
    reset(font)
    reset(music)
    reset(fxCoin)
  finally:
    closeAudioDevice() # Close audio context
    closeWindow() # Close window and OpenGL context
  # --------------------------------------------------------------------------------------

main()
