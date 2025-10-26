const express = require('express');
const cors = require('cors');
const path = require('path');
const fs = require('fs');

const app = express();
const PORT = 3000;

// Enable CORS for Flutter app
app.use(cors());

// Parse JSON bodies
app.use(express.json());

// Serve static files (APK and IPA files)
app.use('/downloads', express.static(path.join(__dirname, 'downloads')));

// Serve manifest.plist for iOS
app.use('/ios', express.static(path.join(__dirname, 'ios')));

const RELEASE_NOTES = {
  en: {
    android: '🚀 New Features:\n- Bug fixes\n- Performance improvements\n- New UI enhancements',
    ios: '🍎 iOS Update:\n- Bug fixes\n- Performance improvements\n- New features'
  },
  km: {
    android: '🚀 មុខងារថ្មី:\n- ជួសជុលកំហុស\n- បង្កើនប្រសិទ្ធភាព\n- ការកែលម្អ UI ថ្មី',
    ios: '🍎 ធ្វើបច្ចុប្បន្នភាព iOS:\n- ជួសជុលកំហុស\n- បង្កើនប្រសិទ្ធភាព\n- មុខងារថ្មី'
  },
  zh: {
    android: '🚀 新功能:\n- 错误修复\n- 性能改进\n- 新的界面增强',
    ios: '🍎 iOS 更新:\n- 错误修复\n- 性能改进\n- 新功能'
  }
};

/**
 * Get localized release notes based on language
 * @param {string} language - Language code (e.g., 'en', 'km', 'zh')
 * @param {string} platform - Platform ('android' or 'ios')
 * @returns {string} Localized release notes
 */
function getLocalizedReleaseNotes(language, platform) {
  // Normalize language code (take first 2 characters, lowercase)
  const langCode = (language || 'en').toLowerCase().substring(0, 2);
  
  // Check if we have translations for this language
  const notes = RELEASE_NOTES[langCode];
  
  if (notes && notes[platform]) {
    console.log(`   📝 Using ${langCode} release notes`);
    return notes[platform];
  }
  
  // Fallback to English
  console.log(`   📝 Using English release notes (fallback)`);
  return RELEASE_NOTES.en[platform];
}

// Logging middleware
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
  console.log('Headers:', {
    'current-version': req.headers['current-version'],
    'platform': req.headers['platform'],
    'accept-language': req.headers['accept-language']
  });
  next();
});

// API endpoint to check for updates
app.get('/api/check-update', (req, res) => {
  const currentVersion = req.headers['current-version'] || '0.0.0';
  const platform = req.headers['platform'] || 'unknown';
  const language = req.headers['accept-language'] || 'en';
  
  console.log(`\n📱 Update check from ${platform} - Current version: ${currentVersion}`);
  console.log(`   🌐 Language: ${language}`);
  
  const latestVersion = '1.2.3';
  const hasUpdate = compareVersions(latestVersion, currentVersion) > 0;
  
  if (!hasUpdate) {
    console.log('✅ No update needed');
    return res.json({
      has_update: false
    });
  }
  
  console.log('🆕 Update available!');
  
  // Get server URL (works with local IP and localhost)
  const protocol = req.protocol;
  const host = req.get('host');
  const baseUrl = `${protocol}://${host}`;
  
  if (platform === 'android') {
    // Android response
    const apkFileName = 'app-v1.2.3.apk';
    const apkPath = path.join(__dirname, 'downloads', apkFileName);
    
    // Get file size if file exists
    let fileSize = 0;
    if (fs.existsSync(apkPath)) {
      fileSize = fs.statSync(apkPath).size;
    }
    
    res.json({
      has_update: true,
      version: latestVersion,
      download_url: `${baseUrl}/downloads/${apkFileName}`,
      file_name: apkFileName,
      release_notes: getLocalizedReleaseNotes(language, 'android'),
      force_update: false,
      file_size: fileSize
    });
  } else if (platform === 'ios') {
    // iOS response
    res.json({
      has_update: true,
      version: latestVersion,
      download_url: `${baseUrl}/ios/manifest.plist`,
      ios_manifest_url: `${baseUrl}/ios/manifest.plist`,
      release_notes: getLocalizedReleaseNotes(language, 'ios'),
      force_update: false
    });
  } else {
    // Unknown platform
    res.json({
      has_update: false,
      error: 'Unknown platform'
    });
  }
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    message: 'Mock Update Server is running',
    supported_languages: Object.keys(RELEASE_NOTES),
    endpoints: {
      check_update: '/api/check-update',
      android_download: '/downloads/app-v1.2.3.apk',
      ios_manifest: '/ios/manifest.plist'
    }
  });
});

// Compare versions (simple implementation)
function compareVersions(v1, v2) {
  const parts1 = v1.split('.').map(Number);
  const parts2 = v2.split('.').map(Number);
  
  for (let i = 0; i < Math.max(parts1.length, parts2.length); i++) {
    const part1 = parts1[i] || 0;
    const part2 = parts2[i] || 0;
    
    if (part1 > part2) return 1;
    if (part1 < part2) return -1;
  }
  
  return 0;
}

// Start server
app.listen(PORT, '0.0.0.0', () => {
  const networkInterfaces = require('os').networkInterfaces();
  const addresses = [];
  
  for (const interfaceName in networkInterfaces) {
    for (const iface of networkInterfaces[interfaceName]) {
      if (iface.family === 'IPv4' && !iface.internal) {
        addresses.push(iface.address);
      }
    }
  }
  
  console.log('\n🚀 Mock Update Server Started!\n');
  console.log('📍 Server is running on:');
  console.log(`   - Local:   http://localhost:${PORT}`);
  addresses.forEach(addr => {
    console.log(`   - Network: http://${addr}:${PORT}`);
  });
  console.log('\n📋 Available endpoints:');
  console.log(`   - Health Check:  http://localhost:${PORT}/health`);
  console.log(`   - Update Check:  http://localhost:${PORT}/api/check-update`);
  console.log(`   - Android APK:   http://localhost:${PORT}/downloads/app-v1.2.3.apk`);
  console.log(`   - iOS Manifest:  http://localhost:${PORT}/ios/manifest.plist`);
  console.log(`\n🌐 Supported languages: ${Object.keys(RELEASE_NOTES).join(', ')}`);
  console.log('\n💡 Use the Network URL in your Flutter app for testing on physical devices\n');
});