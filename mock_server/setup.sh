#!/bin/bash

echo "🚀 Setting up Mock Update Server..."

# Create necessary directories
mkdir -p downloads
mkdir -p ios

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed!"
    echo "Please install Node.js from https://nodejs.org/"
    exit 1
fi

echo "✅ Node.js found: $(node --version)"

# Install dependencies
echo "📦 Installing dependencies..."
npm install

# Check if APK exists
if [ ! -f "downloads/app-v1.2.3.apk" ]; then
    echo "⚠️  No APK file found in downloads/"
    echo "Please copy your APK file to downloads/app-v1.2.3.apk"
    echo ""
    echo "Example:"
    echo "  cp ../example/build/app/outputs/flutter-apk/app-release.apk downloads/app-v1.2.3.apk"
fi

echo ""
echo "✅ Setup complete!"
echo ""
echo "To start the server, run:"
echo "  npm start"
echo ""