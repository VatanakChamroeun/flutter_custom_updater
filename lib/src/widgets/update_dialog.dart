import 'dart:io';

import 'package:flutter/material.dart';

import '../models/update_info.dart';
import '../models/updater_config.dart';

class UpdateDialog extends StatelessWidget {
  final UpdateInfo updateInfo;
  final UpdaterConfig config;

  const UpdateDialog({
    super.key,
    required this.updateInfo,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    final forceUpdate = updateInfo.forceUpdate ?? false;

    return PopScope(
      canPop: !forceUpdate && config.allowDismiss,
      child: AlertDialog(
        title: Text(
          config.dialogTitle ?? 'Update Available',
          style:
              config.dialogTitleStyle ??
              const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (updateInfo.version != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    'Version ${updateInfo.version}',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
              ],
              if (updateInfo.releaseNotes != null) ...[
                Text(
                  updateInfo.releaseNotes!,
                  style:
                      config.dialogContentStyle ??
                      const TextStyle(fontSize: 14, height: 1.5),
                ),
              ] else ...[
                Text(
                  config.dialogContent ??
                      'A new version is available. Would you like to update now?',
                  style:
                      config.dialogContentStyle ??
                      const TextStyle(fontSize: 14, height: 1.5),
                ),
              ],
              if (updateInfo.fileSize != null && Platform.isAndroid) ...[
                const SizedBox(height: 10),
                Text(
                  'Size: ${_formatFileSize(updateInfo.fileSize!)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ],
          ),
        ),
        actions: [
          if (!forceUpdate)
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: config.laterButtonStyle,
              child: Text(
                config.laterButtonText ?? 'Later',
                style: config.buttonTextStyle,
              ),
            ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: config.updateButtonStyle,
            child: Text(
              config.updateButtonText ?? 'Update Now',
              style: config.buttonTextStyle,
            ),
          ),
        ],
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
