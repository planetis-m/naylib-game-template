# Package
version       = "1.0.0"
author        = "Author"
description   = "Raylib game template"
license       = "License"
srcDir        = "src"

# Dependencies
requires "naylib#78146ca"

import std/[os, strutils, sequtils]

# Define Android architecture (armeabi-v7a, arm64-v8a, x86, x86-64) and API version
const AndroidApiVersion = 29
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
  AndroidNdk = "/opt/android-ndk"
  AndroidHome = "/opt/android-sdk"
  AndroidBuildTools = AndroidHome / "build-tools/33.0.1"
  AndroidPlatformTools = AndroidHome / "platform-tools"

# Android project configuration variables
const
  ProjectName = "raylib_game"
  ProjectLibraryName = "main"
  ProjectBuildId = "android"
  ProjectBuildPath = ProjectBuildId & "." & ProjectName
  ProjectResourcesPath = "src/resources"
  ProjectSourceFile = "src/raylib_game.nim"

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
  # Create required temp directories for APK building
  mkDir(ProjectBuildPath / "src/com" / AppCompanyName / AppProductName)
  mkDir(ProjectBuildPath / "lib" / AndroidArchName)
  mkDir(ProjectBuildPath / "bin")
  mkDir(ProjectBuildPath / "res/drawable-ldpi")
  mkDir(ProjectBuildPath / "res/drawable-mdpi")
  mkDir(ProjectBuildPath / "res/drawable-hdpi")
  mkDir(ProjectBuildPath / "res/values")
  mkDir(ProjectBuildPath / "assets/resources")
  mkDir(ProjectBuildPath / "obj/screens")
  # Copy project required resources: strings.xml, icon.png, assets
  writeFile(ProjectBuildPath / "res/values/strings.xml",
      "<?xml version='1.0' encoding='utf-8'?>\n<resources><string name='app_name'>" & AppLabelName & "</string></resources>\n")
  cpFile(AppIconLdpi, ProjectBuildPath / "res/drawable-ldpi/icon.png")
  cpFile(AppIconMdpi, ProjectBuildPath / "res/drawable-mdpi/icon.png")
  cpFile(AppIconHdpi, ProjectBuildPath / "res/drawable-hdpi/icon.png")
  cpDir(ProjectResourcesPath, ProjectBuildPath / "assets/resources")
  # Generate NativeLoader.java to load required shared libraries
  writeFile(ProjectBuildPath / "src/com" / AppCompanyName / AppProductName / "NativeLoader.java",
      "package com." & AppCompanyName & "." & AppProductName & """;

public class NativeLoader extends android.app.NativeActivity {
    static {
        System.loadLibrary("""" & ProjectLibraryName & """");
    }
}
""")
  # Generate AndroidManifest.xml with all the required options
  writeFile(ProjectBuildPath / "AndroidManifest.xml", """
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
        package="com.""" & AppCompanyName & "." & AppProductName & """"
        android:versionCode="""" & $AppVersionCode & "\" android:versionName=\"" & AppVersionName & """" >
    <uses-sdk android:minSdkVersion="""" & $AndroidApiVersion & """" />
    <uses-feature android:glEsVersion="0x00020000" android:required="true" />
    <application android:allowBackup="false" android:label="@string/app_name" android:icon="@drawable/icon" >
        <activity android:name="com.""" & AppCompanyName & "." & AppProductName & """.NativeLoader"
            android:theme="@android:style/Theme.NoTitleBar.Fullscreen"
            android:configChanges="orientation|keyboardHidden|screenSize"
            android:screenOrientation="""" & AppScreenOrientation & """" android:launchMode="singleTask"
            android:clearTaskOnLaunch="true">
            <meta-data android:name="android.app.lib_name" android:value="""" & ProjectLibraryName & """" />
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>
</manifest>
""")
  # Generate storekey for APK signing: {ProjectName}.keystore
  let keystorePath = ProjectBuildPath / ProjectName & ".keystore"
  if not fileExists(keystorePath):
    exec(JavaHome / "bin/keytool -genkeypair -validity 10000 -dname \"CN=" & AppCompanyName &
        ",O=Android,C=ES\" -keystore " & keystorePath & " -storepass " & AppKeystorePass &
        " -keypass " & AppKeystorePass & " -alias " & ProjectName & "Key -keyalg RSA")

task buildAndroid, "Compile raylib project for Android":
  # Config project package and resource using AndroidManifest.xml and res/values/strings.xml
  let androidResourcePath = AndroidHome / ("platforms/android-" & $AndroidApiVersion) / "android.jar"
  exec(AndroidBuildTools / "aapt" & " package -f -m -S " & ProjectBuildPath / "res" & " -J " &
      ProjectBuildPath / "src" & " -M " & ProjectBuildPath / "AndroidManifest.xml" & " -I " & androidResourcePath)
  # Compile project code into a shared library: lib/lib{ProjectLibraryName}.so
  exec("nim c -d:release --os:android --cpu:" & hostCPU & " -d:AndroidApiVersion=" &
      $AndroidApiVersion & " -d:AndroidNdk=" & AndroidNdk & " -o:" &
      ProjectBuildPath / "lib" / AndroidArchName / ("lib" & ProjectLibraryName & ".so") & " " & ProjectSourceFile)
  # Compile project .java code into .class (Java bytecode)
  exec(JavaHome / "bin/javac" & " -verbose -source 1.8 -target 1.8 -d " & ProjectBuildPath / "obj" &
      " -bootclasspath " & JavaHome / "jre/lib/rt.jar" & " -classpath " & androidResourcePath & ":" &
      ProjectBuildPath / "obj" & " -sourcepath " & ProjectBuildPath / "src" & " " &
      ProjectBuildPath / "src/com" / AppCompanyName / AppProductName / "R.java" & " " &
      ProjectBuildPath / "src/com" / AppCompanyName / AppProductName / "NativeLoader.java")
  # Compile .class files into Dalvik executable bytecode (.dex)
  let classes = join(map(listFiles(ProjectBuildPath / "obj/com" / AppCompanyName / AppProductName), quoteShell), " ")
  exec(AndroidBuildTools / "d8" & " --release --output " & ProjectBuildPath / "bin" &
      " " & classes & " --lib " & androidResourcePath)
  # Create Android APK package: bin/{ProjectName}.unsigned.apk
  let unsignedApkPath = ProjectBuildPath / "bin" / (ProjectName & ".unsigned.apk")
  let signedApkPath = ProjectBuildPath / "bin" / (ProjectName & ".signed.apk")
  rmFile(unsignedApkPath) # fixes rebuilding
  rmFile(signedApkPath)
  exec(AndroidBuildTools / "aapt" & " package -f -M " & ProjectBuildPath / "AndroidManifest.xml" & " -S " &
      ProjectBuildPath / "res" & " -A " & ProjectBuildPath / "assets" & " -I " & androidResourcePath & " -F " &
      unsignedApkPath & " " & ProjectBuildPath / "bin")
  withDir(ProjectBuildPath):
    exec(AndroidBuildTools / "aapt" & " add " & "bin" / (ProjectName & ".unsigned.apk") & " " &
        "lib" / AndroidArchName / ("lib" & ProjectLibraryName & ".so"))
  # Create signed APK package using generated Key: bin/{ProjectName}.signed.apk
  exec(JavaHome / "bin/jarsigner" & " -keystore " & ProjectBuildPath / (ProjectName & ".keystore") &
      " -storepass " & AppKeystorePass & " -keypass " & AppKeystorePass &
      " -signedjar " & signedApkPath &
      " " & unsignedApkPath & " " & ProjectName & "Key")
  # Create zip-aligned APK package: {ProjectName}.apk
  exec(AndroidBuildTools / "zipalign" & " -f 4 " & signedApkPath & " " &
      ProjectName & ".apk")
