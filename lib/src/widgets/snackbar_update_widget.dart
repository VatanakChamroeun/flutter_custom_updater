import 'dart:io';

import 'package:flutter/material.dart';

import '../models/update_info.dart';
import '../models/updater_config.dart';

class SnackbarUpdateWidget extends StatelessWidget {
  final UpdateInfo updateInfo;
  final UpdaterConfig config;
  final VoidCallback onUpdate;
  final VoidCallback? onDismiss;

  const SnackbarUpdateWidget({
    super.key,
    required this.updateInfo,
    required this.config,
    required this.onUpdate,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final forceUpdate = updateInfo.forceUpdate ?? false;

    final primaryColor =
        config.snackbarIconColor ?? Theme.of(context).primaryColor;

    final hasReleaseNotes =
        updateInfo.releaseNotes != null &&
        updateInfo.releaseNotes!.trim().isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 32),
      decoration: BoxDecoration(
        color: config.snackbarBackgroundColor ?? Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Update Icon
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.system_update_alt,
                      color: primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Title and Version
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          config.dialogTitle ?? 'Update Available',
                          style:
                              config.dialogTitleStyle ??
                              const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        if (updateInfo.version != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Version ${updateInfo.version}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Close button (only if not force update)
                  if (!forceUpdate && onDismiss != null)
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      color: Colors.grey.shade600,
                      onPressed: onDismiss,
                      padding: EdgeInsets.zero,
                      // constraints: const BoxConstraints(),
                    ),
                ],
              ),

              // Release notes (only if provided)
              if (hasReleaseNotes) ...[
                const SizedBox(height: 12),
                Container(
                  constraints: const BoxConstraints(maxHeight: 150),
                  child: SingleChildScrollView(
                    child: Text(
                      updateInfo.releaseNotes!,
                      style:
                          config.dialogContentStyle ??
                          TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                            height: 1.4,
                          ),
                    ),
                  ),
                ),
              ] else if (config.snackbarDescription != null ||
                  config.dialogContent != null) ...[
                // Fallback description (only if release notes not provided)
                const SizedBox(height: 12),
                Text(
                  config.snackbarDescription ??
                      config.dialogContent ??
                      'A new version is available',
                  style:
                      config.dialogContentStyle ??
                      TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // File size (only if available and Android)
              if (updateInfo.fileSize != null && Platform.isAndroid) ...[
                const SizedBox(height: 8),
                Text(
                  'Size: ${_formatFileSize(updateInfo.fileSize!)}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],

              const SizedBox(height: 16),
              // Buttons
              Row(
                children: [
                  if (!forceUpdate) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onDismiss,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          config.laterButtonText ?? 'Later',
                          style:
                              config.buttonTextStyle ??
                              TextStyle(
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    flex: forceUpdate ? 1 : 1,
                    child: ElevatedButton(
                      onPressed: onUpdate,
                      style:
                          config.updateButtonStyle ??
                          ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                      child: Text(
                        config.updateButtonText ?? 'Update Now',
                        style:
                            config.buttonTextStyle ??
                            const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
