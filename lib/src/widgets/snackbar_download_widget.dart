import 'package:flutter/material.dart';

import '../models/updater_config.dart';

class SnackbarDownloadWidget extends StatelessWidget {
  final UpdaterConfig config;

  const SnackbarDownloadWidget({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    final primaryColor = config.snackbarIconColor ?? Theme.of(context).primaryColor;

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
          child: Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  config.downloadingText ?? 'Downloading update...',
                  style:
                      config.dialogContentStyle ??
                      const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
