# Windows Environment Issues

This document covers common environment variable problems when using AI coding tools ("vibe coding" tools) on Windows.

## The HOME Environment Variable Problem

### Background

Many developer tools were originally designed for Unix/Linux systems, where `$HOME` always points to the user's home directory (e.g., `/home/username`). When these tools are ported to Windows or when cross-platform tools are written, developers often check for `HOME` first, assuming a Unix environment.

### The Problem

On Windows:
- `HOME` is **not set by default**
- Windows uses `USERPROFILE` instead (e.g., `C:\Users\Username`)
- Many tools check `HOME` first and fail or behave unexpectedly when it's missing

### Affected Tools

This issue commonly affects:

| Tool | Symptom |
|------|---------|
| **Git** | Can't find `.gitconfig`, SSH keys in wrong location |
| **SSH/OpenSSH** | Looks for `~/.ssh` in wrong place |
| **Node.js/npm** | Package cache or config issues |
| **Python/pip** | Virtual environment or config issues |
| **Composer** | Can't find global config |
| **AI Agents** | Commands fail because tools can't find configs |

### Solution 1: Set HOME System-Wide

Set `HOME` to match `USERPROFILE`:

```powershell
# PowerShell (User Environment Variable)
[Environment]::SetEnvironmentVariable("HOME", $env:USERPROFILE, "User")

# Verify
$env:HOME
```

Or via GUI:
1. **System Properties** → **Advanced** → **Environment Variables**
2. Under **User variables**, click **New**
3. Variable name: `HOME`
4. Variable value: `%USERPROFILE%`
5. Click **OK** and restart your terminal

### Solution 2: Per-Session (Temporary)

Set `HOME` for the current terminal session:

```powershell
# PowerShell
$env:HOME = $env:USERPROFILE

# CMD
set HOME=%USERPROFILE%
```

### Solution 3: Application-Specific Workarounds

Some tools have their own config options:

**Git:**
```powershell
# Force Git to use USERPROFILE
git config --global core.homeDirectory $env:USERPROFILE
```

**SSH:**
Create a config file at `%USERPROFILE%\.ssh\config` that works regardless of HOME.

## AI Agent Environment Issues

### Problem

AI coding agents (Cursor, GitHub Copilot, Windsurf, etc.) often spawn subprocesses to run commands. These subprocesses may:

1. Not inherit all environment variables
2. Assume Unix paths (forward slashes, case-sensitive)
3. Look for tools in Unix-style locations

### How Magboots Helps

Magboots addresses these issues by:

1. **Handle Inheritance**: Uses `STARTF_USESTDHANDLES` to pass stdio handles correctly
2. **Environment Inheritance**: Passes `NULL` for `lpEnvironment`, inheriting all current env vars
3. **Controlled Routing**: Points to known-good tool installations regardless of PATH issues

### Example: Agent Running Git

Without Magboots:
```
Agent runs: git status
→ Spawns subprocess
→ HOME not set
→ Git can't find .gitconfig
→ Authentication fails
```

With Magboots:
```
Agent runs: git status
→ Hits Magboots shim (git.exe)
→ Shim inherits environment (including HOME if set)
→ Routes to system Git installation
→ Git works normally with full auth
```

## SSH Key Authentication

### Problem

SSH keys are typically stored in `~/.ssh/`. On Windows, this path depends on:
- Whether `HOME` is set
- Whether the tool respects `USERPROFILE`

### Solution

1. **Set HOME** (see above)
2. **Use explicit SSH config**:

Create `%USERPROFILE%\.ssh\config`:
```
Host github.com
    IdentityFile C:\Users\YourName\.ssh\id_ed25519
    User git

Host *
    IdentitiesOnly yes
```

3. **Verify SSH agent is running**:
```powershell
# Start SSH agent
Start-Service ssh-agent

# Add your key
ssh-add $env:USERPROFILE\.ssh\id_ed25519
```

## GitHub CLI Authentication

### Problem

GitHub CLI (`gh`) stores credentials using the system credential manager, but some AI agents can't access these credentials when spawning subprocesses.

### Solution

Magboots passes through to your system `gh` installation, which has full access to:
- Windows Credential Manager
- Environment variables (`GITHUB_TOKEN`)
- SSH authentication

Configure Magboots:
```ini
; tools.ini - passthrough to system installation
gh = C:\Program Files\GitHub CLI\gh.exe
```

## Best Practices Summary

1. **Always set HOME** to match USERPROFILE on Windows systems used for development
2. **Use Magboots** to route tools through a controlled shim layer
3. **Keep system tools** for authentication (Git, gh) — use passthrough mode
4. **Use portable tools** for version-specific needs (PHP, Node, Python)
5. **Test in a new terminal** after making environment changes

## Diagnostic Commands

```powershell
# Check environment variables
echo $env:HOME
echo $env:USERPROFILE
echo $env:PATH

# Check which tool is being used
where git
where php

# Check SSH key location
ls $env:USERPROFILE\.ssh

# Test Git authentication
git config --global --list
ssh -T git@github.com
```
