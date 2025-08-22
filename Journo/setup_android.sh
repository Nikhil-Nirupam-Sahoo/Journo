#!/bin/bash

# Set up Android SDK environment
export ANDROID_HOME="$HOME/Android"
export ANDROID_SDK_ROOT="$HOME/Android"
export PATH="$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools"

# Set up Flutter path
export PATH="$HOME/flutter/bin:$PATH"

echo "Android SDK Root: $ANDROID_SDK_ROOT"
echo "Flutter path: $HOME/flutter/bin"

# Check if sdkmanager is available
if command -v sdkmanager &> /dev/null; then
    echo "✓ sdkmanager found"
else
    echo "✗ sdkmanager not found"
    exit 1
fi

# Check if flutter is available
if command -v flutter &> /dev/null; then
    echo "✓ Flutter found"
else
    echo "✗ Flutter not found"
    exit 1
fi

echo "Environment setup complete!"
echo "You can now run: flutter build apk --debug"