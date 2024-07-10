import os
const AndroidApiVersion {.intdefine.} = 33
const AndroidNdk {.strdefine.} = "/opt/android-ndk"
when buildOS == "windows":
  const AndroidToolchain = AndroidNdk / "toolchains/llvm/prebuilt/windows-x86_64"
elif buildOS == "linux":
  const AndroidToolchain = AndroidNdk / "toolchains/llvm/prebuilt/linux-x86_64"
elif buildOS == "macosx":
  const AndroidToolchain = AndroidNdk / "toolchains/llvm/prebuilt/darwin-x86_64"
const AndroidSysroot = AndroidToolchain / "sysroot"

when defined(android):
  --define:GraphicsApiOpenGlEs2
  --os:android
  --cc:clang
  when hostCPU == "arm":
    const AndroidTriple = "armv7a-linux-androideabi"
    const AndroidAbiFlags = "-march=armv7-a -mfloat-abi=softfp -mfpu=vfpv3-d16"
  elif hostCPU == "arm64":
    const AndroidTriple = "aarch64-linux-android"
    const AndroidAbiFlags = "-march=armv8-a -mfix-cortex-a53-835769"
  elif hostCPU == "i386":
    const AndroidTriple = "i686-linux-android"
    const AndroidAbiFlags = "-march=i686"
  elif hostCPU == "amd64":
    const AndroidTriple = "x86_64-linux-android"
    const AndroidAbiFlags = "-march=x86-64"
  const AndroidTarget = AndroidTriple & $AndroidApiVersion

  template toCmd(x: string): string =
    (when defined(windows): x & ".cmd" else: x)

  switch("clang.path", AndroidToolchain / "bin")
  switch("clang.exe", AndroidTarget & "-clang".toCmd)
  switch("clang.linkerexe", AndroidTarget & "-clang".toCmd)
  switch("clang.cpp.path", AndroidToolchain / "bin")
  switch("clang.cpp.exe", AndroidTarget & "-clang++".toCmd)
  switch("clang.cpp.linkerexe", AndroidTarget & "-clang++".toCmd)
  switch("clang.options.always", "--sysroot=" & AndroidSysroot &
         " -I" & AndroidSysroot / "usr/include" &
         " -I" & AndroidSysroot / "usr/include" / AndroidTriple & " " & AndroidAbiFlags &
         " -D__ANDROID__ -D__ANDROID_API__=" & $AndroidApiVersion)
  switch("clang.options.linker", "-shared " & AndroidAbiFlags)

  --define:androidNDK
  # --mm:orc
  --panics:on # not strictly needed but good to have
  --define:noSignalHandler

elif defined(emscripten):
  --define:GraphicsApiOpenGlEs2
  --define:NaylibWebResources
  switch("define", "NaylibWebResourcesPath=src/resources")
  --os:linux
  --cpu:wasm32
  --cc:clang
  when buildOS == "windows":
    --clang.exe:emcc.bat
    --clang.linkerexe:emcc.bat
    --clang.cpp.exe:emcc.bat
    --clang.cpp.linkerexe:emcc.bat
  else:
    --clang.exe:emcc
    --clang.linkerexe:emcc
    --clang.cpp.exe:emcc
    --clang.cpp.linkerexe:emcc

  # --mm:orc
  --threads:on
  --panics:on
  --define:noSignalHandler
  --passL:"-o public/raylib_game.html"
  # Use raylib/src/shell.html or raylib/src/minshell.html
  --passL:"--shell-file src/minshell.html"
