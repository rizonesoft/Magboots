# Magboots Build Script
# Usage: .\scripts\build.ps1 [-Release] [-Arch x64|arm64]
#
# Requires: LLVM-MinGW in portable\llvm-mingw\ or in PATH

param(
    [switch]$Release,
    [ValidateSet("x64", "arm64")]
    [string]$Arch = "x64"
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path $PSScriptRoot -Parent
$SrcDir = Join-Path $ProjectRoot "src"
$BuildDir = Join-Path $ProjectRoot "build"
$PortableDir = Join-Path $ProjectRoot "portable"

# Ensure build directory exists
if (-not (Test-Path $BuildDir)) {
    New-Item -ItemType Directory -Path $BuildDir | Out-Null
}

# Find clang++ compiler
$ClangPath = $null

# Priority 1: Portable LLVM-MinGW
$PortableLLVM = Join-Path $PortableDir "llvm-mingw\bin\clang++.exe"
if (Test-Path $PortableLLVM) {
    $ClangPath = $PortableLLVM
    Write-Host "Using portable LLVM-MinGW" -ForegroundColor Cyan
}

# Priority 2: System PATH
if (-not $ClangPath) {
    $SystemClang = Get-Command "clang++.exe" -ErrorAction SilentlyContinue
    if ($SystemClang) {
        $ClangPath = $SystemClang.Source
        Write-Host "Using system clang++" -ForegroundColor Cyan
    }
}

if (-not $ClangPath) {
    Write-Error @"
clang++ not found!

Install LLVM-MinGW:
1. Download from: https://github.com/mstorsjo/llvm-mingw/releases
2. Extract to: $PortableDir\llvm-mingw\
3. Run this script again
"@
    exit 1
}

# Architecture-specific settings
switch ($Arch) {
    "x64"   { $Target = "x86_64-w64-mingw32" }
    "arm64" { $Target = "aarch64-w64-mingw32" }
}

# Compiler flags
$BaseFlags = "-static -target $Target"
if ($Release) {
    $Flags = "$BaseFlags -O2 -DNDEBUG -s"  # -s strips symbols
    Write-Host "Building RELEASE ($Arch)..." -ForegroundColor Green
} else {
    $Flags = "$BaseFlags -g -O0"
    Write-Host "Building DEBUG ($Arch)..." -ForegroundColor Yellow
}

# Output filename
$OutputName = if ($Arch -eq "x64") { "magboots.exe" } else { "magboots-$Arch.exe" }
$SourceFile = Join-Path $SrcDir "shim.cpp"
$OutputFile = Join-Path $BuildDir $OutputName

Write-Host "Compiler: $ClangPath"
Write-Host "Target: $Target"
Write-Host "Source: $SourceFile"

# Build command
$cmd = "& `"$ClangPath`" `"$SourceFile`" -o `"$OutputFile`" $Flags"
Write-Host $cmd -ForegroundColor DarkGray
Invoke-Expression $cmd

if ($LASTEXITCODE -eq 0 -and (Test-Path $OutputFile)) {
    $size = (Get-Item $OutputFile).Length / 1KB
    Write-Host "`nBuild successful!" -ForegroundColor Green
    Write-Host "Output: $OutputFile ($([math]::Round($size, 1)) KB)"
} else {
    Write-Error "Build failed!"
    exit 1
}
