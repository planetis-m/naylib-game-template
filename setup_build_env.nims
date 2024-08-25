# This script sets up the build environment for an Android project.
# Copyright (c) 2024 Antonis Geralis (@planetis-m)
# See the file "LICENSE", included in this distribution,
# for details about the copyright.

import std/[strutils, os]

# mode = ScriptMode.Verbose

proc appendToGithubFile(envVar: string, pairs: openarray[(string, string)]) =
  let filename = getEnv(envVar)
  if filename != "":
    var content = ""
    if fileExists(filename):
      content = readFile(filename)
    for key, val in pairs.items:
      content.add key & "=" & val & "\n"
    writeFile(filename, content)
  else:
    echo envVar, " is not set."

proc myExec(command: string, input = "", cache = "") =
  let (output, exitCode) = gorgeEx(command, input, cache)
  echo output
  if exitCode != 0:
    raise newException(OSError, "FAILED: " & command)

template verifyHash(filename, expected, cmd: string) =
  myExec(cmd & " -c -", input = expected & " " & filename)

proc verifySha256(filename, expected: string) =
  verifyHash(filename, expected, "sha256sum")

proc verifySha1(filename, expected: string) =
  verifyHash(filename, expected, "sha1sum")

template toBat(x: string): string =
  (when defined(windows): x & ".bat" else: x)

when defined(windows):
  const
    CommandLineToolsZip = "commandlinetools-win-11076708_latest.zip"
    CommandLineToolsSha256 = "4d6931209eebb1bfb7c7e8b240a6a3cb3ab24479ea294f3539429574b1eec862"
    AndroidNdkZip = "android-ndk-r27-windows.zip"
    AndroidNdkSha1 = "0ea2756e6815356831bda3af358cce4cdb6a981e"
elif defined(linux):
  const
    CommandLineToolsZip = "commandlinetools-linux-11076708_latest.zip"
    CommandLineToolsSha256 = "2d2d50857e4eb553af5a6dc3ad507a17adf43d115264b1afc116f95c92e5e258"
    AndroidNdkZip = "android-ndk-r27-linux.zip"
    AndroidNdkSha1 = "5e5cd517bdb98d7e0faf2c494a3041291e71bdcc"

task setupBuildEnv, "Set up Android SDK and NDK for development":
  # Download the Android SDK Command Line Tools
  myExec "wget -nv https://dl.google.com/android/repository/" & CommandLineToolsZip, cache = "1.0"
  # Verify the integrity of the downloaded file
  verifySha256(CommandLineToolsZip, CommandLineToolsSha256)
  # Extract the tools to the specified Android home directory
  myExec "unzip -q " & CommandLineToolsZip & " -d " & AndroidHome, input = "A"
  let sdkmanagerPath = AndroidHome / "cmdline-tools/bin" / "sdkmanager".toBat
  # Accept SDK licenses automatically
  myExec sdkmanagerPath & " --licenses --sdk_root=" & AndroidHome, input = "y\n".repeat(8)
  # Install specific Android SDK components
  exec sdkmanagerPath & " --update --sdk_root=" & AndroidHome
  exec sdkmanagerPath & " --install \"build-tools;34.0.0\" --sdk_root=" & AndroidHome
  exec sdkmanagerPath & " --install \"platform-tools\" --sdk_root=" & AndroidHome
  exec sdkmanagerPath & " --install \"platforms;android-" & $AndroidApiVersion & "\" --sdk_root=" & AndroidHome
  when not defined(GitHubCI) and defined(windows):
    exec sdkmanagerPath & " --install extras;google;usb_driver --sdk_root=" & AndroidHome
  # Download the Android NDK
  myExec "wget -nv https://dl.google.com/android/repository/" & AndroidNdkZip, cache = "1.0"
  # Verify the integrity of the downloaded file.
  verifySha1(AndroidNdkZip, AndroidNdkSha1)
  # Extract and move the NDK to the appropriate directory
  myExec "unzip -q " & AndroidNdkZip, input = "A"
  # AndroidNdkZip[0..<rfind(AndroidNdkZip, '-')]
  mvDir(thisDir() / "android-ndk-r27", AndroidNdk)
  # Set up environment variables
  when defined(GitHubCI):
    appendToGithubFile("GITHUB_ENV", {"ANDROID_HOME": AndroidHome, "ANDROID_NDK": AndroidNdk})
  else:
    putEnv("ANDROID_HOME", AndroidHome)
    putEnv("ANDROID_NDK", AndroidNdk)
