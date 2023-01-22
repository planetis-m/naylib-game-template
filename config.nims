import os
const AndroidApiVersion {.intdefine.} = 29
const AndroidNdk {.strdefine.} = "/opt/android-ndk"
when defined(windows):
  const AndroidToolchain = AndroidNdk / "toolchains/llvm/prebuilt/windows-x86_64"
elif defined(linux):
  const AndroidToolchain = AndroidNdk / "toolchains/llvm/prebuilt/linux-x86_64"
elif defined(macosx):
  const AndroidToolchain = AndroidNdk / "toolchains/llvm/prebuilt/darwin-x86_64"
const AndroidSysroot = AndroidToolchain / "sysroot"

when defined(android):
  --define:GraphicsApiOpenGlEs2
  --os:android
  # --cpu:arm64
  --cc:clang
  when hostCPU == "arm":
    const AndroidCCType = "arm-linux-androideabi"
    const AndroidAbiFlags = "-march=armv7-a -mfloat-abi=softfp -mfpu=vfpv3-d16"
  elif hostCPU == "arm64":
    const AndroidCCType = "aarch64-linux-android"
    const AndroidAbiFlags = "-march=armv8-a -mfix-cortex-a53-835769"
  elif hostCPU == "i386":
    const AndroidCCType = "i686-linux-android"
    const AndroidAbiFlags = "-march=i686"
  elif hostCPU == "amd64":
    const AndroidCCType = "x86_64-linux-android"
    const AndroidAbiFlags = "-march=x86-64"
  const AndroidAbiTarget = AndroidCCType & $AndroidApiVersion

  switch("clang.path", AndroidToolchain / "bin")
  switch("clang.exe", AndroidAbiTarget & "-clang")
  switch("clang.linkerexe", AndroidAbiTarget & "-clang")
  switch("clang.cpp.exe", AndroidAbiTarget & "-clang++")
  switch("clang.cpp.linkerexe", AndroidAbiTarget & "-clang++")
  switch("clang.options.always", "--sysroot=" & AndroidSysroot & " -I" & AndroidSysroot / "usr/include" &
         " -I" & AndroidSysroot / "usr/include" / AndroidCCType & " " & AndroidAbiFlags)
  switch("clang.options.linker", AndroidAbiFlags & " -L" & AndroidSysroot / "usr/lib")

  # --define:androidNDK
  --mm:orc
  # --threads:off
  --panics:on
  --define:noSignalHandler

elif defined(emscripten):
  --define:GraphicsApiOpenGlEs2
  --define:NaylibWebResources
  --os:linux
  --cpu:wasm32
  --cc:clang
  when defined(windows):
    --clang.exe:emcc.bat
    --clang.linkerexe:emcc.bat
    --clang.cpp.exe:emcc.bat
    --clang.cpp.linkerexe:emcc.bat
  else:
    --clang.exe:emcc
    --clang.linkerexe:emcc
    --clang.cpp.exe:emcc
    --clang.cpp.linkerexe:emcc

  --mm:orc
  --threads:off
  --panics:on
  --define:noSignalHandler
  --passL:"-o raylib_game.html"
  # Use raylib/src/shell.html or raylib/src/minshell.html
  # --passL:"--shell-file minshell.html"
