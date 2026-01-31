# Magboots - Development TODO

> **Project Goal:** Create a Context-Aware Tool Router that enables per-workspace tool versioning while preserving system-installed tools through transparent passthrough.

---

## Phase 1: Project Initialization ✅

### 1.1 Directory Structure Setup
- [x] Create `src/` directory for C++ source files
- [x] Create `config/` directory for example configuration files
- [x] Create `docs/` directory for documentation
- [x] Create `scripts/` directory for utility scripts
- [x] Create `todo/` directory for task tracking

### 1.2 Core Files Creation
- [x] Create `src/shim.cpp` with the Magboots implementation
- [x] Create `config/tools.ini.example` (global config template)
- [x] Create `config/workspace-tools.ini.example` (per-workspace config template)
- [x] Create `README.md` with project overview
- [x] Create `LICENSE` file (MIT)
- [x] Create `CHANGELOG.md` for version tracking

---

## Phase 2: Documentation ✅

### 2.1 User Documentation
- [x] Write `docs/installation.md` with detailed setup
- [x] Write `docs/configuration.md` with all options
- [x] Write `docs/windows-environment.md` for HOME env var issues
- [x] Write `docs/troubleshooting.md` for common issues

---

## Phase 3: GitHub Repository Setup

### 3.1 Git Initialization
- [x] Create `.gitignore` for C++ projects
- [x] Create `.github/workflows/build.yml` for CI
- [x] Create `.github/workflows/release.yml` for releases
- [ ] Initialize git repository (`git init`)
- [ ] Make initial commit with project structure
- [ ] Create repository on GitHub (rizonesoft/Magboots)
- [ ] Push to main branch

---

## Phase 4: Build & Compile

### 4.1 Build System
- [x] Create `scripts/build.ps1` for PowerShell builds
- [x] Create `scripts/install.ps1` for installation
- [ ] Install MinGW-w64 or verify g++ is available
- [ ] Compile release binary: `.\scripts\build.ps1 -Release`
- [ ] Test binary runs without external DLLs

---

## Phase 5: Portable Tools Setup

### 5.1 Create Directory Structure
- [ ] Create `portable/` directory
- [ ] Download PHP 8.3 portable
- [ ] Download Node.js LTS portable (optional)
- [ ] Configure `tools.ini` with actual paths

### 5.2 Test Tool Routing
- [ ] Test system Git passthrough
- [ ] Test portable PHP routing
- [ ] Test per-workspace override

---

## Phase 6: Testing & Verification

### 6.1 Manual Testing
- [ ] Verify shim intercepts calls correctly
- [ ] Test directory tree walking for `.magboots/tools.ini`
- [ ] Test stdout/stderr passthrough
- [ ] Test exit code propagation
- [ ] Test with AI agent (Antigravity)

---

## Phase 7: Release

### 7.1 First Release
- [ ] Tag version v1.0.0
- [ ] GitHub Actions creates release
- [ ] Download and verify release package

---

## Quick Reference

### Build Command
```powershell
.\scripts\build.ps1 -Release
```

### Install Command
```powershell
.\scripts\install.ps1 -Destination "C:\Magboots" -Tools @("git", "php") -AddToPath
```

### Project Structure
```
R:\Magboots\
├── src\
│   └── shim.cpp         # Core router implementation
├── build\
│   └── magboots.exe     # Compiled binary
├── config\
│   ├── tools.ini.example
│   └── workspace-tools.ini.example
├── docs\
│   ├── installation.md
│   ├── configuration.md
│   ├── windows-environment.md
│   └── troubleshooting.md
├── scripts\
│   ├── build.ps1
│   └── install.ps1
├── portable\            # Downloaded portable tools
├── .github\workflows\
├── README.md
├── LICENSE
└── CHANGELOG.md
```

---

*Last Updated: 2026-01-30*
