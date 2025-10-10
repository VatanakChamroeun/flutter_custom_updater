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
      hasUpdate: json['hasUpdate'] ?? false,
      version: json['version'],
      downloadUrl: json['downloadUrl'] ?? '',
      fileName: json['fileName'],
      releaseNotes: json['releaseNotes'],
      forceUpdate: json['forceUpdate'] ?? false,
      fileSize: json['fileSize'],
      iosManifestUrl: json['iosManifestUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hasUpdate': hasUpdate,
      'version': version,
      'downloadUrl': downloadUrl,
      'fileName': fileName,
      'releaseNotes': releaseNotes,
      'forceUpdate': forceUpdate,
      'fileSize': fileSize,
      'iosManifestUrl': iosManifestUrl,
    };
  }
}
