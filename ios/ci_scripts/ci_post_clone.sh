#!/bin/sh
set -e
set -x

echo "=== Installing Flutter ==="
git clone https://github.com/flutter/flutter.git -b stable --depth 1 $HOME/flutter
export PATH="$PATH:$HOME/flutter/bin"

cd $CI_PRIMARY_REPOSITORY_PATH

echo "=== Flutter pub get ==="
flutter pub get

echo "=== Generating FlutterGeneratedPluginSwiftPackage ==="
flutter build ios --config-only --no-codesign

echo "=== Done ==="