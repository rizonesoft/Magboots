# Magboots

A context-aware tool router for Windows that enables per-workspace versioning of CLI tools while preserving system installations.

## The Problem

When using AI coding agents (like Cursor, GitHub Copilot, Windsurf, etc.), you need controlled tool versions without:
- Breaking existing system installations (Git, GitHub CLI, etc.)
- Losing authentication, SSH keys, and environment variables
- Manually switching versions between projects
- Dealing with the `HOME` environment variable issue on Windows

## The Solution

Magboots acts as a transparent proxy. When you (or an Agent) run `php` or `git`:

1. **Check Local**: Looks for `.magboots/tools.ini` in the current folder (walks up tree)
2. **Check Global**: Falls back to `tools.ini` next to the shim
3. **Passthrough**: Routes to system installs or portable versions as configured

## Quick Start

### 1. Build

```powershell
.\scripts\build.ps1 -Release
```

### 2. Install

```powershell
.\scripts\install.ps1 -Destination "C:\Magboots" -Tools @("git", "php", "node") -AddToPath
```

### 3. Configure Global Defaults

Edit `C:\Magboots\tools.ini`:

```ini
; System passthrough (preserves Git auth, SSH keys)
git = C:\Program Files\Git\bin\git.exe
gh  = C:\Program Files\GitHub CLI\gh.exe

; Portable tools
php = C:\Magboots\portable\php-8.3\php.exe
```

### 4. Per-Project Overrides (Optional)

Create `.magboots/tools.ini` in any project root:

```ini
; Use PHP 7.4 for this legacy project only
php = C:\Magboots\portable\php-7.4\php.exe
```

## Documentation

- [Installation Guide](docs/installation.md)
- [Configuration Reference](docs/configuration.md)
- [Windows Environment Issues](docs/windows-environment.md)
- [Troubleshooting](docs/troubleshooting.md)

## How It Works

```
┌───────────────────────┐
│ User runs: php -v     │
└──────────┬────────────┘
           │
           ▼
┌───────────────────────┐
│ Magboots (php.exe)    │
│ Gets CWD: D:\Project  │
└──────────┬────────────┘
           │
           ▼
┌───────────────────────┐
│ Walk up looking for   │
│ .magboots/tools.ini   │◄─── Found? Use that path
└──────────┬────────────┘
           │ Not found
           ▼
┌───────────────────────┐
│ Check tools.ini next  │
│ to shim executable    │◄─── Use global default
└──────────┬────────────┘
           │
           ▼
┌───────────────────────┐
│ Execute target with   │
│ inherited handles &   │
│ environment           │
└───────────────────────┘
```

## Requirements

- Windows 10/11
- MinGW-w64 (for compilation) or use pre-built releases

## License

MIT License - See [LICENSE](LICENSE) for details.
