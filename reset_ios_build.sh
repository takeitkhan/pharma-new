#!/bin/bash
# ============================================
# Flutter iOS full cleanup + Firebase pod fix
# ============================================
set -e

echo "🚀 Starting full iOS rebuild + Firebase cleanup..."

# Step 1: Flutter clean
echo "🧹 Cleaning Flutter build artifacts..."
flutter clean

# Step 2: Remove Flutter cache (optional but useful if weird issues persist)
echo "🗑️  Clearing Flutter pub cache (optional, can skip if slow)..."
flutter pub cache repair || true

# Step 3: Get fresh dependencies
echo "📦 Running flutter pub get..."
flutter pub get

# Step 4: iOS cleanup
echo "🧼 Cleaning iOS project files..."
cd ios

# Remove all derived data and build artifacts
rm -rf Pods Podfile.lock Runner.xcworkspace
rm -rf ~/Library/Developer/Xcode/DerivedData/*

# Step 5: Remove Flutter and plugin symlink caches
echo "🧩 Removing plugin symlinks and Firebase cache..."
rm -rf .symlinks
rm -rf Flutter/Flutter.framework
rm -rf Flutter/Flutter.podspec
rm -rf Flutter/Generated.xcconfig
rm -rf Flutter/ephemeral

# Step 6: Reinstall CocoaPods
echo "🔄 Updating local CocoaPods repo..."
pod repo update

echo "🧰 Deintegrating and reinstalling Pods..."
pod deintegrate
pod install

# Step 7: Confirm success
echo "✅ iOS environment cleaned and rebuilt!"

echo ""
echo "👉 Next steps:"
echo "   1. Open Xcode workspace:"
echo "        open Runner.xcworkspace"
echo "   2. In Xcode: Select your real device, then press Cmd + R to build once."
echo "   3. Then run from CLI again:"
echo "        cd .. && flutter run"
echo ""
echo "💡 Tip: If Firebase pods fail to install, try running 'pod setup' once."
