#!/bin/bash

# SpotNav Flutter App Setup Script
echo "🚀 Setting up SpotNav Flutter App..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed. Please install Flutter first."
    echo "Visit: https://flutter.dev/docs/get-started/install"
    exit 1
fi

print_status "Flutter is installed"

# Check Flutter version
flutter --version

# Clean and get dependencies
print_status "Cleaning project..."
flutter clean

print_status "Getting dependencies..."
flutter pub get

# Check if firebase_options.dart exists
if [ ! -f "lib/firebase_options.dart" ]; then
    print_warning "Firebase configuration not found!"
    echo "Please run: flutterfire configure"
    echo "Make sure you have:"
    echo "1. Created a Firebase project"
    echo "2. Installed Firebase CLI: npm install -g firebase-tools"
    echo "3. Installed FlutterFire CLI: dart pub global activate flutterfire_cli"
fi

# Generate platform files if they don't exist
if [ ! -d "android" ]; then
    print_status "Generating Android platform files..."
    flutter create --platforms android .
fi

if [ ! -d "ios" ] && [[ "$OSTYPE" == "darwin"* ]]; then
    print_status "Generating iOS platform files..."
    flutter create --platforms ios .
fi

if [ ! -d "web" ]; then
    print_status "Generating Web platform files..."
    flutter create --platforms web .
fi

# Check for Google Services files
if [ ! -f "android/app/google-services.json" ]; then
    print_warning "Google Services file not found for Android!"
    echo "Please add google-services.json to android/app/"
fi

if [[ "$OSTYPE" == "darwin"* ]] && [ ! -f "ios/Runner/GoogleService-Info.plist" ]; then
    print_warning "Google Services file not found for iOS!"
    echo "Please add GoogleService-Info.plist to ios/Runner/"
fi

# Run flutter doctor
print_status "Running Flutter doctor..."
flutter doctor

print_status "Setup complete! 🎉"
echo ""
echo "Next steps:"
echo "1. Configure Firebase (if not done): flutterfire configure"
echo "2. Add Google Services files to platform directories"
echo "3. Run the app: flutter run"