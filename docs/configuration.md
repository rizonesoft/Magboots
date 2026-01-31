# Configuration Reference

Magboots uses two configuration files:

| File | Location | Purpose |
|------|----------|---------|
| `tools.ini` | Next to Magboots executables | Global defaults |
| `.magboots/tools.ini` | Project root | Per-workspace overrides |

## File Format

Both files use INI-style syntax:

```ini
; Comments start with semicolon or hash
# This is also a comment

; Format: toolname = /path/to/executable
php = C:\Magboots\portable\php-8.3\php.exe
git = C:\Program Files\Git\bin\git.exe
```

### Rules

- Tool name must match the Magboots shim filename (e.g., `php.exe` looks for `php`)
- Paths can contain spaces (no quotes needed)
- Only one tool per line
- Empty lines and comments are ignored

## Global Configuration

The global `tools.ini` sits next to your Magboots executables:

```
C:\Magboots\
├── php.exe          ← Shim
├── git.exe          ← Shim
├── node.exe         ← Shim
├── tools.ini        ← Global config
└── portable\
    ├── php-8.3\
    └── node-20\
```

### Example Global Config

```ini
; =============================================================================
; Global Tools Configuration
; =============================================================================

; -----------------------------------------------------------------------------
; SYSTEM PASSTHROUGH
; Route to existing system installations
; -----------------------------------------------------------------------------
git = C:\Program Files\Git\bin\git.exe
gh  = C:\Program Files\GitHub CLI\gh.exe

; -----------------------------------------------------------------------------
; PORTABLE TOOLS
; Route to portable/versioned installations
; -----------------------------------------------------------------------------
php = C:\Magboots\portable\php-8.3\php.exe
python = C:\Magboots\portable\python-3.12\python.exe
node = C:\Magboots\portable\node-20\node.exe
npm = C:\Magboots\portable\node-20\npm.cmd
composer = C:\Magboots\portable\composer\composer.bat
```

## Per-Workspace Configuration

Create a `.magboots` folder in your project root with a `tools.ini` file:

```
D:\Projects\LegacyApp\
├── .magboots\
│   └── tools.ini    ← Workspace override
├── src\
├── composer.json
└── ...
```

### Example Workspace Config

```ini
; Only override tools that differ from global
php = C:\Magboots\portable\php-7.4\php.exe
```

### Priority

1. **Workspace config** (`.magboots/tools.ini`) — checked first, walking up directory tree
2. **Global config** (`tools.ini` next to shim) — fallback if no workspace config

### Directory Tree Walking

Magboots searches for `.magboots/tools.ini` starting from the current working directory and walking up:

```
Current: D:\Projects\LegacyApp\src\controllers\

Search order:
1. D:\Projects\LegacyApp\src\controllers\.magboots\tools.ini  ❌
2. D:\Projects\LegacyApp\src\.magboots\tools.ini              ❌
3. D:\Projects\LegacyApp\.magboots\tools.ini                  ✅ Found!
```

This means you can place `.magboots` at your project root and it applies to all subdirectories.

## Adding New Tools

1. Copy the Magboots shim executable and rename it:
   ```powershell
   Copy-Item C:\Magboots\shim.exe C:\Magboots\python.exe
   ```

2. Add the tool to `tools.ini`:
   ```ini
   python = C:\Magboots\portable\python-3.12\python.exe
   ```

3. Test:
   ```powershell
   python --version
   ```

## Troubleshooting

### Tool Not Found

```
[Magboots] No path configured for 'php'.
```

**Solution**: Add the tool to your `tools.ini`:
```ini
php = C:\path\to\php.exe
```

### Target Not Found

```
[Magboots] Target not found: C:\invalid\path\php.exe
```

**Solution**: Verify the path in `tools.ini` points to an existing executable.

### Wrong Version Used

If the wrong version is being used:
1. Check your current directory with `pwd`
2. Verify `.magboots/tools.ini` exists in the right location
3. Check the global `tools.ini` for fallback path
