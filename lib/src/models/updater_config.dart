import 'package:flutter/material.dart';
import 'package:flutter_custom_updater/src/models/dialog_style.dart';

class UpdaterConfig {
  // Dialog Style
  final DialogStyle dialogStyle;

  /// Required: URL to check for updates
  final String updateCheckUrl;

  /// Custom headers for API requests
  final Map<String, String>? customHeaders;

  /// Language code for localized update content (e.g., 'en', 'km', 'zh', 'ja')
  /// If null, will use device's system language automatically
  /// Default: null (auto-detect from device)
  final String? language;

  /// Timeout for update check request
  final Duration timeout;

  /// Timeout for APK download (Android) / manifest fetch (iOS)
  final Duration downloadTimeout;

  /// Allow user to dismiss update dialog
  final bool allowDismiss;

  /// iOS Configuration
  final String? iosInstallText; // Custom text shown during iOS installation

  /// Dialog customization
  final String? dialogTitle;
  final String? dialogContent;
  final String? updateButtonText;
  final String? laterButtonText;
  final String? downloadingText;
  final String? errorTitle;
  final String? okButtonText;

  // Snackbar style properties
  final Color? snackbarBackgroundColor;
  final Color? snackbarIconColor;
  final String? snackbarDescription;

  /// Text styles
  final TextStyle? dialogTitleStyle;
  final TextStyle? dialogContentStyle;
  final TextStyle? buttonTextStyle;

  /// Button styles
  final ButtonStyle? updateButtonStyle;
  final ButtonStyle? laterButtonStyle;

  /// Callbacks
  final Function()? onNoUpdateAvailable;
  final Function(String)? onError;
  final Function(String)? onDownloadComplete;
  final Function()? onInstallStart;

  UpdaterConfig({
    this.dialogStyle = DialogStyle.material, // default to material
    required this.updateCheckUrl,
    this.customHeaders,
    this.timeout = const Duration(seconds: 30),
    this.downloadTimeout = const Duration(minutes: 5),
    this.allowDismiss = false,
    this.language,
    this.iosInstallText,
    this.dialogTitle,
    this.dialogContent,
    this.updateButtonText,
    this.laterButtonText,
    this.downloadingText,
    this.errorTitle,
    this.okButtonText,
    this.dialogTitleStyle,
    this.dialogContentStyle,
    this.buttonTextStyle,
    this.updateButtonStyle,
    this.laterButtonStyle,
    this.onNoUpdateAvailable,
    this.onError,
    this.onDownloadComplete,
    this.onInstallStart,
    this.snackbarBackgroundColor,
    this.snackbarIconColor,
    this.snackbarDescription,
  });
}
