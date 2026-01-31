// Magboots: Context-Aware Tool Router
// Handles Per-Workspace Versioning & System Passthrough
// 
// This program acts as a traffic controller for CLI tools.
// When a command like 'php' or 'git' is executed:
//   1. Check for .magboots/tools.ini in the current directory (walk up tree)
//   2. Fall back to global tools.ini next to the shim
//   3. Execute the configured tool with full handle inheritance
//
// Copyright (c) 2026 Rizonesoft - MIT License

#include <windows.h>
#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <filesystem>

namespace fs = std::filesystem;

// Configuration file names
const std::string LOCAL_CONFIG_DIR = ".magboots";
const std::string LOCAL_CONFIG_FILE = "tools.ini";
const std::string GLOBAL_CONFIG_FILE = "tools.ini";

// Helper to clean up configuration strings
std::string trim(const std::string& str) {
    size_t first = str.find_first_not_of(" \t\r\n");
    if (std::string::npos == first) return str;
    size_t last = str.find_last_not_of(" \t\r\n");
    return str.substr(first, (last - first + 1));
}

// Search for a specific tool path in an INI file
std::string getPathFromIni(const std::string& iniPath, const std::string& toolName) {
    if (!fs::exists(iniPath)) return "";
    std::ifstream file(iniPath);
    std::string line;
    while (std::getline(file, line)) {
        // Skip comments and empty lines
        std::string trimmedLine = trim(line);
        if (trimmedLine.empty() || trimmedLine[0] == ';' || trimmedLine[0] == '#') {
            continue;
        }
        // Match "toolname ="
        if (line.find(toolName) == 0) {
            size_t len = toolName.length();
            // Ensure we matched the whole word (e.g. 'php' not 'php8')
            if (line[len] == '=' || (line[len] == ' ' && line.find('=') != std::string::npos)) {
                size_t eq = line.find('=');
                return trim(line.substr(eq + 1));
            }
        }
    }
    return "";
}

int main(int argc, char* argv[]) {
    // 1. Identify SELF (e.g., "git.exe" -> "git")
    char buffer[MAX_PATH];
    GetModuleFileNameA(NULL, buffer, MAX_PATH);
    std::string shimFullPath = buffer;
    std::string toolName = fs::path(shimFullPath).stem().string();

    std::string targetPath = "";

    // 2. PRIORITY 1: Walk up directory tree looking for '.magboots/tools.ini'
    try {
        fs::path searchPath = fs::current_path();
        while (true) {
            // Check for .magboots/tools.ini (directory format)
            fs::path localConfigDir = searchPath / LOCAL_CONFIG_DIR / LOCAL_CONFIG_FILE;
            if (fs::exists(localConfigDir)) {
                targetPath = getPathFromIni(localConfigDir.string(), toolName);
                if (!targetPath.empty()) break; // Found local override
            }
            
            if (searchPath == searchPath.root_path()) break;
            searchPath = searchPath.parent_path();
        }
    } catch (...) {}

    // 3. PRIORITY 2: Check Global 'tools.ini' next to the shim
    if (targetPath.empty()) {
        std::string globalConfig = fs::path(shimFullPath).parent_path().string() + "\\" + GLOBAL_CONFIG_FILE;
        targetPath = getPathFromIni(globalConfig, toolName);
    }

    // 4. Error Handling
    if (targetPath.empty()) {
        std::cerr << "[Magboots] No path configured for '" << toolName << "'." << std::endl;
        std::cerr << "Add '" << toolName << " = /path/to/executable' to tools.ini" << std::endl;
        return 1;
    }

    // Verify target exists
    if (!fs::exists(targetPath)) {
        std::cerr << "[Magboots] Target not found: " << targetPath << std::endl;
        return 1;
    }

    // 5. Execution Strategy: Inherit Environment & Handles
    std::string cmdLine = "\"" + targetPath + "\"";
    for (int i = 1; i < argc; ++i) {
        cmdLine += " \"";
        cmdLine += argv[i];
        cmdLine += "\"";
    }

    STARTUPINFOA si;
    PROCESS_INFORMATION pi;
    ZeroMemory(&si, sizeof(si));
    si.cb = sizeof(si);
    // CRITICAL: Pass StdOut/Err pipes so the Agent can read output
    si.dwFlags |= STARTF_USESTDHANDLES;
    si.hStdInput = GetStdHandle(STD_INPUT_HANDLE);
    si.hStdOutput = GetStdHandle(STD_OUTPUT_HANDLE);
    si.hStdError = GetStdHandle(STD_ERROR_HANDLE);

    ZeroMemory(&pi, sizeof(pi));
    std::vector<char> cmdBuf(cmdLine.begin(), cmdLine.end());
    cmdBuf.push_back(0);

    // lpEnvironment = NULL inherits current env (PATH, HOME, USERPROFILE, SSH_AUTH_SOCK)
    if (!CreateProcessA(NULL, cmdBuf.data(), NULL, NULL, TRUE, 0, NULL, NULL, &si, &pi)) {
        std::cerr << "[Magboots] Failed to launch: " << targetPath << std::endl;
        std::cerr << "Error code: " << GetLastError() << std::endl;
        return 1;
    }

    WaitForSingleObject(pi.hProcess, INFINITE);
    DWORD exitCode;
    GetExitCodeProcess(pi.hProcess, &exitCode);
    CloseHandle(pi.hProcess);
    CloseHandle(pi.hThread);

    return exitCode;
}
