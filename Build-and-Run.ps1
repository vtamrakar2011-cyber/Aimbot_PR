# PowerShell Build and Run Script for Aimbot Memory Scanner
# Run with Administrator privileges

# Check if running as Administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    Write-Host "Please re-run PowerShell as Administrator and try again." -ForegroundColor Yellow
    Read-Host "Press ENTER to exit"
    exit 1
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Aimbot Memory Scanner - Build & Run" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "[*] Current directory: $(Get-Location)" -ForegroundColor Yellow
Write-Host "[*] Checking for solution file..." -ForegroundColor Yellow

if (-not (Test-Path "AimbotScanner.sln"))
{
    Write-Host "ERROR: AimbotScanner.sln not found!" -ForegroundColor Red
    Write-Host "Please run this script from the repository root directory" -ForegroundColor Yellow
    Write-Host "Current directory: $(Get-Location)" -ForegroundColor Yellow
    Read-Host "Press ENTER to exit"
    exit 1
}

Write-Host "[OK] Found AimbotScanner.sln" -ForegroundColor Green
Write-Host ""

Write-Host "[*] Checking for CROXY.cs..." -ForegroundColor Yellow
if (-not (Test-Path "CROXY.cs"))
{
    Write-Host "ERROR: CROXY.cs not found in repository root!" -ForegroundColor Red
    Write-Host "This file is required for the build." -ForegroundColor Yellow
    Read-Host "Press ENTER to exit"
    exit 1
}

Write-Host "[OK] Found CROXY.cs" -ForegroundColor Green
Write-Host ""

# Check if Visual Studio is installed
Write-Host "[*] Checking for Visual Studio..." -ForegroundColor Yellow
$vsPath = "C:\Program Files (x86)\Microsoft Visual Studio\2019"
if (-not (Test-Path $vsPath))
{
    $vsPath = "C:\Program Files\Microsoft Visual Studio\2022"
    if (-not (Test-Path $vsPath))
    {
        $vsPath = "C:\Program Files (x86)\Microsoft Visual Studio\2022"
        if (-not (Test-Path $vsPath))
        {
            Write-Host "ERROR: Visual Studio not found!" -ForegroundColor Red
            Write-Host "Please install Visual Studio Community 2019+ with .NET development tools" -ForegroundColor Yellow
            Write-Host "Download: https://visualstudio.microsoft.com/downloads/" -ForegroundColor Cyan
            Read-Host "Press ENTER to exit"
            exit 1
        }
    }
}

Write-Host "[OK] Visual Studio found: $vsPath" -ForegroundColor Green
Write-Host ""

# Find MSBuild
Write-Host "[*] Locating MSBuild..." -ForegroundColor Yellow
$msbuild = Get-ChildItem -Path "$vsPath" -Filter "msbuild.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1

if (-not $msbuild)
{
    Write-Host "ERROR: MSBuild not found in $vsPath" -ForegroundColor Red
    Read-Host "Press ENTER to exit"
    exit 1
}

Write-Host "[OK] MSBuild found: $($msbuild.FullName)" -ForegroundColor Green
Write-Host ""

# Build the solution
Write-Host "[*] Building solution..." -ForegroundColor Yellow
Write-Host "    Solution: AimbotScanner.sln" -ForegroundColor Cyan
Write-Host "    Configuration: Release" -ForegroundColor Cyan
Write-Host ""

& "$($msbuild.FullName)" "AimbotScanner.sln" /p:Configuration=Release /p:Platform="Any CPU" /m

if ($LASTEXITCODE -ne 0)
{
    Write-Host ""
    Write-Host "ERROR: Build failed with exit code $LASTEXITCODE" -ForegroundColor Red
    Write-Host ""
    Write-Host "Troubleshooting:" -ForegroundColor Yellow
    Write-Host "1. Ensure Visual Studio is properly installed with C# workload" -ForegroundColor Cyan
    Write-Host "2. Check that all files are in the correct locations" -ForegroundColor Cyan
    Write-Host "3. Try opening AimbotScanner.sln directly in Visual Studio" -ForegroundColor Cyan
    Write-Host ""
    Read-Host "Press ENTER to exit"
    exit 1
}

Write-Host ""
Write-Host "[OK] Build completed successfully" -ForegroundColor Green
Write-Host ""

# Find the compiled executable
Write-Host "[*] Locating executable..." -ForegroundColor Yellow
$exe = Get-ChildItem -Path ".\WindowsFormsApp1\bin\Release" -Filter "WindowsFormsApp1.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1

if (-not $exe)
{
    Write-Host "ERROR: Executable not found in bin\Release!" -ForegroundColor Red
    Write-Host "Expected path: $(Get-Location)\WindowsFormsApp1\bin\Release\WindowsFormsApp1.exe" -ForegroundColor Yellow
    Read-Host "Press ENTER to exit"
    exit 1
}

Write-Host "[OK] Executable found: $($exe.FullName)" -ForegroundColor Green
Write-Host ""

# Run the application
Write-Host "[*] Launching application..." -ForegroundColor Yellow
Write-Host "    Path: $($exe.FullName)" -ForegroundColor Cyan
Write-Host ""

Start-Process -FilePath $exe.FullName -Verb RunAs

Start-Sleep -Milliseconds 1500

Write-Host "[OK] Application launched!" -ForegroundColor Green
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Build & Launch Complete" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
