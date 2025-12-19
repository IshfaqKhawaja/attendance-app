#!/bin/bash
# Flutter app release build script

set -e

echo "========================================="
echo "Building Attendance App - Release"
echo "========================================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}Error: Flutter is not installed!${NC}"
    exit 1
fi

# Clean previous builds
echo -e "${YELLOW}Cleaning previous builds...${NC}"
flutter clean

# Get dependencies
echo -e "${YELLOW}Getting dependencies...${NC}"
flutter pub get

# Run code generation if needed
if grep -q "build_runner" pubspec.yaml; then
    echo -e "${YELLOW}Running code generation...${NC}"
    flutter pub run build_runner build --delete-conflicting-outputs
fi

# Build for Android
if [[ "$1" == "android" ]] || [[ "$1" == "all" ]] || [[ -z "$1" ]]; then
    echo -e "${YELLOW}Building Android APK...${NC}"
    flutter build apk --release --flavor production --dart-define=FLAVOR=production

    echo -e "${YELLOW}Building Android App Bundle...${NC}"
    flutter build appbundle --release --flavor production --dart-define=FLAVOR=production

    echo -e "${GREEN}✓${NC} Android builds completed!"
    echo "APK: build/app/outputs/flutter-apk/app-production-release.apk"
    echo "AAB: build/app/outputs/bundle/productionRelease/app-production-release.aab"
fi

# Build for iOS
if [[ "$1" == "ios" ]] || [[ "$1" == "all" ]]; then
    echo -e "${YELLOW}Building iOS...${NC}"
    flutter build ios --release --flavor production --dart-define=FLAVOR=production

    echo -e "${GREEN}✓${NC} iOS build completed!"
    echo "Open Xcode to archive and upload to App Store"
fi

# Build for Web
if [[ "$1" == "web" ]] || [[ "$1" == "all" ]]; then
    echo -e "${YELLOW}Building Web...${NC}"
    flutter build web --release --dart-define=FLAVOR=production --base-href=/webapp/

    echo -e "${GREEN}✓${NC} Web build completed!"
    echo "Web build: build/web/"
    echo ""
    echo "To deploy, copy build/web/* to backend/webapp/"
fi

echo ""
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}Build completed successfully!${NC}"
echo -e "${GREEN}=========================================${NC}"
