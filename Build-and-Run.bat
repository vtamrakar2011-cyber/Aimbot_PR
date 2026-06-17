@echo off
REM Batch Build and Run Script for Aimbot Memory Scanner
REM Run as Administrator

color 0B
echo.
echo ========================================
echo   Aimbot Memory Scanner - Build ^& Run
echo ========================================
echo.

REM Check if running as Administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: This script must be run as Administrator!
    echo Please right-click and select "Run as Administrator"
    pause
    exit /b 1
)

echo [*] Current directory: %cd%
echo [*] Checking for solution file...

if NOT exist "AimbotScanner.sln" (
    echo ERROR: AimbotScanner.sln not found in current directory!
    echo Please run this script from the repository root directory
    echo Current directory: %cd%
    pause
    exit /b 1
)

echo [OK] Found AimbotScanner.sln
echo.

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
echo.

echo [*] Locating MSBuild...
for /f "delims=" %%A in ('dir /s /b "%VS_PATH%\MSBuild.exe" 2^>nul ^| findstr /r ".*MSBuild.exe$" ') do (
    set "MSBUILD=%%A"
    goto :found_msbuild
)

echo ERROR: MSBuild not found in %VS_PATH%
pause
exit /b 1

:found_msbuild
echo [OK] MSBuild found: %MSBUILD%
echo.

echo [*] Building solution...
echo    File: AimbotScanner.sln
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
echo [OK] Build completed successfully
echo.

echo [*] Locating executable...
if exist "WindowsFormsApp1\bin\Release\WindowsFormsApp1.exe" (
    set "EXE_PATH=WindowsFormsApp1\bin\Release\WindowsFormsApp1.exe"
) else (
    echo ERROR: Executable not found!
    echo Expected path: WindowsFormsApp1\bin\Release\WindowsFormsApp1.exe
    pause
    exit /b 1
)

echo [OK] Executable found: %EXE_PATH%
echo.

echo [*] Launching application...
echo    Path: %CD%\%EXE_PATH%
echo.

start "" "%CD%\%EXE_PATH%"

echo [OK] Application launched!
echo.
echo ========================================
echo   Build ^& Launch Complete
echo ========================================
echo.
pause
