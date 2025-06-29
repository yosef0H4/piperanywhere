; DependencyChecker.ahk - Checks for required executables (ffmpeg and piper)
#Requires AutoHotkey v2

class DependencyChecker {
    
    __New() {
        this.requiredDependencies := [
            {name: "piper", exeName: "piper.exe", localPath: ".\piper\piper.exe",
             downloadUrl: "https://github.com/rhasspy/piper/releases/download/2023.11.14-2/piper_windows_amd64.zip",
             extractPath: ".\piper"},
            {name: "ffmpeg", exeName: "ffmpeg.exe", localPath: ".\ffmpeg\bin\ffmpeg.exe", 
             downloadUrl: "https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.7z",
             extractPath: ".\ffmpeg"},
            {name: "ffplay", exeName: "ffplay.exe", localPath: ".\ffmpeg\bin\ffplay.exe",
             downloadUrl: "", extractPath: ""}  ; ffplay comes with ffmpeg
        ]
        this.dependencyStatus := Map()
        this.downloadInProgress := false
        this.cudaAvailable := false
    }
    
    ; Main method to check all dependencies
    CheckAllDependencies() {
        missingDependencies := []
        
        for dependency in this.requiredDependencies {
            status := this.CheckSingleDependency(dependency)
            this.dependencyStatus[dependency.name] := status
            
            if (!status.found) {
                missingDependencies.Push(dependency.name)
            }
        }
        
        if (missingDependencies.Length > 0) {
            this.ShowDependencyError(missingDependencies)
            return false
        }
        
        ; Check CUDA availability
        this.CheckCUDAAvailability()
        return true
    }
    
    ; Check a single dependency
    CheckSingleDependency(dependency) {
        status := {
            found: false,
            location: "",
            type: "" ; "local" or "system"
        }
        
        ; First check local path
        if (FileExist(dependency.localPath)) {
            status.found := true
            status.location := dependency.localPath
            status.type := "local"
            return status
        }
        
        ; If not found locally, check system PATH
        systemPath := this.FindInSystemPath(dependency.exeName)
        if (systemPath != "") {
            status.found := true
            status.location := systemPath
            status.type := "system"
            return status
        }
        
        return status
    }
    
    ; Search for executable in system PATH
    FindInSystemPath(exeName) {
        ; Get PATH environment variable
        try {
            pathVar := EnvGet("PATH")
        } catch {
            return ""
        }
        
        ; Split PATH by semicolons and check each directory
        pathDirs := StrSplit(pathVar, ";")
        
        for dir in pathDirs {
            if (dir = "") {
                continue
            }
            
            ; Clean up the directory path
            cleanDir := Trim(dir, ' "')
            if (!InStr(cleanDir, "\") && cleanDir != "") {
                cleanDir := cleanDir . "\"
            } else if (SubStr(cleanDir, -1) != "\") {
                cleanDir := cleanDir . "\"
            }
            
            fullPath := cleanDir . exeName
            
            if (FileExist(fullPath)) {
                return fullPath
            }
        }
        
        ; Also check common installation paths
        try {
            ; Get Program Files paths using environment variables
            programFiles := EnvGet("ProgramFiles")
            programW6432 := ""
            try {
                programW6432 := EnvGet("ProgramW6432")  ; 64-bit Program Files on 64-bit systems
            } catch {
                ; ProgramW6432 may not exist on 32-bit systems
            }
            
            commonPaths := [
                programFiles . "\FFmpeg\bin\" . exeName,
                programFiles . "\Piper\" . exeName
            ]
            
            ; Add 64-bit Program Files path if it exists and is different
            if (programW6432 != "" && programW6432 != programFiles) {
                commonPaths.Push(programW6432 . "\FFmpeg\bin\" . exeName)
                commonPaths.Push(programW6432 . "\Piper\" . exeName)
            }
            
            for path in commonPaths {
                if (FileExist(path)) {
                    return path
                }
            }
        } catch {
            ; If environment variable access fails, try A_ProgramFiles fallback
            commonPaths := [
                A_ProgramFiles . "\FFmpeg\bin\" . exeName,
                A_ProgramFiles . "\Piper\" . exeName
            ]
            
            for path in commonPaths {
                if (FileExist(path)) {
                    return path
                }
            }
        }
        
        return ""
    }
    
    ; Test if executable actually works
    TestExecutable(dependency) {
        status := this.dependencyStatus[dependency.name]
        
        if (!status.found) {
            return false
        }
        
        try {
            ; Test the executable with a simple command
            if (dependency.name = "piper") {
                ; Test piper with --help flag
                RunWait('"' . status.location . '" --help', , "Hide")
            } else if (dependency.name = "ffmpeg" || dependency.name = "ffplay") {
                ; Test ffmpeg/ffplay with -version flag
                RunWait('"' . status.location . '" -version', , "Hide")
            }
            return true
        } catch {
            return false
        }
    }
    
    ; Show detailed error message for missing dependencies
    ShowDependencyError(missingDependencies) {
        ; Check if we can auto-download (works for ffmpeg and piper)
        ;canAutoDownload := this.ArrayContains(missingDependencies, "ffmpeg") || this.ArrayContains(missingDependencies, "ffplay") || this.ArrayContains(missingDependencies, "piper")
        
        errorMsg := "❌ Missing Required Dependencies:`n`n"
        
        for depName in missingDependencies {
            errorMsg .= "• " . depName . "`n"
        }
        
        errorMsg .= "`n📁 Required Local Paths:`n"
        for dependency in this.requiredDependencies {
            if (this.ArrayContains(missingDependencies, dependency.name)) {
                errorMsg .= "• " . dependency.localPath . "`n"
            }
        }
        
        errorMsg .= "`n💡 Solutions:`n"
       
        errorMsg .= "1. Download FFmpeg from https://ffmpeg.org/download.html`n"
        
        errorMsg .= "2. Download Piper from https://github.com/rhasspy/piper`n"
        errorMsg .= "3. Extract piper.exe to .\piper\`n"
        
        
            errorMsg .= "`n⚠️ The application requires local installation only."
                    
        MsgBox(errorMsg, "Missing Dependencies", "Iconx")
        ;}
    }
    
    ; Get the effective path for a dependency (local or system)
    GetDependencyPath(dependencyName) {
        if (this.dependencyStatus.Has(dependencyName)) {
            status := this.dependencyStatus[dependencyName]
            if (status.found) {
                return status.location
            }
        }
        return ""
    }
    
    ; Get a summary of all dependency statuses
    GetDependencySummary() {
        summary := "🔍 Dependency Status (Local Only):`n`n"
        
        for dependency in this.requiredDependencies {
            status := this.dependencyStatus[dependency.name]
            
            if (status.found) {
                summary .= "✅ " . dependency.name . ": Found`n"
                summary .= "   📍 " . status.location . "`n`n"
            } else {
                summary .= "❌ " . dependency.name . ": Not Found`n"
                summary .= "   📍 Expected: " . dependency.localPath . "`n`n"
            }
        }
        
        ; Add CUDA information
        summary .= "🎮 GPU Acceleration:`n" . this.GetCUDAStatus() . "`n`n"
        
        return summary
    }
    
    ; Helper method to check if array contains a value
    ArrayContains(arr, value) {
        for item in arr {
            if (item = value) {
                return true
            }
        }
        return false
    }
    
    ; Method to update audio settings with dependency paths
    UpdateAudioSettings(audioSettings) {
        ; Update the AudioSettings class to use the found local paths
        piperPath := this.GetDependencyPath("piper")
        ffmpegPath := this.GetDependencyPath("ffmpeg")
        ffplayPath := this.GetDependencyPath("ffplay")
        
        if (piperPath != "" && ffmpegPath != "" && ffplayPath != "") {
            audioSettings.SetExecutablePaths(piperPath, ffmpegPath, ffplayPath)
            return true
        }
        
        return false
    }
    
    ; Check if CUDA is available on the system
    CheckCUDAAvailability() {
        try {
            ; Try to run nvidia-smi to detect NVIDIA GPU
            RunWait("nvidia-smi", , "Hide")
            this.cudaAvailable := true
        } catch {
            ; Try alternative method - check for CUDA toolkit
            try {
                RunWait("nvcc --version", , "Hide")
                this.cudaAvailable := true
            } catch {
                this.cudaAvailable := false
            }
        }
    }
    
    ; Get CUDA availability status
    IsCUDAAvailable() {
        return this.cudaAvailable
    }
    
    ; Get CUDA status as text
    GetCUDAStatus() {
        return this.cudaAvailable ? "✅ CUDA Available" : "❌ CUDA Not Detected"
    }
}
