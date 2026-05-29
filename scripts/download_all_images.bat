@echo off
REM Downloads all bundled JPEG assets. Run from project root:
REM   scripts\download_all_images.bat

cd /d "%~dp0.."
echo Downloading KidCare image assets...
dart tool\download_assets.dart
if errorlevel 1 (
  echo.
  echo Download failed. Ensure Dart/Flutter SDK is on PATH.
  exit /b 1
)
echo.
echo All images saved under assets\images\
pause
