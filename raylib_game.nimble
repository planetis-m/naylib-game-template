# Package
version       = "1.0.0"
author        = "Author"
description   = "Raylib game template"
license       = "License"
srcDir        = "src"

# Dependencies
requires "naylib"

include "build_android.nims"

task setupAndroid, "":
  setupTask()

task buildAndroid, "":
  compileTask()

task test, "Runs the test suite":
  exec "nim c -d:release src/raylib_game.nim"
  exec "nim c -d:release -d:emscripten src/raylib_game.nim"
  # Test Android cross-compilation
  setupTask()
  compileTask()
