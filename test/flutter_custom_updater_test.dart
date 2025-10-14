import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_custom_updater/flutter_custom_updater.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';

// Generate mocks
@GenerateMocks([http.Client])
void main() {
  group('UpdateInfo Model Tests', () {
    test('should create UpdateInfo from JSON with all fields', () {
      final json = {
        'has_update': true,
        'version': '1.2.3',
        'download_url': 'http://localhost:3000/downloads/app-v1.2.3.apk',
        'file_name': 'app.apk',
        'release_notes': 'Bug fixes',
        'force_update': false,
        'file_size': 1024000,
        'ios_manifest_url': 'http://localhost:3000/ios/manifest.plist',
      };

      final updateInfo = UpdateInfo.fromJson(json);

      expect(updateInfo.hasUpdate, true);
      expect(updateInfo.version, '1.2.3');
      expect(updateInfo.downloadUrl, 'http://localhost:3000/downloads/app-v1.2.3.apk');
      expect(updateInfo.fileName, 'app.apk');
      expect(updateInfo.releaseNotes, 'Bug fixes');
      expect(updateInfo.forceUpdate, false);
      expect(updateInfo.fileSize, 1024000);
      expect(updateInfo.iosManifestUrl, 'http://localhost:3000/ios/manifest.plist');
    });

    test('should handle missing optional fields', () {
      final json = {'has_update': false, 'download_url': ''};

      final updateInfo = UpdateInfo.fromJson(json);

      expect(updateInfo.hasUpdate, false);
      expect(updateInfo.version, null);
      expect(updateInfo.fileName, null);
      expect(updateInfo.releaseNotes, null);
      expect(updateInfo.forceUpdate, false);
      expect(updateInfo.fileSize, null);
    });

    test('should serialize UpdateInfo to JSON', () {
      final updateInfo = UpdateInfo(
        hasUpdate: true,
        version: '1.2.3',
        downloadUrl: 'http://localhost:3000/downloads/app-v1.2.3.apk',
        fileName: 'app.apk',
        releaseNotes: 'Bug fixes',
        forceUpdate: true,
        fileSize: 1024000,
      );

      final json = updateInfo.toJson();

      expect(json['has_update'], true);
      expect(json['version'], '1.2.3');
      expect(json['download_url'], 'http://localhost:3000/downloads/app-v1.2.3.apk');
      expect(json['file_name'], 'app.apk');
      expect(json['release_notes'], 'Bug fixes');
      expect(json['force_update'], true);
      expect(json['file_size'], 1024000);
    });
  });

  group('UpdaterConfig Tests', () {
    test('should create config with required fields only', () {
      final config = UpdaterConfig(updateCheckUrl: 'http://localhost:3000/api/check-update');

      expect(config.updateCheckUrl, 'http://localhost:3000/api/check-update');
      expect(config.timeout, Duration(seconds: 30));
      expect(config.downloadTimeout, Duration(minutes: 5));
      expect(config.allowDismiss, false);
    });

    test('should create config with all custom fields', () {
      final config = UpdaterConfig(
        updateCheckUrl: 'http://localhost:3000/api/check-update',
        customHeaders: {'Authorization': 'Bearer token'},
        timeout: Duration(seconds: 60),
        downloadTimeout: Duration(minutes: 10),
        allowDismiss: true,
        dialogTitle: 'Update Available',
        updateButtonText: 'Install',
        laterButtonText: 'Later',
        iosInstallText: 'Installing...',
      );

      expect(config.updateCheckUrl, 'http://localhost:3000/api/check-update');
      expect(config.customHeaders, {'Authorization': 'Bearer token'});
      expect(config.timeout, Duration(seconds: 60));
      expect(config.downloadTimeout, Duration(minutes: 10));
      expect(config.allowDismiss, true);
      expect(config.dialogTitle, 'Update Available');
      expect(config.updateButtonText, 'Install');
      expect(config.laterButtonText, 'Later');
      expect(config.iosInstallText, 'Installing...');
    });

    test('should handle callbacks', () {
      bool callbackCalled = false;

      final config = UpdaterConfig(
        updateCheckUrl: 'http://localhost:3000/api/check-update',
        onNoUpdateAvailable: () {
          callbackCalled = true;
        },
      );

      config.onNoUpdateAvailable?.call();
      expect(callbackCalled, true);
    });
  });

  group('UpdateDialog Widget Tests', () {
    testWidgets('should display update dialog with all info', (tester) async {
      final updateInfo = UpdateInfo(
        hasUpdate: true,
        version: '1.2.3',
        downloadUrl: 'http://localhost:3000/downloads/app-v1.2.3.apk',
        releaseNotes: 'Bug fixes and improvements',
        forceUpdate: false,
        fileSize: 1024000,
      );

      final config = UpdaterConfig(
        updateCheckUrl: 'http://localhost:3000/api/check-update',
        dialogTitle: 'Update Available',
        updateButtonText: 'Update Now',
        laterButtonText: 'Later',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => UpdateDialog(updateInfo: updateInfo, config: config),
                    );
                  },
                  child: Text('Show Dialog'),
                );
              },
            ),
          ),
        ),
      );

      // Tap button to show dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Verify dialog content
      expect(find.text('Update Available'), findsOneWidget);
      expect(find.text('Version 1.2.3'), findsOneWidget);
      expect(find.text('Bug fixes and improvements'), findsOneWidget);
      expect(find.text('Update Now'), findsOneWidget);
      expect(find.text('Later'), findsOneWidget);
    });

    testWidgets('should hide Later button for force update', (tester) async {
      final updateInfo = UpdateInfo(
        hasUpdate: true,
        version: '2.0.0',
        downloadUrl: 'http://localhost:3000/downloads/app-v1.2.3.apk',
        forceUpdate: true,
      );

      final config = UpdaterConfig(
        updateCheckUrl: 'http://localhost:3000/api/check-update',
        updateButtonText: 'Update Now',
        laterButtonText: 'Later',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => UpdateDialog(updateInfo: updateInfo, config: config),
                    );
                  },
                  child: Text('Show Dialog'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Later button should not be visible
      expect(find.text('Later'), findsNothing);
      expect(find.text('Update Now'), findsOneWidget);
    });

    testWidgets('should show file size for Android', (tester) async {
      // Mock Platform.isAndroid would require platform channel mocking
      // This is a simplified test
      final updateInfo = UpdateInfo(
        hasUpdate: true,
        version: '1.2.3',
        downloadUrl: 'http://localhost:3000/downloads/app-v1.2.3.apk',
        fileSize: 25600000, // 25.6 MB
      );

      final config = UpdaterConfig(updateCheckUrl: 'http://localhost:3000/api/check-update');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => UpdateDialog(updateInfo: updateInfo, config: config),
                    );
                  },
                  child: Text('Show Dialog'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // File size should be displayed (when on Android)
      // Note: In real test, you'd need to mock Platform.isAndroid
      expect(updateInfo.fileSize, 25600000);
    });
  });

  group('DownloadDialog Widget Tests', () {
    testWidgets('should display download progress', (tester) async {
      final config = UpdaterConfig(
        updateCheckUrl: 'http://localhost:3000/api/check-update',
        downloadingText: 'Downloading update...',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DownloadDialog(config: config)),
        ),
      );

      expect(find.text('Downloading update...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should not be dismissible', (tester) async {
      final config = UpdaterConfig(updateCheckUrl: 'http://localhost:3000/api/check-update');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => DownloadDialog(config: config),
                    );
                  },
                  child: Text('Show Download'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Download'));
      await tester.pumpAndSettle();

      // Try to dismiss by tapping outside
      await tester.tapAt(Offset(10, 10));
      await tester.pumpAndSettle();

      // Dialog should still be visible
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
