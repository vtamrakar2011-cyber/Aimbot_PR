@echo off
REM Universal Auto-Navigate Build & Run Script
REM This script automatically finds the repository directory and runs the build

setlocal enabledelayedexpansion

color 0B
echo.
echo ========================================
echo   Aimbot Memory Scanner
echo   Auto-Launch Builder
echo ========================================
echo.

REM Get the directory where this script is located
set "SCRIPT_DIR=%~dp0"

REM Remove trailing backslash if present
if "%SCRIPT_DIR:~-1%"=="\" set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"

echo [*] Script location: %SCRIPT_DIR%
echo [*] Changing to repository directory...
echo.

REM Change to the script directory
cd /d "%SCRIPT_DIR%"

if %errorLevel% neq 0 (
    echo ERROR: Failed to change directory!
    echo Script location: %SCRIPT_DIR%
    pause
    exit /b 1
)

echo [OK] Current directory: %cd%
echo.

REM Check if running as Administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: This script must be run as Administrator!
    echo Please right-click and select "Run as Administrator"
    pause
    exit /b 1
)

echo [OK] Running with Administrator privileges
echo.

REM Check for solution file
if NOT exist "AimbotScanner.sln" (
    echo ERROR: AimbotScanner.sln not found!
    echo Expected location: %cd%\AimbotScanner.sln
    pause
    exit /b 1
)

echo [OK] Found AimbotScanner.sln
echo [*] Checking for Visual Studio...

if exist "C:\Program Files (x86)\Microsoft Visual Studio\2019" (
    set "VS_PATH=C:\Program Files (x86)\Microsoft Visual Studio\2019"
) else if exist "C:\Program Files\Microsoft Visual Studio\2022" (
    set "VS_PATH=C:\Program Files\Microsoft Visual Studio\2022"
) else if exist "C:\Program Files (x86)\Microsoft Visual Studio\2022" (
    set "VS_PATH=C:\Program Files (x86)\Microsoft Visual Studio\2022"
) else (
    echo ERROR: Visual Studio not found!
    echo Please install Visual Studio Community 2019+ with .NET development tools
    echo Download: https://visualstudio.microsoft.com/downloads/
    pause
    exit /b 1
)

echo [OK] Visual Studio found: %VS_PATH%
echo [*] Locating MSBuild...

for /f "delims=" %%A in ('dir /s /b "%VS_PATH%\MSBuild.exe" 2^>nul ^| findstr /r ".*MSBuild.exe$" ') do (
    set "MSBUILD=%%A"
    goto :found_msbuild
)

echo ERROR: MSBuild not found in %VS_PATH%
pause
exit /b 1

:found_msbuild
echo [OK] MSBuild found
echo.
echo [*] Building solution...
echo    Configuration: Release
echo    Platform: Any CPU
echo.

"%MSBUILD%" "AimbotScanner.sln" /p:Configuration=Release /p:Platform="Any CPU" /m /consoleloggerparameters:ErrorsOnly

if %errorLevel% neq 0 (
    echo.
    echo ERROR: Build failed with exit code %errorLevel%!
    echo.
    echo Troubleshooting:
    echo 1. Ensure Visual Studio is properly installed
    echo 2. Check that CROXY.cs exists in repository root
    echo 3. Try opening AimbotScanner.sln directly in Visual Studio
    echo.
    pause
    exit /b 1
)

echo.
echo [OK] Build completed successfully!
echo.
echo [*] Locating executable...

if exist "WindowsFormsApp1\bin\Release\WindowsFormsApp1.exe" (
    set "EXE_PATH=WindowsFormsApp1\bin\Release\WindowsFormsApp1.exe"
) else (
    echo ERROR: Executable not found!
    echo Expected: %cd%\WindowsFormsApp1\bin\Release\WindowsFormsApp1.exe
    pause
    exit /b 1
)

echo [OK] Executable found
echo.
echo [*] Launching application...
echo.

start "" "%cd%\%EXE_PATH%"

timeout /t 2 /nobreak

echo [OK] Application launched successfully!
echo.
echo ========================================
echo   Build & Launch Complete
echo ========================================
echo.

REM Keep window open for 5 seconds then close
timeout /t 5 /nobreak
exit /b 0
