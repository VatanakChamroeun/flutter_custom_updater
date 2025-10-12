#!/bin/bash

# Make script executable: chmod +x start.sh

echo "🚀 Starting Mock Update Server..."
echo ""

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
    echo "📦 Installing dependencies first..."
    npm install
    echo ""
fi

# Start server
node server.js