import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_custom_updater/flutter_custom_updater.dart';
import 'package:http/http.dart' as http;
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
  String _latestVersion = '...';
  bool _hasUpdate = false;

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkForUpdates());
  }

  // ============================================================================
  // Version Management
  // ============================================================================

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = packageInfo.version;
        _buildNumber = packageInfo.buildNumber;
      });
    } catch (e) {
      setState(() => _appVersion = 'Unknown');
    }
  }

  // ============================================================================
  // Update Logic
  // ============================================================================

  String _getServerUrl() {
    // Android Emulator uses 10.0.2.2 to access host's localhost
    // iOS Simulator can use localhost directly
    return Platform.isAndroid
        ? 'http://10.0.2.2:3000/api/check-update'
        : 'http://localhost:3000/api/check-update';
  }

  Future<void> _checkForUpdates() async {
    _setCheckingState();

    try {
      final updateInfo = await _fetchUpdateInfo();
      _handleUpdateInfo(updateInfo);

      if (updateInfo.hasUpdate) {
        await _showUpdateDialog();
      }
    } catch (e) {
      _handleUpdateError(e);
    }
  }

  void _setCheckingState() {
    setState(() {
      _updateStatus = 'Checking for updates...';
      _latestVersion = '...';
      _hasUpdate = false;
    });
  }

  Future<UpdateInfo> _fetchUpdateInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;

    final response = await http
        .get(
          Uri.parse(_getServerUrl()),
          headers: {
            'current-version': currentVersion,
            'platform': Platform.isAndroid ? 'android' : 'ios',
          },
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw Exception('Server returned status code ${response.statusCode}');
    }

    final jsonResponse = json.decode(response.body);
    final responseData = jsonResponse['data'] ?? jsonResponse;
    
    return UpdateInfo(
      hasUpdate: responseData['has_update'] ?? false,
      version: responseData['version'] ?? _appVersion,
    );
  }

  void _handleUpdateInfo(UpdateInfo info) {
    setState(() {
      _latestVersion = info.version;
      _hasUpdate = info.hasUpdate;
      _updateStatus = info.hasUpdate
          ? '🆕 Update available!'
          : '✅ App is up to date';
    });
  }

  Future<void> _showUpdateDialog() async {
    final updater = AppUpdater(context: context, config: _buildUpdaterConfig());
    await updater.checkAndUpdate();
  }

  UpdaterConfig _buildUpdaterConfig() {
    return UpdaterConfig(
      dialogStyle: DialogStyle.snackbar,
      updateCheckUrl: _getServerUrl(),
      language: 'en', // your current app language
      dialogTitle: 'Update Available! 🚀',
      updateButtonText: 'Update Now',
      laterButtonText: 'Later',
      downloadingText: 'Downloading update...',
      iosInstallText:
          'Preparing installation...\nPlease follow the system prompts.',
      allowDismiss: true,
      onDownloadComplete: _onDownloadComplete,
      onInstallStart: _onInstallStart,
      onError: _onUpdateError,
    );
  }

  void _onDownloadComplete(String path) {
    setState(() => _updateStatus = '✅ Download complete');
  }

  void _onInstallStart() {
    setState(() => _updateStatus = '⚙️ Installing update...');
  }

  void _onUpdateError(String error) {
    setState(() => _updateStatus = '❌ Error occurred');
    _showErrorSnackBar('Update failed: $error');
  }

  void _handleUpdateError(Object error) {
    setState(() {
      _updateStatus = '❌ Connection failed';
      _latestVersion = 'Unknown';
    });
    _showErrorSnackBar('Update check failed: $error');
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // ============================================================================
  // UI Helpers
  // ============================================================================

  Color _getVersionColor() {
    if (_hasUpdate) return Colors.orange.shade700;
    if (_latestVersion == _appVersion && _latestVersion != '...') {
      return Colors.green.shade700;
    }
    return Colors.grey.shade700;
  }

  IconData _getStatusIcon() {
    if (_hasUpdate) return Icons.new_releases;
    if (_updateStatus.contains('✅')) return Icons.check_circle;
    return Icons.info_outline;
  }

  Color _getStatusIconColor() {
    if (_hasUpdate) return Colors.orange;
    if (_updateStatus.contains('✅')) return Colors.green;
    return Colors.grey;
  }

  // ============================================================================
  // Build Methods
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Custom Updater Demo'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildHeader(context),
              const SizedBox(height: 40),
              _buildPlatformInfoCard(),
              const SizedBox(height: 30),
              _buildVersionInfoCard(),
              const SizedBox(height: 40),
              _buildCheckUpdateButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.system_update_outlined,
          size: 100,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(height: 12),
        const Text(
          'Flutter Custom Updater',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          'Cross-Platform App Updates',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildPlatformInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200, width: 2),
      ),
      child: Column(
        children: [
          _buildPlatformHeader(),
          const SizedBox(height: 16),
          _buildStatusIndicator(),
        ],
      ),
    );
  }

  Widget _buildPlatformHeader() {
    final isAndroid = Platform.isAndroid;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isAndroid ? Icons.android : Icons.apple,
          color: Colors.blue.shade700,
          size: 28,
        ),
        const SizedBox(width: 12),
        Text(
          isAndroid ? 'Android (APK)' : 'iOS (IPA)',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.blue.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusIndicator() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getStatusIcon(), size: 18, color: _getStatusIconColor()),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              _updateStatus,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          _buildCurrentVersionRow(),
          const SizedBox(height: 12),
          _buildDivider(),
          const SizedBox(height: 12),
          _buildLatestVersionRow(),
        ],
      ),
    );
  }

  Widget _buildCurrentVersionRow() {
    final versionText = _buildNumber.isNotEmpty
        ? '$_appVersion ($_buildNumber)'
        : _appVersion;

    return _buildVersionRow(
      icon: Icons.phone_android,
      label: 'Current:',
      version: versionText,
      color: Colors.grey.shade800,
    );
  }

  Widget _buildLatestVersionRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildVersionRow(
          icon: Icons.cloud_download,
          label: 'Latest:',
          version: _latestVersion,
          color: _getVersionColor(),
          iconColor: _getVersionColor(),
        ),
        if (_hasUpdate) ...[
          const SizedBox(width: 4),
          Icon(Icons.arrow_upward, size: 14, color: Colors.orange.shade700),
        ],
      ],
    );
  }

  Widget _buildVersionRow({
    required IconData icon,
    required String label,
    required String version,
    required Color color,
    Color? iconColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: iconColor ?? Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: Colors.grey.shade600)),
        const SizedBox(width: 8),
        Text(
          version,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(height: 1, width: 100, color: Colors.grey.shade300);
  }

  Widget _buildCheckUpdateButton() {
    return ElevatedButton.icon(
      onPressed: _checkForUpdates,
      icon: const Icon(Icons.refresh, size: 24),
      label: const Text('Check for Updates', style: TextStyle(fontSize: 18)),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// ============================================================================
// Data Models
// ============================================================================

class UpdateInfo {
  final bool hasUpdate;
  final String version;

  UpdateInfo({required this.hasUpdate, required this.version});
}
