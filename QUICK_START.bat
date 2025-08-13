@echo off
echo 🚀 Lancement de Prioris...
echo.

REM Vérifier si Flutter est installé
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Flutter n'est pas installé ou pas dans le PATH
    echo.
    echo 📋 Suivez les instructions du fichier INSTALL_FLUTTER.md
    pause
    exit /b 1
)

echo ✅ Flutter détecté
echo.

REM Naviguer vers le projet
cd /d "%~dp0"

echo 📦 Installation des dépendances...
flutter pub get

echo.
echo 🌐 Activation du support Web...
flutter config --enable-web

echo.
echo 🚀 Lancement de l'application...
flutter run -d chrome

pause 