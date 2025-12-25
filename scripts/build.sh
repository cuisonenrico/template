#!/bin/bash

# Build Flutter app with build flavors
# Usage: ./scripts/build.sh [development|staging|production] [platform]

FLAVOR=${1:-production}
PLATFORM=${2:-apk}

echo "🏗️  Building app for $PLATFORM with $FLAVOR flavor..."

# Determine target file
case $FLAVOR in
  development)
    TARGET="lib/main.dart"
    ;;
  staging)
    TARGET="lib/main_staging.dart"
    ;;
  production)
    TARGET="lib/main_production.dart"
    ;;
  *)
    echo "Unknown flavor: $FLAVOR"
    echo "Usage: ./scripts/build.sh [development|staging|production] [platform]"
    exit 1
    ;;
esac

# Build for platform
case $PLATFORM in
  apk)
    flutter build apk \
      --flavor $FLAVOR \
      --target $TARGET \
      --dart-define-from-file=.env.$FLAVOR
    ;;
  appbundle)
    flutter build appbundle \
      --flavor $FLAVOR \
      --target $TARGET \
      --dart-define-from-file=.env.$FLAVOR
    ;;
  ios)
    flutter build ios \
      --flavor $FLAVOR \
      --target $TARGET \
      --dart-define-from-file=.env.$FLAVOR
    ;;
  web)
    flutter build web \
      --target $TARGET \
      --dart-define-from-file=.env.$FLAVOR
    ;;
  windows)
    flutter build windows \
      --target $TARGET \
      --dart-define-from-file=.env.$FLAVOR
    ;;
  macos)
    flutter build macos \
      --target $TARGET \
      --dart-define-from-file=.env.$FLAVOR
    ;;
  linux)
    flutter build linux \
      --target $TARGET \
      --dart-define-from-file=.env.$FLAVOR
    ;;
  *)
    echo "Unknown platform: $PLATFORM"
    echo "Supported: apk, appbundle, ios, web, windows, macos, linux"
    exit 1
    ;;
esac

echo "✅ Build complete!"
echo "Flavor: $FLAVOR"
echo "Platform: $PLATFORM"
echo "Target: $TARGET"
