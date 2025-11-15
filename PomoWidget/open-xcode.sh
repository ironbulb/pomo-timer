#!/bin/bash
# Open Xcode with clean environment (no conda)
cd "$(dirname "$0")"
env -i PATH="/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin" HOME="$HOME" /Applications/Xcode.app/Contents/MacOS/Xcode PomoWidget/PomoWidget.xcodeproj &
