# Installation Guide

This guide covers installing Magboots on Windows systems.

## Prerequisites

- Windows 10 or Windows 11
- PowerShell 5.1 or later
- (For building from source) LLVM-MinGW

## Installation Methods

### Method 1: Pre-built Release (Recommended)

1. Download the latest release from [GitHub Releases](https://github.com/rizonesoft/Magboots/releases)
2. Extract to your desired location (e.g., `C:\Magboots`)
3. Edit `tools.ini` to configure your tool paths
4. Add the installation directory to your User PATH

### Method 2: Build from Source

1. **Install LLVM-MinGW** (portable):
   - Download from: https://github.com/mstorsjo/llvm-mingw/releases
   - Get: `llvm-mingw-20260127-ucrt-x86_64.zip`
   - Extract to: `portable\llvm-mingw\`

2. **Build and install**:
```powershell
# Clone the repository
git clone https://github.com/rizonesoft/Magboots.git
cd Magboots

# Build release binary (x64)
.\scripts\build.ps1 -Release

# Or build for ARM64
.\scripts\build.ps1 -Release -Arch arm64

# Install to target directory
.\scripts\install.ps1 -Destination "C:\Magboots" -Tools @("git", "php", "node") -AddToPath
```

## PATH Configuration

Magboots must be at the **beginning** of your PATH to intercept tool calls before system installations.

### Automatic (via Install Script)

```powershell
.\scripts\install.ps1 -Destination "C:\Magboots" -AddToPath
```

### Manual

1. Open **System Properties** → **Advanced** → **Environment Variables**
2. Under **User variables**, select **Path** and click **Edit**
3. Click **New** and add `C:\Magboots`
4. Use **Move Up** to place it at the top
5. Click **OK** and restart your terminal

## Verification

After installation, verify Magboots is intercepting calls:

```powershell
# Should show your configured Git path
where git

# Should work normally (passthrough to system Git)
git --version
```

## Uninstallation

1. Remove Magboots from your PATH
2. Delete the installation directory
3. (Optional) Remove `.magboots` folders from your projects

## Next Steps

- [Configure your tools](configuration.md)
- [Set up per-workspace overrides](configuration.md#per-workspace-configuration)
- [Understand Windows environment issues](windows-environment.md)
