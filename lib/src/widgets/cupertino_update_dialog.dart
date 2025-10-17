import 'dart:io';

import 'package:flutter/cupertino.dart';

import '../models/update_info.dart';
import '../models/updater_config.dart';

class CupertinoUpdateDialog extends StatelessWidget {
  final UpdateInfo updateInfo;
  final UpdaterConfig config;

  const CupertinoUpdateDialog({
    super.key,
    required this.updateInfo,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    final forceUpdate = updateInfo.forceUpdate ?? false;

    return PopScope(
      canPop: !forceUpdate && config.allowDismiss,
      child: CupertinoAlertDialog(
        title: Text(
          config.dialogTitle ?? 'Update Available',
          style:
              config.dialogTitleStyle ??
              const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 12.0),
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
                    color: CupertinoColors.systemBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Version ${updateInfo.version}',
                    style: const TextStyle(
                      color: CupertinoColors.systemBlue,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (updateInfo.releaseNotes != null) ...[
                Text(
                  updateInfo.releaseNotes!,
                  textAlign: TextAlign.left,
                  style:
                      config.dialogContentStyle ??
                      const TextStyle(fontSize: 13, height: 1.4),
                ),
              ] else ...[
                Text(
                  config.dialogContent ??
                      'A new version is available. Would you like to update now?',
                  style:
                      config.dialogContentStyle ??
                      const TextStyle(fontSize: 13, height: 1.4),
                ),
              ],
              if (updateInfo.fileSize != null && Platform.isAndroid) ...[
                const SizedBox(height: 8),
                Text(
                  'Size: ${_formatFileSize(updateInfo.fileSize!)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          if (!forceUpdate)
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                config.laterButtonText ?? 'Later',
                style: config.buttonTextStyle,
              ),
            ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              config.updateButtonText ?? 'Update Now',
              style:
                  config.buttonTextStyle ??
                  const TextStyle(fontWeight: FontWeight.w600),
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
