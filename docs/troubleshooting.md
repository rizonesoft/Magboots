# Troubleshooting

Common issues and solutions when using Magboots.

## Error Messages

### "No path configured for 'toolname'"

```
[Magboots] No path configured for 'php'.
Add 'php = /path/to/executable' to tools.ini
```

**Cause**: The tool isn't defined in either workspace or global config.

**Solution**:
1. Open your `tools.ini` (next to Magboots executables)
2. Add the tool path:
   ```ini
   php = C:\Magboots\portable\php-8.3\php.exe
   ```

### "Target not found"

```
[Magboots] Target not found: C:\invalid\path\php.exe
```

**Cause**: The path in `tools.ini` points to a file that doesn't exist.

**Solution**:
1. Verify the path is correct
2. Check for typos
3. Use `Test-Path` to verify:
   ```powershell
   Test-Path "C:\Magboots\portable\php-8.3\php.exe"
   ```

### "Failed to launch"

```
[Magboots] Failed to launch: C:\path\to\tool.exe
Error code: 5
```

**Cause**: Permission denied or file is not executable.

**Common error codes**:
- `2` - File not found
- `5` - Access denied
- `740` - Requires elevation (run as admin)

**Solution**:
1. Check file permissions
2. Try running as Administrator if needed
3. Verify the file is a valid executable

## Wrong Version Being Used

### Symptoms
- Running `php -v` shows wrong version
- Per-workspace config seems ignored

### Diagnosis

1. **Check current directory**:
   ```powershell
   Get-Location
   ```

2. **Verify config location**:
   ```powershell
   Test-Path ".magboots\tools.ini"
   # Walk up if not found
   Test-Path "..\\.magboots\\tools.ini"
   ```

3. **Check config contents**:
   ```powershell
   Get-Content ".magboots\tools.ini"
   ```

4. **Verify which executable runs**:
   ```powershell
   where php
   # Should show C:\Magboots\php.exe (the shim)
   ```

### Solutions

1. **Config file missing**: Create `.magboots/tools.ini` in project root
2. **Wrong path in config**: Fix the path to point to correct executable
3. **Shim not in PATH**: Add Magboots directory to PATH
4. **PATH order wrong**: Magboots must be BEFORE system tools in PATH

## PATH Issues

### Magboots Not Intercepting Calls

```powershell
where git
# Shows: C:\Program Files\Git\bin\git.exe
# Should show: C:\Magboots\git.exe
```

**Solution**: Move Magboots to the BEGINNING of your PATH:

1. Open **Environment Variables**
2. Edit **User PATH**
3. Move `C:\Magboots` to the top
4. Restart terminal

### Multiple Shims Found

```powershell
where git
# C:\Magboots\git.exe
# C:\Program Files\Git\bin\git.exe
```

This is **correct** - the first one (Magboots) will be used.

## Agent/Tool Integration Issues

### Agent Can't Read Output

**Symptom**: AI agent hangs or shows no output from commands.

**Cause**: Handle inheritance not working.

**Solution**: This is handled by Magboots' `STARTF_USESTDHANDLES`. If you still see issues:
1. Verify you're using a Magboots shim (not direct tool)
2. Check the agent's terminal/shell settings
3. Try running the command manually first

### Authentication Failed

**Symptom**: Git push/pull fails with auth errors.

**Cause**: Usually HOME environment variable not set.

**Solution**: See [Windows Environment Issues](windows-environment.md)

```powershell
# Set HOME
[Environment]::SetEnvironmentVariable("HOME", $env:USERPROFILE, "User")
# Restart terminal
```

## Build Issues

### clang++ Not Found

```
clang++ not found!
```

**Solution**: Install LLVM-MinGW:
1. Download from https://github.com/mstorsjo/llvm-mingw/releases
2. Extract to `R:\Magboots\portable\llvm-mingw\`
3. Or add to PATH
4. Restart terminal

### Compilation Errors

If you get C++ errors during build:
1. Ensure you have LLVM-MinGW with C++17 support
2. Try: `clang++ --version` (should be 15.0+)
3. Verify the portable path: `portable\llvm-mingw\bin\clang++.exe`

## Getting Help

If you can't resolve an issue:

1. **Check logs**: Run the command directly to see Magboots error messages
2. **Verify config**: Print your config with `Get-Content tools.ini`
3. **Test manually**: Run the target tool directly (bypassing Magboots)
4. **Open an issue**: https://github.com/rizonesoft/Magboots/issues
