# Flutter Custom Updater

📦 Flutter package for internal app updates (APK & IPA). Update your apps from your own server without App Store or Play Store. Perfect for self-hosted, enterprise, and private distribution.

## Features

### Cross-Platform Support

| Platform | Format | Installation Method | Status |
|----------|--------|---------------------|--------|
| Android | APK | Automatic download and installation | ✅ Supported |
| iOS | IPA | Enterprise distribution via itms-services protocol | ✅ Supported |

### Core Features

- ✅ Automatic version checking from your own server
- ✅ Customizable update dialogs
- ✅ Background APK download (Android)
- ✅ Automatic installation trigger
- ✅ Force update support
- ✅ Comprehensive error handling
- ✅ Highly customizable UI
- ✅ Callback support for all events
- ✅ File size display
- ✅ Release notes support
- ✅ Self-hosted server support

## Installation

Install directly from GitHub (always get the latest):
```
dependencies:
  flutter_custom_updater:
    git:
      url: https://github.com/vatanakchamroeun/flutter_custom_updater.git
      ref: v1.0.0  # Use specific tag or commit hash
```
or install to your local
```
dependencies:
  flutter_custom_updater:
    path: ../flutter_custom_updater
```

## Setup
### Android Setup
And add these permissions to your android/app/src/main/AndroidManifest.xml:
```xml
<manifest>
    <!-- Add these permissions -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES"/>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
    
    <application>
        <!-- Add FileProvider for Android N+ -->
        <provider
            android:name="androidx.core.content.FileProvider"
            android:authorities="${applicationId}.provider"
            android:exported="false"
            android:grantUriPermissions="true">
            <meta-data
                android:name="android.support.FILE_PROVIDER_PATHS"
                android:resource="@xml/file_paths"/>
        </provider>
    </application>
</manifest>
```

Create android/app/src/main/res/xml/file_paths.xml:
```xml
<?xml version="1.0" encoding="utf-8"?>
<paths>
    <external-path name="external_files" path="."/>
</paths>
```

### iOS Setup
Edit ios/Runner/Info.plist and add this inside the <dict> tag:
```
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>itms-services</string>
</array>
```

## Usage

```dart
// Server should return: "forceUpdate": true
// The dialog will hide "Later" button and prevent dismissal
import 'package:flutter_custom_updater/flutter_custom_updater.dart';

final updater = AppUpdater(
  context: context,
  config: UpdaterConfig(
    updateCheckUrl: 'https://your-server.com/api/check-update',
    customHeaders: {'Authorization': 'Bearer TOKEN'},
    
    // UI Customization (works for both platforms)
    dialogTitle: Platform.isIOS ? 'New Update! 🍎' : 'New Update! 🤖',
    updateButtonText: 'Install Now',
    laterButtonText: 'Maybe Later',
    allowDismiss: true,
    
    // iOS-specific configuration
    iosInstallText: 'Preparing installation...\nPlease tap "Install" when prompted.',
    
    // Callbacks (work for both platforms)
    onNoUpdateAvailable: () => print('Up to date'),
    onError: (error) => print('Error: $error'),
    onDownloadComplete: (path) => print('Downloaded: $path'),  // Android only
    onInstallStart: () => print('Installing...'),
  ),
);

await updater.checkAndUpdate();
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
