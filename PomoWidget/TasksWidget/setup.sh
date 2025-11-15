#!/bin/bash

# TasksWidget Easy Setup Script
# This script builds your enhanced TasksWidget without manual Xcode configuration

set -e

echo "🚀 Setting up Enhanced TasksWidget..."
echo ""

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Xcode is not installed. Please install Xcode first."
    exit 1
fi

# Set the project directory
PROJECT_DIR="/Users/roitaitou/Alain/pomo/PomoWidget/TasksWidget"
cd "$PROJECT_DIR"

echo "✅ Found project directory"
echo ""

# Build the project
echo "🔨 Building TasksWidget..."
echo ""

# Use clean PATH to avoid conda conflicts
export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin"

# Build with xcodebuild
xcodebuild \
    -project TasksWidget/TasksWidget.xcodeproj \
    -scheme TasksWidget \
    -configuration Release \
    clean build \
    CODE_SIGN_IDENTITY="-" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Build succeeded!"
    echo ""

    # Find the built app
    APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "TasksWidget.app" -type d 2>/dev/null | head -n 1)

    if [ -n "$APP_PATH" ]; then
        echo "📦 App location: $APP_PATH"
        echo ""
        echo "🎉 To launch the widget, run:"
        echo "   open \"$APP_PATH\""
        echo ""

        # Ask if user wants to launch now
        read -p "Would you like to launch it now? (y/n) " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            open "$APP_PATH"
            echo "✨ TasksWidget launched!"
        fi
    else
        echo "⚠️  Could not find built app. You can open it manually from Xcode."
    fi
else
    echo ""
    echo "❌ Build failed. Opening Xcode for you to check errors..."
    open TasksWidget/TasksWidget.xcodeproj
fi
