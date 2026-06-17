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

echo [*] Checking for Visual Studio...
if exist "C:\Program Files (x86)\Microsoft Visual Studio\2019" (
    set "VS_PATH=C:\Program Files (x86)\Microsoft Visual Studio\2019"
) else if exist "C:\Program Files\Microsoft Visual Studio\2022" (
    set "VS_PATH=C:\Program Files\Microsoft Visual Studio\2022"
) else (
    echo ERROR: Visual Studio not found!
    echo Please install Visual Studio Community 2019+ with .NET development tools
    pause
    exit /b 1
)

echo [OK] Visual Studio found
echo.

echo [*] Locating MSBuild...
for /f "delims=" %%A in ('dir /s /b "%VS_PATH%\MSBuild.exe" 2^>nul') do (
    set "MSBUILD=%%A"
    goto :found_msbuild
)

echo ERROR: MSBuild not found!
pause
exit /b 1

:found_msbuild
echo [OK] MSBuild found: %MSBUILD%
echo.

echo [*] Building solution...
"%MSBUILD%" "AimbotScanner.sln" /p:Configuration=Release /p:Platform="Any CPU" /m

if %errorLevel% neq 0 (
    echo ERROR: Build failed!
    pause
    exit /b 1
)

echo [OK] Build completed successfully
echo.

echo [*] Locating executable...
if exist "WindowsFormsApp1\bin\Release\WindowsFormsApp1.exe" (
    set "EXE_PATH=WindowsFormsApp1\bin\Release\WindowsFormsApp1.exe"
) else (
    echo ERROR: Executable not found!
    pause
    exit /b 1
)

echo [OK] Executable found: %EXE_PATH%
echo.

echo [*] Launching application...
echo    Path: %EXE_PATH%
echo.

start "" "%CD%\%EXE_PATH%"

echo [OK] Application launched!
echo.
echo ========================================
echo   Build ^& Launch Complete
echo ========================================
echo.
pause
