# Magboots Installation Script
# Installs Magboots and creates tool copies
# Usage: .\scripts\install.ps1 -Destination "C:\Magboots" [-Tools @("git", "php", "node")] [-AddToPath]

param(
    [Parameter(Mandatory=$true)]
    [string]$Destination,
    
    [string[]]$Tools = @("git", "gh"),
    
    [switch]$AddToPath
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path $PSScriptRoot -Parent
$BuildDir = Join-Path $ProjectRoot "build"
$MagbootsExe = Join-Path $BuildDir "magboots.exe"

# Verify magboots exists
if (-not (Test-Path $MagbootsExe)) {
    Write-Error "magboots.exe not found. Run .\scripts\build.ps1 -Release first."
    exit 1
}

# Create destination directory
if (-not (Test-Path $Destination)) {
    Write-Host "Creating directory: $Destination"
    New-Item -ItemType Directory -Path $Destination | Out-Null
}

# Copy shim for each tool
foreach ($tool in $Tools) {
    $targetExe = Join-Path $Destination "$tool.exe"
    Write-Host "Creating: $targetExe"
    Copy-Item $MagbootsExe $targetExe -Force
}

# Copy original shim
$originalShim = Join-Path $Destination "magboots.exe"
Copy-Item $MagbootsExe $originalShim -Force

# Create portable directory
$portableDir = Join-Path $Destination "portable"
if (-not (Test-Path $portableDir)) {
    New-Item -ItemType Directory -Path $portableDir | Out-Null
    Write-Host "Created portable tools directory: $portableDir"
}

# Copy example config
$configExample = Join-Path $ProjectRoot "config\tools.ini.example"
$configTarget = Join-Path $Destination "tools.ini"
if (-not (Test-Path $configTarget)) {
    Write-Host "Creating default tools.ini from example"
    Copy-Item $configExample $configTarget
    Write-Host "`n⚠ IMPORTANT: Edit $configTarget to configure your tool paths!" -ForegroundColor Yellow
}

Write-Host "`nInstallation complete!" -ForegroundColor Green
Write-Host "Location: $Destination"
Write-Host "Tools: $($Tools -join ', ')"

# Optionally add to PATH
if ($AddToPath) {
    $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($userPath -notlike "*$Destination*") {
        $newPath = "$Destination;$userPath"
        [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
        Write-Host "`nAdded to User PATH (restart terminal to take effect)" -ForegroundColor Green
    } else {
        Write-Host "`nDestination already in PATH" -ForegroundColor Yellow
    }
}

Write-Host "`nNext steps:"
Write-Host "1. Edit $configTarget to set your tool paths"
Write-Host "2. Add portable tools to $portableDir"
Write-Host "3. Ensure $Destination is at the BEGINNING of your PATH"
Write-Host "4. Restart your terminal"
Write-Host "`nDocumentation: $ProjectRoot\docs\"
