# Magboots Environment Setup Script
# Configures PATH and HOME environment variables for Magboots
# Usage: .\scripts\setup-env.ps1 [-BinPath "R:\Magboots\bin"]
#
# Run as Administrator for system-wide changes, or as normal user for User-level

param(
    [string]$BinPath = "R:\Magboots\bin"
)

$ErrorActionPreference = "Stop"

Write-Host "=== Magboots Environment Setup ===" -ForegroundColor Cyan
Write-Host ""

# ============================================================================
# 1. Add Magboots bin to PATH
# ============================================================================
Write-Host "1. Configuring PATH..." -ForegroundColor Yellow

$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -notlike "*$BinPath*") {
    # Add to BEGINNING of PATH so Magboots intercepts first
    $newPath = "$BinPath;$userPath"
    [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
    Write-Host "   Added $BinPath to User PATH (at beginning)" -ForegroundColor Green
}
else {
    Write-Host "   $BinPath already in PATH" -ForegroundColor DarkGray
}

# ============================================================================
# 2. Set HOME environment variable (Linux/Windows compatibility fix)
# ============================================================================
Write-Host ""
Write-Host "2. Configuring HOME variable..." -ForegroundColor Yellow

$currentHome = [Environment]::GetEnvironmentVariable("HOME", "User")
$userProfile = $env:USERPROFILE

if ([string]::IsNullOrEmpty($currentHome)) {
    [Environment]::SetEnvironmentVariable("HOME", $userProfile, "User")
    Write-Host "   Set HOME = $userProfile" -ForegroundColor Green
    Write-Host "   (Fixes: Git config, SSH keys, npm, pip, etc.)" -ForegroundColor DarkGray
}
else {
    Write-Host "   HOME already set to: $currentHome" -ForegroundColor DarkGray
}

# ============================================================================
# 3. Summary
# ============================================================================
Write-Host ""
Write-Host "=== Setup Complete ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Environment variables configured:" -ForegroundColor White
Write-Host "  PATH  : $BinPath (added to beginning)"
Write-Host "  HOME  : $userProfile"
Write-Host ""
Write-Host "IMPORTANT:" -ForegroundColor Yellow
Write-Host "  - Restart your terminal for changes to take effect"
Write-Host "  - Or run: `$env:Path = [Environment]::GetEnvironmentVariable('Path', 'User')"
Write-Host ""
Write-Host "Verify with:" -ForegroundColor White
Write-Host "  where git       # Should show $BinPath\git.exe first"
Write-Host "  echo `$env:HOME  # Should show $userProfile"
