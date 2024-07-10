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
  # Test Android cross-compilation
  setupTask()
  compileTask()

proc appendToGithubFile(envVar, value: string) =
  # Get the path to the target file from the specified environment variable
  let filename = getEnv(envVar, "")
  if filename != "":
    var content = ""
    if fileExists(filename):
      content = readFile(filename)
    content.add value
    content.add "\n"
    writeFile(filename, content)
  else:
    echo envVar, " environment variable is not set."

task setupBuildEnv, "Set up Android SDK/NDK":
  exec("sha256sum -c -", input = getEnv("COMMANDLINETOOLS_SHA256") & "  " & getEnv("COMMANDLINETOOLS_ZIP"))
  exec("/sdkmanager --licenses", input = "y\n".repeat(8))
