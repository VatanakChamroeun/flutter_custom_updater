import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

import 'models/update_info.dart';
import 'models/updater_config.dart';
import 'widgets/download_dialog.dart';
import 'widgets/update_dialog.dart';

class AppUpdater {
  final BuildContext context;
  final UpdaterConfig config;

  AppUpdater({required this.context, required this.config});

  /// Main method to check and update app (works for both Android & iOS)
  Future<void> checkAndUpdate() async {
    try {
      // Get current version
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentVersion = packageInfo.version;

      // Check for updates
      UpdateInfo? updateInfo = await _checkForUpdate(currentVersion);

      if (updateInfo != null && updateInfo.hasUpdate) {
        // Show update dialog
        bool? shouldUpdate = await _showUpdateDialog(updateInfo);

        if (shouldUpdate == true) {
          if (Platform.isAndroid) {
            await _downloadAndInstallApk(updateInfo);
          } else if (Platform.isIOS) {
            await _handleIosUpdate(updateInfo);
          }
        }
      } else {
        if (config.onNoUpdateAvailable != null) {
          config.onNoUpdateAvailable!();
        }
      }
    } catch (e) {
      if (config.onError != null) {
        config.onError!(e.toString());
      }
      debugPrint('AppUpdater Error: $e');
    }
  }

  /// Check for update from server
  Future<UpdateInfo?> _checkForUpdate(String currentVersion) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        'Current-Version': currentVersion,
        'Platform': Platform.isAndroid ? 'android' : 'ios',
        ...?config.customHeaders,
      };

      final response = await http
          .get(Uri.parse(config.updateCheckUrl), headers: headers)
          .timeout(config.timeout, onTimeout: () => throw Exception('Connection timeout'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return UpdateInfo.fromJson(data);
      } else {
        throw Exception('Failed to check update: ${response.statusCode}');
      }
    } catch (e) {
      if (config.onError != null) {
        config.onError!('Failed to check for updates: $e');
      }
      rethrow;
    }
  }

  /// Show update dialog
  Future<bool?> _showUpdateDialog(UpdateInfo updateInfo) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: config.allowDismiss && !(updateInfo.forceUpdate ?? false),
      builder: (BuildContext context) {
        return UpdateDialog(updateInfo: updateInfo, config: config);
      },
    );
  }

  /// Download and install APK (Android)
  Future<void> _downloadAndInstallApk(UpdateInfo updateInfo) async {
    try {
      // Show download dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => DownloadDialog(config: config),
      );

      // Download APK
      final response = await http
          .get(Uri.parse(updateInfo.downloadUrl))
          .timeout(config.downloadTimeout, onTimeout: () => throw Exception('Download timeout'));

      if (response.statusCode == 200) {
        // Save to storage
        final directory = await getExternalStorageDirectory();
        final fileName = updateInfo.fileName ?? 'app_update.apk';
        final filePath = '${directory!.path}/$fileName';

        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        // Close download dialog
        Navigator.of(context).pop();

        // Notify success callback
        if (config.onDownloadComplete != null) {
          config.onDownloadComplete!(filePath);
        }

        // Install APK
        await _installApk(filePath);
      } else {
        Navigator.of(context).pop();
        throw Exception('Download failed: ${response.statusCode}');
      }
    } catch (e) {
      Navigator.of(context).pop();
      if (config.onError != null) {
        config.onError!('Download failed: $e');
      }
      _showErrorDialog('Failed to download update: $e');
    }
  }

  /// Install APK (Android)
  Future<void> _installApk(String filePath) async {
    try {
      final result = await OpenFilex.open(filePath);

      if (result.type != ResultType.done) {
        if (config.onError != null) {
          config.onError!('Installation failed: ${result.message}');
        }
        _showErrorDialog('Failed to install: ${result.message}');
      } else {
        if (config.onInstallStart != null) {
          config.onInstallStart!();
        }
      }
    } catch (e) {
      if (config.onError != null) {
        config.onError!('Installation error: $e');
      }
      _showErrorDialog('Installation error: $e');
    }
  }

  /// Handle iOS update (Enterprise Distribution)
  Future<void> _handleIosUpdate(UpdateInfo updateInfo) async {
    try {
      await _installEnterpriseIpa(updateInfo);
    } catch (e) {
      if (config.onError != null) {
        config.onError!('iOS update failed: $e');
      }
      _showErrorDialog('Update failed: $e');
    }
  }

  /// Install Enterprise IPA using itms-services
  Future<void> _installEnterpriseIpa(UpdateInfo updateInfo) async {
    // Show progress dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text(
              config.iosInstallText ?? 'Preparing installation...\nPlease follow the system prompts.',
              textAlign: TextAlign.center,
              style: config.dialogContentStyle,
            ),
          ],
        ),
      ),
    );

    // Construct itms-services URL
    // The manifest URL should point to a .plist file on HTTPS server
    final manifestUrl = updateInfo.iosManifestUrl ?? updateInfo.downloadUrl;
    final itmsUrl = 'itms-services://?action=download-manifest&url=$manifestUrl';

    final uri = Uri.parse(itmsUrl);

    // Small delay to show the dialog
    await Future.delayed(Duration(seconds: 1));

    // Close dialog
    Navigator.of(context).pop();

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (config.onInstallStart != null) {
        config.onInstallStart!();
      }
    } else {
      throw Exception(
        'Could not launch installation. Please ensure the manifest URL is correct and accessible via HTTPS.',
      );
    }
  }

  /// Show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(config.errorTitle ?? 'Error', style: config.dialogTitleStyle),
        content: Text(message, style: config.dialogContentStyle),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(config.okButtonText ?? 'OK', style: config.buttonTextStyle),
          ),
        ],
      ),
    );
  }
}
