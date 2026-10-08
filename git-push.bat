@echo off
title Push Vamos Arena Showcase to GitHub
echo ===================================================
echo   VAMOS ARENA - PUBLIC SHOWCASE GIT INITIALIZER
echo ===================================================
echo.
echo This script will initialize this showcase folder as a new Git repository,
echo link it to the public showcase GitHub repository:
echo https://github.com/N0AH205/Vamos-Arena
echo and prepare it to push without including any private source code.
echo.
pause

echo.
echo [1/5] Initializing Git repository...
git init

echo.
echo [2/5] Setting up Git remote for the showcase repository...
git remote remove origin >nul 2>&1
git remote add origin https://github.com/N0AH205/Vamos-Arena.git

echo.
echo [3/5] Staging showcase files (README and screenshots)...
git add README.md assets/

echo.
echo [4/5] Creating initial commit...
git commit -m "Initial commit: Vamos Arena public showcase design, architecture, and preview assets"

echo.
echo [5/5] Renaming default branch to main...
git branch -M main

echo.
echo ===================================================
echo   READY TO PUSH
echo ===================================================
echo.
echo To complete the upload, run:
echo   git push -u origin main --force
echo.
echo Note: If you haven't authenticated with GitHub yet, it might ask you to sign in.
echo.
set /p CHOICE="Would you like to run the push command now? (y/n): "
if /I "%CHOICE%"=="y" (
    echo.
    echo Pushing to GitHub...
    git push -u origin main --force
)

echo.
echo Done! You can close this window.
pause
