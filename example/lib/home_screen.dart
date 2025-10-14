import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_custom_updater/flutter_custom_updater.dart';
import 'package:package_info_plus/package_info_plus.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _updateStatus = 'No update check performed';
  String _appVersion = 'Loading...';
  String _buildNumber = '';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
    // Check for updates on app start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForUpdates();
    });
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = packageInfo.version;
        _buildNumber = packageInfo.buildNumber;
      });
    } catch (e) {
      setState(() {
        _appVersion = 'Unknown';
      });
    }
  }

  Future<void> _checkForUpdates() async {
    setState(() {
      _updateStatus = 'Checking for updates...';
    });

    final updater = AppUpdater(
      context: context,
      config: UpdaterConfig(
        // Replace with your actual server URL
        updateCheckUrl: 'http://10.0.2.2:3000/api/check-update', // Special Android emulator IP that maps to host's localhost
        // UI Customization
        dialogTitle: 'Update Available! 🚀',
        updateButtonText: 'Update Now',
        laterButtonText: 'Later',
        downloadingText: 'Downloading update...',

        // iOS Configuration
        iosInstallText: 'Preparing installation...\nPlease follow the system prompts.',

        // Allow dismissing the dialog
        allowDismiss: true,

        // Callbacks
        onNoUpdateAvailable: () {
          setState(() {
            _updateStatus = 'App is up to date ✓';
          });
        },
        onError: (error) {
          setState(() {
            _updateStatus = 'Error: $error';
          });
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Update check failed: $error'), backgroundColor: Colors.red));
        },
        onDownloadComplete: (path) {
          setState(() {
            _updateStatus = 'Download complete: $path';
          });
        },
        onInstallStart: () {
          setState(() {
            _updateStatus = 'Installing update...';
          });
        },
      ),
    );

    await updater.checkAndUpdate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Flutter Custom Updater Demo'), centerTitle: true),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.system_update, size: 100, color: Theme.of(context).primaryColor),
              SizedBox(height: 40),
              Text('Flutter Custom Updater', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              Text('Cross-Platform App Updates', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
              SizedBox(height: 40),
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue.shade200, width: 2),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Platform.isAndroid ? Icons.android : Icons.apple, color: Colors.blue.shade700, size: 28),
                        SizedBox(width: 12),
                        Text(
                          Platform.isAndroid ? 'Android (APK)' : 'iOS (IPA)',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue.shade700),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        _updateStatus,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 50),
              ElevatedButton.icon(
                onPressed: _checkForUpdates,
                icon: Icon(Icons.refresh, size: 24),
                label: Text('Check for Updates', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              SizedBox(height: 30),
              Text(
                'Version $_appVersion${_buildNumber.isNotEmpty ? ' ($_buildNumber)' : ''}',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
