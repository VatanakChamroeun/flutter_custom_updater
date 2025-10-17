import 'package:flutter/cupertino.dart';

import '../models/updater_config.dart';

class CupertinoDownloadDialog extends StatelessWidget {
  final UpdaterConfig config;

  const CupertinoDownloadDialog({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: CupertinoAlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CupertinoActivityIndicator(radius: 14),
            const SizedBox(height: 16),
            Text(
              config.downloadingText ?? 'Downloading update...',
              style: config.dialogContentStyle ?? const TextStyle(fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
