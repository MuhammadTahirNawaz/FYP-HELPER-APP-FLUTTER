#!/bin/bash
# Bash script to run Flutter app with environment variables from .env file
# Usage: ./run_app.sh [device|web|android] [--build]

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ENV_FILE="$SCRIPT_DIR/.env"

if [ ! -f "$ENV_FILE" ]; then
    echo "Error: .env file not found at $ENV_FILE"
    echo "Copy .env.example to .env and fill in your Firebase credentials"
    exit 1
fi

# Load .env file
set -a
source "$ENV_FILE"
set +a

# Validate required keys
for key in FIREBASE_WEB_API_KEY FIREBASE_ANDROID_API_KEY; do
    if [ -z "${!key}" ]; then
        echo "Error: Missing $key in .env file"
        exit 1
    fi
done

echo "✓ Loaded Firebase credentials from .env"

# Parse arguments
DEVICE="${1:-chrome}"
BUILD_MODE=false

if [ "$2" == "--build" ] || [ "$1" == "--build" ]; then
    BUILD_MODE=true
fi

# Build dart-define arguments
DART_DEFINE="--dart-define=FIREBASE_WEB_API_KEY=$FIREBASE_WEB_API_KEY"
DART_DEFINE="$DART_DEFINE --dart-define=FIREBASE_ANDROID_API_KEY=$FIREBASE_ANDROID_API_KEY"

# Build flutter command
if [ "$BUILD_MODE" = true ]; then
    FLUTTER_CMD="flutter build apk $DART_DEFINE"
else
    FLUTTER_CMD="flutter run -d $DEVICE $DART_DEFINE"
fi

echo "Running: $FLUTTER_CMD"
eval "$FLUTTER_CMD"
