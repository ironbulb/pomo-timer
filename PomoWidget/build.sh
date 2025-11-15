#!/bin/bash

# Clear conda environment from PATH to avoid linker conflicts
export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/Applications/Xcode.app/Contents/Developer/usr/bin"

cd "$(dirname "$0")/PomoWidget"

echo "Building PomoWidget..."
xcodebuild -scheme PomoWidget -configuration Debug clean build

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Build successful!"
    echo ""
    echo "To run the app:"
    echo "open ~/Library/Developer/Xcode/DerivedData/PomoWidget-*/Build/Products/Debug/PomoWidget.app"
else
    echo ""
    echo "❌ Build failed"
fi
