#!/bin/bash

# Run Flutter app with build flavors
# Usage: ./scripts/run.sh [development|staging|production]

FLAVOR=${1:-development}

echo "🚀 Running app with $FLAVOR flavor..."

case $FLAVOR in
  development)
    flutter run \
      --flavor development \
      --target lib/main.dart \
      --dart-define-from-file=.env.development
    ;;
  staging)
    flutter run \
      --flavor staging \
      --target lib/main_staging.dart \
      --dart-define-from-file=.env.staging
    ;;
  production)
    flutter run \
      --release \
      --flavor production \
      --target lib/main_production.dart \
      --dart-define-from-file=.env.production
    ;;
  *)
    echo "Unknown flavor: $FLAVOR"
    echo "Usage: ./scripts/run.sh [development|staging|production]"
    exit 1
    ;;
esac
