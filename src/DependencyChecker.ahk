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
        canAutoDownload := this.ArrayContains(missingDependencies, "ffmpeg") || this.ArrayContains(missingDependencies, "ffplay") || this.ArrayContains(missingDependencies, "piper")
        
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
        if (canAutoDownload) {
            errorMsg .= "1. ⚡ Click 'Yes' to automatically download and install missing dependencies`n"
            errorMsg .= "2. Manual: Download FFmpeg from https://www.gyan.dev/ffmpeg/builds/`n"
            errorMsg .= "3. Manual: Download Piper from https://github.com/rhasspy/piper/releases`n"
        } else {
        errorMsg .= "1. Download FFmpeg from https://ffmpeg.org/download.html`n"
        }
        errorMsg .= "3. Download Piper from https://github.com/rhasspy/piper`n"
        errorMsg .= "4. Extract piper.exe to .\piper\`n"
        
        if (canAutoDownload) {
            errorMsg .= "`n🔄 Auto-download will:`n"
            errorMsg .= "• Download FFmpeg essentials build (~50MB) if missing`n"
            errorMsg .= "• Download Piper binary (~15MB) if missing`n"
            errorMsg .= "• Extract to appropriate folders`n"
            errorMsg .= "• Set up proper directory structure`n`n"
            errorMsg .= "⚠️ Requires internet connection and may take a few minutes."
            
            result := MsgBox(errorMsg, "Missing Dependencies", "YesNo")
            if (result = "Yes") {
                this.AutoDownloadDependencies(missingDependencies)
                return
            }
        } else {
            errorMsg .= "`n⚠️ The application requires local installation only."
                    
        MsgBox(errorMsg, "Missing Dependencies", "Iconx")
        }
    }
    
    ; Auto-download missing dependencies
    AutoDownloadDependencies(missingDependencies) {
        if (this.downloadInProgress) {
            MsgBox("Download already in progress!", "Download Status", "Iconi")
            return false
        }
        
        success := true
        
        ; Download Piper if missing
        if (this.ArrayContains(missingDependencies, "piper")) {
            if (!this.AutoDownloadPiper()) {
                success := false
            }
        }
        
        ; Download FFmpeg if missing
        if (this.ArrayContains(missingDependencies, "ffmpeg") || this.ArrayContains(missingDependencies, "ffplay")) {
            if (!this.AutoDownloadFFmpeg()) {
                success := false
            }
        }
        
        return success
    }
    
    ; Auto-download and extract Piper
    AutoDownloadPiper() {
        if (this.downloadInProgress) {
            MsgBox("Download already in progress!", "Download Status", "Iconi")
            return false
        }
        
        this.downloadInProgress := true
        
        try {
            ; Show progress dialog
            progressGui := Gui("+Resize -MaximizeBox", "Downloading Piper TTS...")
            progressGui.SetFont("s9", "Segoe UI")
            
            statusText := progressGui.AddText("x10 y10 w300 h20 Center", "Preparing download...")
            progressBar := progressGui.AddProgress("x10 y35 w300 h20", 0)
            cancelBtn := progressGui.AddButton("x130 y65 w60 h25", "Cancel")
            
            progressGui.Show("w320 h100")
            
            ; Define paths
            downloadUrl := "https://github.com/rhasspy/piper/releases/download/2023.11.14-2/piper_windows_amd64.zip"
            tempFile := A_Temp . "\piper_windows_amd64.zip"
            extractDir := A_ScriptDir . "\piper"
            
            ; Set up cancel handler
            cancelled := false
            cancelBtn.OnEvent("Click", (*) => (cancelled := true))
            
            ; Step 1: Download
            statusText.Text := "Downloading Piper TTS (~15MB)..."
            progressBar.Value := 10
            
            ; Clean up any existing temp file
            if (FileExist(tempFile)) {
                FileDelete(tempFile)
            }
            
            if (cancelled) {
                throw Error("Download cancelled by user")
            }
            
            ; Download with error handling
            try {
                Download(downloadUrl, tempFile)
            } catch as e {
                throw Error("Failed to download Piper: " . e.Message)
            }
            
            if (!FileExist(tempFile)) {
                throw Error("Download failed - file not found")
            }
            
            statusText.Text := "Download complete. Extracting..."
            progressBar.Value := 60
            
            if (cancelled) {
                throw Error("Extraction cancelled by user")
            }
            
            ; Step 2: Extract using Windows built-in tar or other available tools
            if (!this.ExtractPiper(tempFile, extractDir, statusText, progressBar)) {
                throw Error("Failed to extract Piper archive")
            }
            
            ; Step 3: Verify extraction
            statusText.Text := "Verifying installation..."
            progressBar.Value := 90
            
            if (!FileExist(A_ScriptDir . "\piper\piper.exe")) {
                throw Error("Extraction completed but piper.exe not found")
            }
            
            ; Success
            statusText.Text := "Installation complete!"
            progressBar.Value := 100
            
            ; Clean up temp file
            if (FileExist(tempFile)) {
                FileDelete(tempFile)
            }
            
            Sleep(1000)  ; Show success briefly
            ; Check if GUI is still valid before closing
            if (IsObject(progressGui) && progressGui.Hwnd) {
                progressGui.Destroy()
            }
            
            MsgBox("✅ Piper TTS has been successfully downloaded and installed!`n`nThe application should now work properly.", "Installation Complete", "Iconi")
            Reload
            return true
            
        } catch as err {
            ; Clean up on error
            if (FileExist(tempFile)) {
                try {
                    FileDelete(tempFile)
                } catch {
                    ; Ignore cleanup errors
                }
            }
            
            try {
                ; Check if GUI is still valid before closing
                if (IsObject(progressGui) && progressGui.Hwnd) {
                    progressGui.Destroy()
                }
            } catch {
                ; GUI might already be closed or invalid, ignore
            }
            
            MsgBox("❌ Failed to download Piper:`n`n" . err.Message . "`n`nPlease try manual installation.", "Download Failed", "Iconx")
            return false
            
        } finally {
            this.downloadInProgress := false
        }
    }
    
    ; Extract Piper archive using available tools
    ExtractPiper(archiveFile, extractDir, statusText, progressBar) {
        ; Try Windows 10+ built-in tar command first (supports zip)
        if (this.TryWindowsTarForPiper(archiveFile, extractDir, statusText)) {
            return true
        }
        
        ; Try 7-Zip if available
        if (this.Try7ZipForPiper(archiveFile, extractDir, statusText)) {
            return true
        }
        
        ; Try WinRAR if available  
        if (this.TryWinRARForPiper(archiveFile, extractDir, statusText)) {
            return true
        }
        
        return false
    }
    
    ; Try extracting Piper with Windows built-in tar
    TryWindowsTarForPiper(archiveFile, extractDir, statusText) {
        try {
            statusText.Text := "Extracting with Windows tar..."
            
            ; Create directory if it doesn't exist
            if (!DirExist(extractDir)) {
                DirCreate(extractDir)
            }
            
            ; Use tar to extract (Windows 10+ has built-in zip support)
            command := 'tar -xf "' . archiveFile . '" -C "' . extractDir . '" --strip-components=1'
            
            RunWait(A_ComSpec . ' /c ' . command, , "Hide")
            
            ; Check if extraction worked
            if (FileExist(extractDir . "\piper.exe")) {
                return true
            }
            
        } catch {
            ; Ignore errors, try next method
        }
        
        return false
    }
    
    ; Try extracting Piper with 7-Zip
    Try7ZipForPiper(archiveFile, extractDir, statusText) {
        ; Look for 7-Zip in common locations
        sevenZipPaths := [
            A_ProgramFiles . "\7-Zip\7z.exe",
            EnvGet("ProgramW6432") . "\7-Zip\7z.exe",
            A_ProgramFiles . " (x86)\7-Zip\7z.exe"
        ]
        
        sevenZipPath := ""
        for path in sevenZipPaths {
            if (FileExist(path)) {
                sevenZipPath := path
                break
            }
        }
        
        if (sevenZipPath = "") {
            return false
        }
        
        try {
            statusText.Text := "Extracting with 7-Zip..."
            
            ; Create temp extraction directory
            tempExtractDir := A_Temp . "\piper_extract"
            if (DirExist(tempExtractDir)) {
                DirDelete(tempExtractDir, true)
            }
            DirCreate(tempExtractDir)
            
            ; Extract archive
            command := '"' . sevenZipPath . '" x "' . archiveFile . '" -o"' . tempExtractDir . '" -y'
            RunWait(command, , "Hide")
            
            ; Find piper.exe in the extracted content (it might be in a subfolder)
            piperExe := ""
            Loop Files, tempExtractDir . "\*", "FR" {
                if (A_LoopFileName = "piper.exe") {
                    piperExe := A_LoopFileFullPath
                    break
                }
            }
            
            if (piperExe != "") {
                ; Move piper.exe to final location
                if (!DirExist(extractDir)) {
                    DirCreate(extractDir)
                }
                FileMove(piperExe, extractDir . "\piper.exe", true)
                
                ; Clean up temp directory
                if (DirExist(tempExtractDir)) {
                    DirDelete(tempExtractDir, true)
                }
                
                return true
            }
            
        } catch {
            ; Ignore errors, try next method
        }
        
        return false
    }
    
    ; Try extracting Piper with WinRAR
    TryWinRARForPiper(archiveFile, extractDir, statusText) {
        ; Look for WinRAR in common locations
        winrarPaths := [
            A_ProgramFiles . "\WinRAR\WinRAR.exe",
            A_ProgramFiles . " (x86)\WinRAR\WinRAR.exe"
        ]
        
        winrarPath := ""
        for path in winrarPaths {
            if (FileExist(path)) {
                winrarPath := path
                break
            }
        }
        
        if (winrarPath = "") {
            return false
        }
        
        try {
            statusText.Text := "Extracting with WinRAR..."
            
            ; Create directory if it doesn't exist
            if (!DirExist(extractDir)) {
                DirCreate(extractDir)
            }
            
            ; Extract with WinRAR
            command := '"' . winrarPath . '" x -y "' . archiveFile . '" "' . extractDir . '\"'
            RunWait(command, , "Hide")
            
            ; Check if extraction worked
            if (FileExist(extractDir . "\piper.exe")) {
                return true
            }
            
        } catch {
            ; Ignore errors
        }
        
        return false
    }
    
    ; Auto-download and extract FFmpeg
    AutoDownloadFFmpeg() {
        if (this.downloadInProgress) {
            MsgBox("Download already in progress!", "Download Status", "Iconi")
            return false
        }
        
        this.downloadInProgress := true
        
        try {
            ; Show progress dialog
            progressGui := Gui("+Resize -MaximizeBox", "Downloading FFmpeg...")
            progressGui.SetFont("s9", "Segoe UI")
            
            statusText := progressGui.AddText("x10 y10 w300 h20 Center", "Preparing download...")
            progressBar := progressGui.AddProgress("x10 y35 w300 h20", 0)
            cancelBtn := progressGui.AddButton("x130 y65 w60 h25", "Cancel")
            
            progressGui.Show("w320 h100")
            
            ; Define paths
            downloadUrl := "https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.7z"
            tempFile := A_Temp . "\ffmpeg-essentials.7z"
            extractDir := A_ScriptDir . "\ffmpeg"
            
            ; Set up cancel handler
            cancelled := false
            cancelBtn.OnEvent("Click", (*) => (cancelled := true))
            
            ; Step 1: Download
            statusText.Text := "Downloading FFmpeg (~50MB)..."
            progressBar.Value := 10
            
            ; Clean up any existing temp file
            if (FileExist(tempFile)) {
                FileDelete(tempFile)
            }
            
            if (cancelled) {
                throw Error("Download cancelled by user")
            }
            
            ; Download with error handling
            try {
                Download(downloadUrl, tempFile)
            } catch as e {
                throw Error("Failed to download FFmpeg: " . e.Message)
            }
            
            if (!FileExist(tempFile)) {
                throw Error("Download failed - file not found")
            }
            
            statusText.Text := "Download complete. Extracting..."
            progressBar.Value := 60
            
            if (cancelled) {
                throw Error("Extraction cancelled by user")
            }
            
            ; Step 2: Extract using Windows built-in tar (Windows 10+) or 7-Zip if available
            if (!this.ExtractFFmpeg(tempFile, extractDir, statusText, progressBar)) {
                throw Error("Failed to extract FFmpeg archive")
            }
            
            ; Step 3: Verify extraction
            statusText.Text := "Verifying installation..."
            progressBar.Value := 90
            
            if (!FileExist(A_ScriptDir . "\ffmpeg\bin\ffmpeg.exe") || !FileExist(A_ScriptDir . "\ffmpeg\bin\ffplay.exe")) {
                throw Error("Extraction completed but required files not found")
            }
            
            ; Success
            statusText.Text := "Installation complete!"
            progressBar.Value := 100
            
            ; Clean up temp file
            if (FileExist(tempFile)) {
                FileDelete(tempFile)
            }
            
            Sleep(1000)  ; Show success briefly
            ; Check if GUI is still valid before closing
            if (IsObject(progressGui) && progressGui.Hwnd) {
                progressGui.Destroy()
            }
            
            MsgBox("✅ FFmpeg has been successfully downloaded and installed!`n`nThe application should now work properly.", "Installation Complete", "Iconi")
            
            ; Restart the application after successful installation
            Reload
            
            ; Re-check dependencies
            this.dependencyStatus := Map()  ; Clear cache
            return this.CheckAllDependencies()
            
        } catch as err {
            ; Clean up on error
            if (FileExist(tempFile)) {
                try {
                    FileDelete(tempFile)
                } catch {
                    ; Ignore cleanup errors
                }
            }
            
            try {
                ; Check if GUI is still valid before closing
                if (IsObject(progressGui) && progressGui.Hwnd) {
                    progressGui.Destroy()
                }
            } catch {
                ; GUI might already be closed or invalid, ignore
            }
            
            MsgBox("❌ Failed to download FFmpeg:`n`n" . err.Message . "`n`nPlease try manual installation.", "Download Failed", "Iconx")
            return false
            
        } finally {
            this.downloadInProgress := false
        }
    }
    
    ; Extract FFmpeg archive using available tools
    ExtractFFmpeg(archiveFile, extractDir, statusText, progressBar) {
        ; Try Windows 10+ built-in tar command first (supports 7z)
        if (this.TryWindowsTar(archiveFile, extractDir, statusText)) {
            return true
        }
        
        ; Try 7-Zip if available
        if (this.Try7Zip(archiveFile, extractDir, statusText)) {
            return true
        }
        
        ; Try WinRAR if available  
        if (this.TryWinRAR(archiveFile, extractDir, statusText)) {
            return true
        }
        
        return false
    }
    
    ; Try extracting with Windows built-in tar
    TryWindowsTar(archiveFile, extractDir, statusText) {
        try {
            statusText.Text := "Extracting with Windows tar..."
            
            ; Create directory if it doesn't exist
            if (!DirExist(extractDir)) {
                DirCreate(extractDir)
            }
            
            ; Use tar to extract (Windows 10+ has built-in 7z support via tar)
            command := 'tar -xf "' . archiveFile . '" -C "' . extractDir . '" --strip-components=1'
            
            RunWait(A_ComSpec . ' /c ' . command, , "Hide")
            
            ; Check if extraction worked
            if (FileExist(extractDir . "\bin\ffmpeg.exe")) {
                return true
            }
            
        } catch {
            ; Ignore errors, try next method
        }
        
        return false
    }
    
    ; Try extracting with 7-Zip
    Try7Zip(archiveFile, extractDir, statusText) {
        ; Look for 7-Zip in common locations
        sevenZipPaths := [
            A_ProgramFiles . "\7-Zip\7z.exe",
            EnvGet("ProgramW6432") . "\7-Zip\7z.exe",
            A_ProgramFiles . " (x86)\7-Zip\7z.exe"
        ]
        
        sevenZipPath := ""
        for path in sevenZipPaths {
            if (FileExist(path)) {
                sevenZipPath := path
                break
            }
        }
        
        if (sevenZipPath = "") {
            return false
        }
        
        try {
            statusText.Text := "Extracting with 7-Zip..."
            
            ; Create temp extraction directory
            tempExtractDir := A_Temp . "\ffmpeg_extract"
            if (DirExist(tempExtractDir)) {
                DirDelete(tempExtractDir, true)
            }
            DirCreate(tempExtractDir)
            
            ; Extract archive
            command := '"' . sevenZipPath . '" x "' . archiveFile . '" -o"' . tempExtractDir . '" -y'
            RunWait(command, , "Hide")
            
            ; Find the extracted folder (usually has a version number)
            extractedFolder := ""
            Loop Files, tempExtractDir . "\*", "D" {
                if (InStr(A_LoopFileName, "ffmpeg")) {
                    extractedFolder := A_LoopFileFullPath
                    break
                }
            }
            
            if (extractedFolder != "" && FileExist(extractedFolder . "\bin\ffmpeg.exe")) {
                ; Move to final location
                if (DirExist(extractDir)) {
                    DirDelete(extractDir, true)
                }
                DirMove(extractedFolder, extractDir)
                
                ; Clean up temp directory
                if (DirExist(tempExtractDir)) {
                    DirDelete(tempExtractDir, true)
                }
                
                return true
            }
            
        } catch {
            ; Ignore errors, try next method
        }
        
        return false
    }
    
    ; Try extracting with WinRAR
    TryWinRAR(archiveFile, extractDir, statusText) {
        ; Look for WinRAR in common locations
        winrarPaths := [
            A_ProgramFiles . "\WinRAR\WinRAR.exe",
            A_ProgramFiles . " (x86)\WinRAR\WinRAR.exe"
        ]
        
        winrarPath := ""
        for path in winrarPaths {
            if (FileExist(path)) {
                winrarPath := path
                break
            }
        }
        
        if (winrarPath = "") {
            return false
        }
        
        try {
            statusText.Text := "Extracting with WinRAR..."
            
            ; Similar logic to 7-Zip but with WinRAR commands
            ; Implementation details omitted for brevity
            ; Would use: WinRAR x -y "archiveFile" "extractDir\"
            
        } catch {
            ; Ignore errors
        }
        
        return false
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
}