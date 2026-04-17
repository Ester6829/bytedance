# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter plugin (`bytedance`) that integrates ByteDance advertising and analytics SDKs for both Android and iOS platforms.

## Key Features

- **Event Tracking**: Upload register events to ByteDance SDK
- **Device Identification**: 
  - iOS: Get IDFV (Identifier for Vendor)
  - Android: Get Android ID
- **Platform Version**: Get OS version information

## Architecture

This plugin follows the standard Flutter plugin architecture:

1. **Dart API Layer** (`lib/bytedance.dart`): Main plugin class that exposes methods to Flutter apps
2. **Platform Interface** (`lib/bytedance_platform_interface.dart`): Abstract interface defining the plugin's contract
3. **Method Channel** (`lib/bytedance_method_channel.dart`): Default implementation using MethodChannel for communication
4. **Android Implementation** (`android/src/main/java/com/example/bytedance/BytedancePlugin.java`): Native Android code using BDConvert SDK
5. **iOS Implementation** (`ios/Classes/BytedancePlugin.m`): Native iOS code using BDASignalSDK

## Main Methods

| Method | Description | Platform |
|--------|-------------|----------|
| `getPlatformVersion()` | Returns OS version string | Both |
| `uploadRegister(Map<String, dynamic> arguments)` | Tracks a register event | Both |
| `getIdfv()` | Returns device IDFV | iOS only |
| `getAndroidId()` | Returns Android ID | Android only |

## Dependencies

- **Flutter SDK**: ^3.9.0
- **plugin_platform_interface**: ^2.0.2

## Platform-Specific Notes

### Android Integration

- Uses BDConvert SDK from ByteDance
- Package: `com.example.bytedance`
- Main class: `BytedancePlugin`

### iOS Integration

- Uses BDASignalSDK (installed via CocoaPods)
- Plugin class: `BytedancePlugin`
- Implements `UIApplicationDelegate` for app lifecycle events
- Handles deeplink click callbacks via `openURL`
- IDFA tracking enabled by default (call `enableIdfa:YES`)

## Development Commands

| Command | Description |
|---------|-------------|
| `flutter pub get` | Install dependencies |
| `flutter analyze` | Run static analysis |
| `flutter test` | Run tests |

## Example App

The plugin includes an example app in the `example/` directory that demonstrates how to use the plugin.
