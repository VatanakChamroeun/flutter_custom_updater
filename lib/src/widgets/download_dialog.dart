import 'package:flutter/material.dart';
import '../models/updater_config.dart';

class DownloadDialog extends StatelessWidget {
  final UpdaterConfig config;

  const DownloadDialog({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 20),
            Expanded(child: Text(config.downloadingText ?? 'Downloading update...', style: config.dialogContentStyle)),
          ],
        ),
      ),
    );
  }
}
