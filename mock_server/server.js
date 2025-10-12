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

// Logging middleware
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
  console.log('Headers:', {
    'current-version': req.headers['current-version'],
    'platform': req.headers['platform']
  });
  next();
});

// API endpoint to check for updates
app.get('/api/check-update', (req, res) => {
  const currentVersion = req.headers['current-version'] || '0.0.0';
  const platform = req.headers['platform'] || 'unknown';
  
  console.log(`\n📱 Update check from ${platform} - Current version: ${currentVersion}`);
  
  const latestVersion = '1.2.3';
  const hasUpdate = compareVersions(latestVersion, currentVersion) > 0;
  
  if (!hasUpdate) {
    console.log('✅ No update needed');
    return res.json({
      hasUpdate: false
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
      hasUpdate: true,
      version: latestVersion,
      downloadUrl: `${baseUrl}/downloads/${apkFileName}`,
      fileName: apkFileName,
      releaseNotes: '🚀 New Features:\n- Bug fixes\n- Performance improvements\n- New UI enhancements',
      forceUpdate: false,
      fileSize: fileSize
    });
  } else if (platform === 'ios') {
    // iOS response
    res.json({
      hasUpdate: true,
      version: latestVersion,
      downloadUrl: `${baseUrl}/ios/manifest.plist`,
      iosManifestUrl: `${baseUrl}/ios/manifest.plist`,
      releaseNotes: '🍎 iOS Update:\n- Bug fixes\n- Performance improvements\n- New features',
      forceUpdate: false
    });
  } else {
    // Unknown platform
    res.json({
      hasUpdate: false,
      error: 'Unknown platform'
    });
  }
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    message: 'Mock Update Server is running',
    endpoints: {
      checkUpdate: '/api/check-update',
      androidDownload: '/downloads/app-v1.2.3.apk',
      iosManifest: '/ios/manifest.plist'
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
  console.log('\n💡 Use the Network URL in your Flutter app for testing on physical devices\n');
});