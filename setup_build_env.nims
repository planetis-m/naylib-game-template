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
    CommandLineToolsZip = "commandlinetools-win-13114758_latest.zip"
    CommandLineToolsSha256 = "98b565cb657b012dae6794cefc0f66ae1efb4690c699b78a614b4a6a3505b003"
    AndroidNdkZip = "android-ndk-r27c-windows.zip"
    AndroidNdkSha1 = "ac5f7762764b1f15341094e148ad4f847d050c38"
elif defined(linux):
  const
    CommandLineToolsZip = "commandlinetools-linux-13114758_latest.zip"
    CommandLineToolsSha256 = "7ec965280a073311c339e571cd5de778b9975026cfcbe79f2b1cdcb1e15317ee"
    AndroidNdkZip = "android-ndk-r27c-linux.zip"
    AndroidNdkSha1 = "090e8083a715fdb1a3e402d0763c388abb03fb4e"
elif defined(macosx):
  const
    CommandLineToolsZip = "commandlinetools-mac-13114758_latest.zip"
    CommandLineToolsSha256 = "5673201e6f3869f418eeed3b5cb6c4be7401502bd0aae1b12a29d164d647a54e"
    AndroidNdkZip = "android-ndk-r27c-darwin.dmg"
    AndroidNdkSha1 = "04d8c43eb4e884c4b16bbf7733ac9179a13b7b20"

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
  exec "set SKIP_JDK_VERSION_CHECK=true"
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
  when defined(macosx):
    # Create a temporary directory for mounting
    let tempDir = "/tmp/android-ndk"
    mkDir tempDir
    # Mount the DMG file
    myExec "hdiutil attach " & AndroidNdkZip & " -mountpoint " & tempDir
    # Copy the contents to the appropriate directory
    cpDir tempDir / "android-ndk-r27c", thisDir() / "android-ndk-r27c"
    # Unmount the DMG file
    myExec "hdiutil detach " & tempDir
    # Remove the temporary directory
    rmDir tempDir
  else: myExec "unzip -q " & AndroidNdkZip, input = "A"
  # AndroidNdkZip[0..<rfind(AndroidNdkZip, '-')]
  mvDir(thisDir() / "android-ndk-r27c", AndroidNdk)
  # Set up environment variables
  when defined(GitHubCI):
    appendToGithubFile("GITHUB_ENV", {"ANDROID_HOME": AndroidHome, "ANDROID_NDK": AndroidNdk})
  else:
    putEnv("ANDROID_HOME", AndroidHome)
    putEnv("ANDROID_NDK", AndroidNdk)
