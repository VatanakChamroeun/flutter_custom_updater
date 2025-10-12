# Mock Update Server

A simple mock server for testing Flutter Custom Updater package.

## Features

- ✅ Simulates update check API
- ✅ Serves Android APK files
- ✅ Serves iOS manifest.plist
- ✅ Automatic version comparison
- ✅ Platform detection (Android/iOS)
- ✅ Works on local network

## Setup

### 1. Install Dependencies

```bash
cd mock_server
npm install
```

### 2. Prepare Files

#### For Android Testing:
```bash
# Copy your APK to downloads folder
mkdir -p downloads
cp path/to/your/app-release.apk downloads/app-v1.2.3.apk
```

#### For iOS Testing:
```bash
# The manifest.plist is already in ios/ folder
# Update it with your bundle ID and IPA URL
# You need HTTPS for real iOS testing
```

### 3. Start Server

```bash
npm start
```

You'll see output like:
```
🚀 Mock Update Server Started!

📍 Server is running on:
   - Local:   http://localhost:3000
   - Network: http://192.168.1.100:3000

📋 Available endpoints:
   - Health Check:  http://localhost:3000/health
   - Update Check:  http://localhost:3000/api/check-update
   - Android APK:   http://localhost:3000/downloads/app-v1.2.3.apk
   - iOS Manifest:  http://localhost:3000/ios/manifest.plist
```

## Usage

### In Your Flutter App

Update your example app to use the mock server:

```dart
final updater = AppUpdater(
  context: context,
  config: UpdaterConfig(
    // Use the Network URL shown in server output
    // Special Android emulator IP that maps to host's localhost
    updateCheckUrl: 'http://10.0.2.2:3000/api/check-update',
  ),
);

await updater.checkAndUpdate();
```

## Testing with Mock Server

### Android Emulator

Use the special Android emulator IP address:
```dart
updateCheckUrl: 'http://10.0.2.2:3000/api/check-update'
```
Note: 10.0.2.2 is a special alias that the Android emulator uses to refer to the host machine's localhost.
### iOS Simulator
Use localhost:
```dart
updateCheckUrl: 'http://localhost:3000/api/check-update'
```
### Physical Devices
Use your computer's actual IP address on the local network:
```
updateCheckUrl: 'http://192.168.1.100:3000/api/check-update'  // Replace with YOUR IP
```

## Find your IP:
```bash
# macOS
ifconfig | grep "inet " | grep -v 127.0.0.1

# Windows
ipconfig

# Linux
ip addr show
```

## Troubleshooting Connection Issues

| Issue | Solution |
|-------|----------|
| Android emulator can't connect | Use `10.0.2.2` instead of `localhost` |
| iOS simulator can't connect | Use `localhost`, ensure mock server is running |
| Physical device can't connect | Ensure both device and computer are on same WiFi |
| Connection timeout | Check firewall settings, verify mock server is running |


### Testing Different Scenarios

#### Test with No Update:
The server compares versions. If your app version is >= 1.2.3, no update will be available.

#### Test with Update Available:
Set your app version to something lower (e.g., 1.0.0) in pubspec.yaml to trigger update.

#### Test Force Update:
Edit `server.js` and change `forceUpdate: false` to `forceUpdate: true`.

### Health Check

Visit http://localhost:3000/health to verify server is running.

### View Logs

The server logs all requests:
```
2025-01-15T10:30:00.000Z - GET /api/check-update
Headers: { 'current-version': '1.0.0', 'platform': 'android' }
📱 Update check from android - Current version: 1.0.0
🆕 Update available!
```

## API Response Examples

### Android Update Available:
```json
{
  "hasUpdate": true,
  "version": "1.2.3",
  "downloadUrl": "http://192.168.1.100:3000/downloads/app-v1.2.3.apk",
  "fileName": "app-v1.2.3.apk",
  "releaseNotes": "🚀 New Features:\n- Bug fixes\n- Performance improvements",
  "forceUpdate": false,
  "fileSize": 25600000
}
```

### iOS Update Available:
```json
{
  "hasUpdate": true,
  "version": "1.2.3",
  "downloadUrl": "http://192.168.1.100:3000/ios/manifest.plist",
  "iosManifestUrl": "http://192.168.1.100:3000/ios/manifest.plist",
  "releaseNotes": "🍎 iOS Update:\n- Bug fixes\n- New features",
  "forceUpdate": false
}
```

### No Update:
```json
{
  "hasUpdate": false
}
```

## Troubleshooting

### Can't connect from physical device?

1. Make sure your computer and device are on the same WiFi network
2. Use the Network URL (not localhost)
3. Check firewall settings

### APK download fails?

1. Ensure APK file exists in `downloads/` folder
2. Check file name matches (app-v1.2.3.apk)
3. Verify file permissions

### iOS manifest doesn't work?

1. iOS enterprise distribution requires HTTPS (not HTTP)
2. For real testing, deploy to HTTPS server
3. This mock server is mainly for Android testing

## Development

### Watch mode (auto-restart on changes):
```bash
npm run dev
```

### Change port:
Edit `server.js` and change `const PORT = 3000;`

### Customize version:
Edit `server.js` and change `const latestVersion = '1.2.3';`

## Notes

- This is for **testing only**, not production use
- Android testing works great on local network
- iOS requires HTTPS server for real testing
- Keep server running while testing Flutter app
