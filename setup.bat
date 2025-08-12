@echo off
echo 🚀 Setting up SpotNav Flutter App...

REM Check if Flutter is installed
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Flutter is not installed. Please install Flutter first.
    echo Visit: https://flutter.dev/docs/get-started/install
    pause
    exit /b 1
)

echo ✅ Flutter is installed

REM Show Flutter version
flutter --version

REM Clean and get dependencies
echo ✅ Cleaning project...
flutter clean

echo ✅ Getting dependencies...
flutter pub get

REM Check if firebase_options.dart exists
if not exist "lib\firebase_options.dart" (
    echo ⚠️  Firebase configuration not found!
    echo Please run: flutterfire configure
    echo Make sure you have:
    echo 1. Created a Firebase project
    echo 2. Installed Firebase CLI: npm install -g firebase-tools
    echo 3. Installed FlutterFire CLI: dart pub global activate flutterfire_cli
)

REM Generate platform files if they don't exist
if not exist "android" (
    echo ✅ Generating Android platform files...
    flutter create --platforms android .
)

if not exist "web" (
    echo ✅ Generating Web platform files...
    flutter create --platforms web .
)

REM Check for Google Services files
if not exist "android\app\google-services.json" (
    echo ⚠️  Google Services file not found for Android!
    echo Please add google-services.json to android\app\
)

REM Run flutter doctor
echo ✅ Running Flutter doctor...
flutter doctor

echo ✅ Setup complete! 🎉
echo.
echo Next steps:
echo 1. Configure Firebase (if not done): flutterfire configure
echo 2. Add Google Services files to platform directories
echo 3. Run the app: flutter run

pause