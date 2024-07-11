# Package
version       = "1.0.0"
author        = "Author"
description   = "Raylib game template"
license       = "License"
srcDir        = "src"

# Dependencies
requires "naylib"

#import std/distros
#if detectOs(Windows):
#  foreignDep "openjdk"
#  foreignDep "wget"
#elif detectOs(Ubuntu):
#  foreignDep "default-jdk"

# Tasks

# mode = ScriptMode.Verbose

include "build_android.nims"
include "setup_build_env.nims"

task setupAndroid, "":
  setupTask()

task buildAndroid, "":
  compileTask()

task test, "Runs the test suite":
  # Test Android cross-compilation
  setupTask()
  compileTask()
