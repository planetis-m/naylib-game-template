# Package
version       = "1.0.0"
author        = "Author"
description   = "Raylib game template"
license       = "License"
srcDir        = "src"

# Dependencies
requires "naylib#5da4353"

import os

# Define Android architecture (armeabi-v7a, arm64-v8a, x86, x86-64) and API version
const AndroidApi = 29
when hostCPU == "arm":
  const AndroidArchName = "armeabi-v7a"
elif hostCPU == "arm64":
  const AndroidArchName = "arm64-v8a"
elif hostCPU == "i386":
  const AndroidArchName = "i686"
elif hostCPU == "amd64":
  const AndroidArchName = "x86_64"

# Required path variables
const
  JavaHome = "/usr/lib/jvm/java-19-openjdk"
  AndroidHome = "/opt/android-sdk"
  AndroidNdk = "/opt/android-ndk"
when defined(windows):
  const AndroidToolchain = AndroidNdk / "toolchains/llvm/prebuilt/windows-x86_64"
elif defined(linux):
  const AndroidToolchain = AndroidNdk / "toolchains/llvm/prebuilt/linux-x86_64"
elif defined(macosx):
  const AndroidToolchain = AndroidNdk / "toolchains/llvm/prebuilt/darwin-x86_64"
const
  AndroidBuildTools = AndroidHome / "build-tools/30.0.3"
  AndroidPlatformTools = AndroidHome / "platform-tools"

# Android project configuration variables
const
  ProjectName = "raylib_game"
  ProjectLibraryName = "main"
  ProjectBuildId = "android"
  ProjectBuildPath = ProjectBuildId & "." & ProjectName
  ProjectResourcesPath = "resources"

# Android app configuration variables
const
  AppLabelName = "rGame"
  AppCompanyName = "raylib"
  AppProductName = "rgame"
  AppVersionCode = 1
  AppVersionName = "1.0"
  AppIconLdpi = "logo/raylib_36x36.png"
  AppIconMdpi = "logo/raylib_48x48.png"
  AppIconHdpi = "logo/raylib_72x72.png"
  AppScreenOrientation = "landscape"
  AppKeystorePass = "raylib"

task setupAndroid, "Set up raylib project for Android":
  mkDir(ProjectBuildPath / "src/com" / AppCompanyName / AppProductName)
  mkDir(ProjectBuildPath / "lib" / AndroidArchName)
  mkDir(ProjectBuildPath / "bin")
  mkDir(ProjectBuildPath / "res/drawable-ldpi")
  mkDir(ProjectBuildPath / "res/drawable-mdpi")
  mkDir(ProjectBuildPath / "res/drawable-hdpi")
  mkDir(ProjectBuildPath / "res/values")
  mkDir(ProjectBuildPath / "assets")
  mkDir(ProjectBuildPath / "obj/screens")

task buildAndroid, "Compile raylib project for Android":
  discard
