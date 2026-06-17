# PowerShell Build and Run Script for Aimbot Memory Scanner
# Run with Administrator privileges

# Check if running as Administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    Write-Host "Please re-run PowerShell as Administrator and try again." -ForegroundColor Yellow
    exit 1
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Aimbot Memory Scanner - Build & Run" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Visual Studio is installed
Write-Host "[*] Checking for Visual Studio..." -ForegroundColor Yellow
$vsPath = "C:\Program Files (x86)\Microsoft Visual Studio\2019"
if (-not (Test-Path $vsPath))
{
    $vsPath = "C:\Program Files\Microsoft Visual Studio\2022"
    if (-not (Test-Path $vsPath))
    {
        Write-Host "ERROR: Visual Studio not found!" -ForegroundColor Red
        Write-Host "Please install Visual Studio Community 2019+ with .NET development tools" -ForegroundColor Yellow
        exit 1
    }
}

Write-Host "[√] Visual Studio found" -ForegroundColor Green

# Find MSBuild
Write-Host "[*] Locating MSBuild..." -ForegroundColor Yellow
$msbuild = Get-ChildItem -Path "$vsPath" -Filter "msbuild.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1

if (-not $msbuild)
{
    Write-Host "ERROR: MSBuild not found!" -ForegroundColor Red
    exit 1
}

Write-Host "[√] MSBuild found: $($msbuild.FullName)" -ForegroundColor Green

# Build the solution
Write-Host ""
Write-Host "[*] Building solution..." -ForegroundColor Yellow
& "$($msbuild.FullName)" "AimbotScanner.sln" /p:Configuration=Release /p:Platform="Any CPU" /m

if ($LASTEXITCODE -ne 0)
{
    Write-Host "ERROR: Build failed!" -ForegroundColor Red
    exit 1
}

Write-Host "[√] Build completed successfully" -ForegroundColor Green

# Find the compiled executable
Write-Host "[*] Locating executable..." -ForegroundColor Yellow
$exe = Get-ChildItem -Path ".\WindowsFormsApp1\bin\Release" -Filter "WindowsFormsApp1.exe" -Recurse | Select-Object -First 1

if (-not $exe)
{
    Write-Host "ERROR: Executable not found in bin\Release!" -ForegroundColor Red
    exit 1
}

Write-Host "[√] Executable found: $($exe.FullName)" -ForegroundColor Green

# Run the application
Write-Host ""
Write-Host "[*] Launching application..." -ForegroundColor Yellow
Write-Host "    Path: $($exe.FullName)" -ForegroundColor Cyan
Write-Host ""

Start-Process -FilePath $exe.FullName -Verb RunAs

Write-Host "[√] Application launched!" -ForegroundColor Green
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Build & Launch Complete" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
