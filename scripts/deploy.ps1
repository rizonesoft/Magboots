# Magboots Deploy Script
# Copies built binary to bin/ and creates tool shims
# Usage: .\scripts\deploy.ps1 [-Tools @("git", "php", "node")]

param(
    [string[]]$Tools = @("git", "gh")
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path $PSScriptRoot -Parent
$BuildDir = Join-Path $ProjectRoot "build"
$BinDir = Join-Path $ProjectRoot "bin"
$MagbootsExe = Join-Path $BuildDir "magboots.exe"

# Verify build exists
if (-not (Test-Path $MagbootsExe)) {
    Write-Error "magboots.exe not found. Run .\scripts\build.ps1 -Release first."
    exit 1
}

# Create bin directory
if (-not (Test-Path $BinDir)) {
    New-Item -ItemType Directory -Path $BinDir | Out-Null
    Write-Host "Created: $BinDir"
}

# Copy master binary
$masterCopy = Join-Path $BinDir "magboots.exe"
Copy-Item $MagbootsExe $masterCopy -Force
Write-Host "Deployed: magboots.exe"

# Create tool shims
foreach ($tool in $Tools) {
    $targetExe = Join-Path $BinDir "$tool.exe"
    Copy-Item $MagbootsExe $targetExe -Force
    Write-Host "Created shim: $tool.exe"
}

# Copy config if not exists
$configExample = Join-Path $ProjectRoot "config\tools.ini.example"
$configTarget = Join-Path $BinDir "tools.ini"
if (-not (Test-Path $configTarget)) {
    Copy-Item $configExample $configTarget
    Write-Host "Created: tools.ini (edit to configure tool paths)"
}

Write-Host "`nDeployment complete!" -ForegroundColor Green
Write-Host "Location: $BinDir"
Write-Host "Tools: magboots, $($Tools -join ', ')"
Write-Host "`nAdd $BinDir to your PATH to use Magboots"
