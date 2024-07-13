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

proc myExec(command, input: string, cache = "") =
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
    AndroidNdkZip = "android-ndk-r26d-windows.zip"
    AndroidNdkSha1 = "c7ea35ffe916082876611da1a6d5618d15430c29"
elif defined(linux):
  const
    CommandLineToolsZip = "commandlinetools-linux-11076708_latest.zip"
    CommandLineToolsSha256 = "2d2d50857e4eb553af5a6dc3ad507a17adf43d115264b1afc116f95c92e5e258"
    AndroidNdkZip = "android-ndk-r26d-linux.zip"
    AndroidNdkSha1 = "fcdad75a765a46a9cf6560353f480db251d14765"

task setupBuildEnv, "Set up Android SDK/NDK":
  # Set up Android SDK
  myExec "wget -nv https://dl.google.com/android/repository/" & CommandLineToolsZip, "", cache = "1.0"
  verifySha256(CommandLineToolsZip, CommandLineToolsSha256)
  myExec "unzip -q " & CommandLineToolsZip & " -d " & AndroidHome, input = "A"
  let sdkmanagerPath = AndroidHome / "cmdline-tools/bin" / "sdkmanager".toBat
  myExec sdkmanagerPath & " --licenses --sdk_root=" & AndroidHome, input = "y\n".repeat(8)
  exec sdkmanagerPath & " --update --sdk_root=" & AndroidHome
  exec sdkmanagerPath & " --install \"build-tools;34.0.0\" --sdk_root=" & AndroidHome
  exec sdkmanagerPath & " --install \"platform-tools\" --sdk_root=" & AndroidHome
  exec sdkmanagerPath & " --install \"platforms;android-" & $AndroidApiVersion & "\" --sdk_root=" & AndroidHome
  when not defined(GitHubCI) and defined(windows):
    exec sdkmanagerPath & " --install extras;google;usb_driver --sdk_root=" & AndroidHome
  # Set up Android NDK
  myExec "wget -nv https://dl.google.com/android/repository/" & AndroidNdkZip, "", cache = "1.0"
  verifySha1(AndroidNdkZip, AndroidNdkSha1)
  myExec "unzip -q " & AndroidNdkZip, input = "A"
  mvDir(thisDir() / "android-ndk-r26d", AndroidNdk)
  when defined(GitHubCI):
    appendToGithubFile("GITHUB_ENV", {"ANDROID_HOME": AndroidHome, "ANDROID_NDK": AndroidNdk})
