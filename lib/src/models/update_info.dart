class UpdateInfo {
  final bool hasUpdate;
  final String? version;
  final String downloadUrl;
  final String? fileName;
  final String? releaseNotes;
  final bool? forceUpdate;
  final int? fileSize;

  // iOS specific field - URL to manifest.plist for enterprise distribution
  final String? iosManifestUrl;

  UpdateInfo({
    required this.hasUpdate,
    this.version,
    required this.downloadUrl,
    this.fileName,
    this.releaseNotes,
    this.forceUpdate,
    this.fileSize,
    this.iosManifestUrl,
  });

  factory UpdateInfo.fromJson(Map<String, dynamic> json) {
    return UpdateInfo(
      hasUpdate: json['has_update'] ?? false,
      version: json['version'],
      downloadUrl: json['download_url'] ?? '',
      fileName: json['file_name'],
      releaseNotes: json['release_notes'],
      forceUpdate: json['force_update'] ?? false,
      fileSize: json['file_size'],
      iosManifestUrl: json['ios_manifest_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'has_update': hasUpdate,
      'version': version,
      'download_url': downloadUrl,
      'file_name': fileName,
      'release_notes': releaseNotes,
      'force_update': forceUpdate,
      'file_size': fileSize,
      'ios_manifest_url': iosManifestUrl,
    };
  }
}
