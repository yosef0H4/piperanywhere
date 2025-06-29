#Requires AutoHotkey v2.0

/**
 * Piper TTS Installation Wizard
 * A modern, robust installer for Piper TTS with improved error handling,
 * user experience, and following AHK v2 best practices
 */

class PiperDependenciesInstaller {
    static VERSION := "2.0.0"
    static WINDOW_WIDTH := 500
    static WINDOW_HEIGHT := 400
    
    ; Download URLs
    static PIPER_URL := "https://github.com/rhasspy/piper/releases/download/2023.11.14-2/piper_windows_amd64.zip"
    static FFMPEG_URL := "https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.7z"
    static VOICE_ONNX_URL := "https://huggingface.co/rhasspy/piper-voices/resolve/main/en/en_GB/alba/medium/en_GB-alba-medium.onnx"
    static VOICE_JSON_URL := "https://huggingface.co/rhasspy/piper-voices/resolve/main/en/en_GB/alba/medium/en_GB-alba-medium.onnx.json"
    
    ; License data for each component
    static LICENSE_DATA := Map(
        "piperAnywhere", {
            name: "piperAnywhere",
            license: "GNU General Public License v3.0",
            text: "GNU GENERAL PUBLIC LICENSE Version 3`n`n" .
                  "piperAnywhere - An annotation program designed to make users use Piper TTS to read text anywhere`n`n" .
                  "Copyright (C) 2025 yousef abdullah`n`n" .
                  "This program is free software: you can redistribute it and/or modify " .
                  "it under the terms of the GNU General Public License as published by " .
                  "the Free Software Foundation, either version 3 of the License, or " .
                  "(at your option) any later version.`n`n" .
                  "This program is distributed in the hope that it will be useful, " .
                  "but WITHOUT ANY WARRANTY; without even the implied warranty of " .
                  "MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the " .
                  "GNU General Public License for more details.`n`n" .
                  "You should have received a copy of the GNU General Public License " .
                  "along with this program. If not, see <https://www.gnu.org/licenses/>.`n`n" .
                  "✅ LICENSE COMPATIBILITY: This GPL v3 license is fully compatible with " .
                  "all dependencies (Piper TTS, eSpeak NG, FFmpeg) ensuring no licensing conflicts.`n`n" .
                  "Source code: https://github.com/yosef0H4/piperanywhere`n" .
                  "Contact: yosef00h4@gmail.com",
            category: "Main Application"
        },
        
        "piper", {
            name: "Piper TTS",
            license: "MIT License (with GPL dependencies)",
            text: "MIT License`n`n" .
                  "Copyright (c) 2022 Michael Hansen`n`n" .
                  "Permission is hereby granted, free of charge, to any person obtaining a copy " .
                  "of this software and associated documentation files (the `"Software`"), to deal " .
                  "in the Software without restriction, including without limitation the rights " .
                  "to use, copy, modify, merge, publish, distribute, sublicense, and/or sell " .
                  "copies of the Software, and to permit persons to whom the Software is " .
                  "furnished to do so, subject to the following conditions:`n`n" .
                  "The above copyright notice and this permission notice shall be included in all " .
                  "copies or substantial portions of the Software.`n`n" .
                  "THE SOFTWARE IS PROVIDED `"AS IS`", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR " .
                  "IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, " .
                  "FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE " .
                  "AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER " .
                  "LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, " .
                  "OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE " .
                  "SOFTWARE.`n`n" .
                  "⚠️ IMPORTANT: Piper depends on eSpeak NG (GPL v3) for phoneme processing. " .
                  "This dependency may affect the licensing of the combined system.`n`n" .
                  "Source: https://github.com/rhasspy/piper",
            category: "Core Software"
        },
        
        "espeak", {
            name: "eSpeak NG",
            license: "GNU General Public License v3.0",
            text: "GNU GENERAL PUBLIC LICENSE Version 3`n`n" .
                  "eSpeak NG Text-to-Speech is released under the GPL version 3 or later license.`n`n" .
                  "This program is free software: you can redistribute it and/or modify " .
                  "it under the terms of the GNU General Public License as published by " .
                  "the Free Software Foundation, either version 3 of the License, or " .
                  "(at your option) any later version.`n`n" .
                  "This program is distributed in the hope that it will be useful, " .
                  "but WITHOUT ANY WARRANTY; without even the implied warranty of " .
                  "MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the " .
                  "GNU General Public License for more details.`n`n" .
                  "⚠️ GPL REQUIREMENTS: This is a copyleft license. If you distribute software " .
                  "containing GPL components, the entire work may need to be GPL-licensed and " .
                  "source code made available.`n`n" .
                  "Full license: https://www.gnu.org/licenses/gpl-3.0.html`n" .
                  "Source: https://github.com/espeak-ng/espeak-ng",
            category: "Core Software"
        },
        
        "ffmpeg", {
            name: "FFmpeg",
            license: "GNU Lesser General Public License v2.1+",
            text: "GNU LESSER GENERAL PUBLIC LICENSE Version 2.1`n`n" .
                  "FFmpeg is licensed under the GNU Lesser General Public License (LGPL) " .
                  "version 2.1 or later. However, FFmpeg incorporates several optional parts " .
                  "and optimizations that are covered by the GNU General Public License (GPL) " .
                  "version 2 or later. If those parts get used the GPL applies to all of FFmpeg.`n`n" .
                  "LGPL COMPLIANCE REQUIREMENTS:`n" .
                  "• You must provide attribution when using FFmpeg`n" .
                  "• Source code must be made available if you distribute modified versions`n" .
                  "• This software uses libraries from the FFmpeg project under the LGPLv2.1`n`n" .
                  "ATTRIBUTION: This software uses code of FFmpeg licensed under the LGPLv2.1`n`n" .
                  "Full license: https://www.gnu.org/licenses/old-licenses/lgpl-2.1.html`n" .
                  "Source: https://github.com/FFmpeg/FFmpeg`n" .
                  "Legal info: https://ffmpeg.org/legal.html",
            category: "Media Processing"
        },
        
        "voices", {
            name: "Voice Models (Alba)",
            license: "Creative Commons Attribution 4.0 International",
            text: "Creative Commons Attribution 4.0 International (CC BY 4.0)`n`n" .
                  "The Alba voice model is licensed under CC BY 4.0.`n" .
                  "Original dataset: University of Edinburgh`n`n" .
                  "You are free to:`n" .
                  "• Share — copy and redistribute the material in any medium or format`n" .
                  "• Adapt — remix, transform, and build upon the material`n" .
                  "• Use for any purpose, even commercially`n`n" .
                  "Under the following terms:`n" .
                  "• Attribution — You must give appropriate credit, provide a link to the " .
                  "license, and indicate if changes were made. You may do so in any reasonable " .
                  "manner, but not in any way that suggests the licensor endorses you or your use.`n`n" .
                  "ATTRIBUTION:`n" .
                  "`"Alba Voice Model`" by University of Edinburgh, licensed under CC BY 4.0`n`n" .
                  "Full license: https://creativecommons.org/licenses/by/4.0/`n" .
                  "Source: https://huggingface.co/rhasspy/piper-voices/tree/main/en/en_GB/alba/medium",
            category: "Voice Models"
        }
    )
    
    __New() {
        this.currentPage := "pathselect"
        this.installPath := EnvGet("LOCALAPPDATA") . "\Programs\piperAnywhere"  ; Default installation path
        this.dependencies := Map(
            "mainApp", {status: "Not checked", exists: false, path: ""},
            "piper", {status: "Not checked", exists: false, path: ""},
            "ffmpeg", {status: "Not checked", exists: false, path: ""},
            "ffplay", {status: "Not checked", exists: false, path: ""},
            "voices", {status: "Not checked", exists: false, path: ""}
        )
        
        this.CreateGUI()
        this.ShowPathSelectPage()
    }
    
    CreateGUI() {
        this.gui := Gui("+Resize -MaximizeBox", "Piper TTS Installer v" . PiperDependenciesInstaller.VERSION)
        this.gui.BackColor := "White"
        this.gui.MarginX := 20
        this.gui.MarginY := 20
        this.gui.SetFont("s9", "Segoe UI")
        
        ; Store all controls for easy management
        this.controls := Map()
        
        ; Create all page content (initially hidden)
        this.CreatePathSelectPage()
        this.CreateWelcomePage()
        this.CreateLicensePage()
        this.CreateProgressPage()
        this.CreateCompletePage()
        
        ; Navigation buttons (always visible)
        this.CreateNavigationButtons()
        
        ; Event handlers
        this.gui.OnEvent("Close", ObjBindMethod(this, "OnClose"))
        this.gui.OnEvent("Size", ObjBindMethod(this, "OnResize"))
    }
    
    CreatePathSelectPage() {
        ; Header
        this.controls["path_header"] := this.gui.AddText("x20 y20 w460 h25 Center", "Choose Installation Location")
        this.controls["path_header"].SetFont("s12 Bold", "Segoe UI")
        
        this.controls["path_desc"] := this.gui.AddText("x20 y+10 w460 h40 Center", 
            "Select where you want to install Piper TTS and its components.")
        
        ; Installation path section
        this.controls["path_label"] := this.gui.AddText("x20 y+5 w460 h20", "Installation Path:")
        this.controls["path_label"].SetFont("s10 Bold")
        
        ; Path input with browse button
        this.controls["path_edit"] := this.gui.AddEdit("x20 y+5 w350 h25", this.installPath)
        this.controls["path_browse"] := this.gui.AddButton("x+10 yp w80 h25", "Browse...")
        this.controls["path_browse"].OnEvent("Click", ObjBindMethod(this, "BrowsePath"))
        
        ; Info text
        this.controls["path_info"] := this.gui.AddText("x20 y+10 w460 h60", 
            "• The installation path will automatically end with '\piperAnywhere'" . 
            "`n• All components (Piper TTS, FFmpeg, voice models) will be installed in this location" .
            "`n• Make sure you have write permissions to the selected folder")
        this.controls["path_info"].SetFont("s8")
        
        ; Default path warning
        this.controls["path_warning"] := this.gui.AddText("x20 y+10 w460 h25 cRed Hidden", 
            "⚠ Warning: Installing to non-standard location")
    }
    
    CreateWelcomePage() {
        ; Header
        this.controls["welcome_header"] := this.gui.AddText("x20 y20 w460 h25 Center Hidden", "Welcome to Piper TTS Installation Wizard")
        this.controls["welcome_header"].SetFont("s12 Bold", "Segoe UI")
        
        this.controls["welcome_desc"] := this.gui.AddText("x20 y+10 w460 h40 Center Hidden", 
            "This wizard will install Piper TTS, FFmpeg, and a sample voice model on your system.")
        
        ; Dependency status section
        this.controls["dep_header"] := this.gui.AddText("x20 y+20 w460 h20 Hidden", "Installation Status:")
        this.controls["dep_header"].SetFont("s10 Bold")
        
        ; Individual dependency status labels
        for name, info in this.dependencies {
            this.controls["status_" . name] := this.gui.AddText("x30 y+5 w440 h20 Hidden", 
                this.FormatDependencyName(name) . ": " . info.status)
        }
        
        ; All installed message
        this.controls["all_installed"] := this.gui.AddText("x20 y+15 w460 h25 Center Hidden", 
            "✅ All components are already installed!")
        this.controls["all_installed"].SetFont("s10 Bold cGreen")
        
        ; Installation path display
        this.controls["install_path_display"] := this.gui.AddText("x20 y+20 w460 h40 Hidden", 
            "Installation Path: " . this.installPath)
        this.controls["install_path_display"].SetFont("s9", "Consolas")
    }
    
    CreateLicensePage() {
        this.controls["license_header"] := this.gui.AddText("x20 y20 w460 h25 Hidden Center", "License Agreement")
        this.controls["license_header"].SetFont("s12 Bold")
        
        this.controls["license_text"] := this.gui.AddEdit("x20 y55 w460 h250 Hidden ReadOnly VScroll", 
            this.GetLicenseText())
        this.controls["license_text"].SetFont("s8", "Consolas")
        
        this.controls["license_accept"] := this.gui.AddCheckBox("x20 y315 w460 h20 Hidden", 
            "I accept the terms in the license agreement")
        this.controls["license_accept"].OnEvent("Click", ObjBindMethod(this, "OnLicenseAcceptChange"))
    }
    
    CreateProgressPage() {
        this.controls["progress_header"] := this.gui.AddText("x20 y20 w460 h25 Hidden Center", 
            "Installing Components")
        this.controls["progress_header"].SetFont("s12 Bold")
        
        this.controls["progress_desc"] := this.gui.AddText("x20 y55 w460 h20 Hidden Center", 
            "Please wait while the required components are downloaded and installed...")
        
        ; Main status text (larger, more prominent)
        this.controls["progress_status"] := this.gui.AddText("x20 y85 w460 h25 Hidden Center", "Preparing installation...")
        this.controls["progress_status"].SetFont("s10 Bold", "Segoe UI")
        
        ; Progress bar with better styling and green color
        this.controls["progress_bar"] := this.gui.AddProgress("x20 y115 w460 h25 Hidden Smooth Border cGreen", 5)
        this.controls["progress_bar"].Opt("Background0xF5F5F5")
        
        ; Detailed status (smaller, below progress bar)
        this.controls["progress_detail"] := this.gui.AddText("x20 y150 w460 h20 Hidden Center", "Ready to begin installation...")
        this.controls["progress_detail"].SetFont("s8", "Segoe UI")
        
        ; Activity log (scrollable)
        this.controls["progress_log"] := this.gui.AddEdit("x20 y180 w460 h130 Hidden ReadOnly VScroll", "")
        this.controls["progress_log"].SetFont("s8", "Consolas")
        this.controls["progress_log"].Opt("Background0xF5F5F5")
    }
    
    CreateCompletePage() {
        this.controls["complete_header"] := this.gui.AddText("x20 y20 w460 h25 Hidden Center", 
            "Installation Complete")
        this.controls["complete_header"].SetFont("s12 Bold cGreen")
        
        this.controls["complete_desc"] := this.gui.AddText("x20 y55 w460 h60 Hidden Center", 
            "Piper TTS has been successfully installed on your system." .
            "`n`nYou can now use Piper TTS for text-to-speech conversion.")
        
        
        
        ; Desktop shortcut checkbox
        this.controls["complete_shortcut"] := this.gui.AddCheckBox("x20 y+20 w460 h20 Hidden Checked", 
            "Create desktop shortcut")
        
        this.controls["complete_startmenu"] := this.gui.AddCheckBox("x20 y+5 w460 h20 Hidden Checked", 
            "Add to Start Menu")
        
        this.controls["complete_launch"] := this.gui.AddCheckBox("x20 y+10 w460 h20 Hidden Checked", 
            "Launch piperAnywhere now")
    }
    
    CreateNavigationButtons() {
        ; Bottom button panel with more space
        this.controls["button_line"] := this.gui.AddText("x0 y340 w500 h1 0x10")  ; Horizontal line
        
        this.controls["btn_back"] := this.gui.AddButton("x240 y355 w70 h25 Disabled", "&Back")
        this.controls["btn_back"].OnEvent("Click", ObjBindMethod(this, "GoBack"))
        
        this.controls["btn_next"] := this.gui.AddButton("x320 y355 w70 h25", "&Next >")
        this.controls["btn_next"].OnEvent("Click", ObjBindMethod(this, "GoNext"))
        
        this.controls["btn_cancel"] := this.gui.AddButton("x400 y355 w70 h25", "Cancel")
        this.controls["btn_cancel"].OnEvent("Click", ObjBindMethod(this, "OnClose"))
    }
    
    ; Page Management Methods
    ShowPathSelectPage() {
        this.HideAllPages()
        this.controls["path_header"].Visible := true
        this.controls["path_desc"].Visible := true
        this.controls["path_label"].Visible := true
        this.controls["path_edit"].Visible := true
        this.controls["path_browse"].Visible := true
        this.controls["path_info"].Visible := true
        
        ; Show warning if using script directory
        if (this.installPath = A_ScriptDir . "\piperAnywhere") {
            this.controls["path_warning"].Visible := true
        } else {
            this.controls["path_warning"].Visible := false
        }
        
        this.controls["btn_back"].Enabled := false
        this.controls["btn_next"].Enabled := true
        this.controls["btn_next"].Text := "&Next >"
        this.currentPage := "pathselect"
        
        ; Update path edit control
        this.controls["path_edit"].Text := this.installPath
    }
    
    ShowWelcomePage() {
        this.HideAllPages()
        this.controls["welcome_header"].Visible := true
        this.controls["welcome_desc"].Visible := true
        this.controls["dep_header"].Visible := true
        this.controls["install_path_display"].Visible := true
        
        for name, info in this.dependencies {
            this.controls["status_" . name].Visible := true
        }
        
        if (this.AllDependenciesInstalled()) {
            this.controls["all_installed"].Visible := true
            this.controls["btn_next"].Text := "&Finish"
        } else {
            this.controls["all_installed"].Visible := false
            this.controls["btn_next"].Text := "&Next >"
        }
        
        this.controls["btn_back"].Enabled := false
        this.controls["btn_next"].Enabled := true
        this.currentPage := "welcome"
        this.UpdateDependencyDisplay()
        
        ; Update installation path display
        this.controls["install_path_display"].Text := "Installation Path: " . this.installPath
    }
    
    ShowLicensePage() {
        this.HideAllPages()
        
        componentsToInstall := this.GetComponentsToInstall()
        
        ; Update header to show what's being licensed
        headerText := "License Agreement"
        if (componentsToInstall.Length > 0) {
            headerText .= " (" . componentsToInstall.Length . " component" . (componentsToInstall.Length > 1 ? "s" : "") . ")"
        }
        
        this.controls["license_header"].Text := headerText
        this.controls["license_header"].Visible := true
        this.controls["license_text"].Text := this.GetLicenseText()
        this.controls["license_text"].Visible := true
        this.controls["license_accept"].Text := "I accept the license terms for the components being installed"
        this.controls["license_accept"].Visible := true
        
        this.controls["btn_back"].Enabled := true
        this.controls["btn_next"].Enabled := this.controls["license_accept"].Value
        
        ; Update button text based on whether installation is needed
        if (this.AllDependenciesInstalled()) {
            this.controls["btn_next"].Text := "&Accept"
        } else {
            this.controls["btn_next"].Text := "&Install"
        }
        
        this.currentPage := "license"
    }
    
    ShowProgressPage() {
        this.HideAllPages()
        this.controls["progress_header"].Visible := true
        this.controls["progress_desc"].Visible := true
        this.controls["progress_status"].Visible := true
        this.controls["progress_bar"].Visible := true
        this.controls["progress_detail"].Visible := true
        this.controls["progress_log"].Visible := true
        
        this.controls["btn_back"].Enabled := false
        this.controls["btn_next"].Enabled := false
        this.controls["btn_next"].Text := "Installing..."
        this.controls["btn_cancel"].Enabled := false
        this.currentPage := "progress"
        
        ; Set initial progress state
        this.controls["progress_bar"].Value := 5
        this.controls["progress_detail"].Text := "Initializing installation process..."
        
        ; Start installation process
        SetTimer(ObjBindMethod(this, "StartInstallation"), -100)
    }
    
    ShowCompletePage() {
        this.HideAllPages()
        this.controls["complete_header"].Visible := true
        this.controls["complete_desc"].Visible := true
        this.controls["complete_shortcut"].Visible := true
        this.controls["complete_startmenu"].Visible := true
        this.controls["complete_launch"].Visible := true
        
        this.controls["btn_back"].Enabled := false
        this.controls["btn_next"].Enabled := true
        this.controls["btn_next"].Text := "&Finish"
        this.controls["btn_cancel"].Enabled := true
        this.currentPage := "complete"
    }
    
    HideAllPages() {
        for name, ctrl in this.controls {
            if (InStr(name, "btn_") != 1 && name != "button_line") {
                ctrl.Visible := false
            }
        }
    }
    
    ; Navigation Event Handlers
    GoNext(*) {
        switch this.currentPage {
            case "pathselect":
                this.ValidateAndSetPath()
                this.ShowWelcomePage()
            case "welcome":
                if (this.AllDependenciesInstalled()) {
                    this.CleanUpDownloadsFolder()
                    this.OnClose()
                } else {
                    this.ShowLicensePage()
                }
            case "license":
                this.ShowProgressPage()
            case "progress":
                ; Should not be clickable during progress
            case "complete":
                ; Create desktop shortcut if requested
                if (this.controls["complete_shortcut"].Value) {
                    this.CreateDesktopShortcut()
                }
                if (this.controls["complete_startmenu"].Value) {
                    this.CreateStartMenuShortcut()
                }
                ; Launch application if requested
                if (this.controls["complete_launch"].Value) {
                    this.LaunchApplication()
                }
                this.OnClose()
        }
    }
    
    GoBack(*) {
        switch this.currentPage {
            case "welcome":
                this.ShowPathSelectPage()
            case "license":
                this.ShowWelcomePage()
            case "progress":
                ; Should not be able to go back during installation
        }
    }
    
    OnLicenseAcceptChange(*) {
        this.controls["btn_next"].Enabled := this.controls["license_accept"].Value
    }
    
    ; Dependency Checking
    CheckDependencies() {
        for name, info in this.dependencies {
            switch name {
                case "mainApp":
                    info.exists := FileExist(info.path) ? true : false
                case "piper":
                    info.exists := this.CheckExecutable(info.path, "piper --version", "Piper")
                case "ffmpeg":
                    info.exists := this.CheckExecutable(info.path, "ffmpeg -version", "FFmpeg")
                case "ffplay":
                    info.exists := this.CheckExecutable(info.path, "ffplay -version", "FFplay")
                case "voices":
                    info.exists := this.CheckVoicesDirectory(info.path)
            }
            info.status := info.exists ? "✅ Installed" : "❌ Not Found"
        }
    }
    
    CheckExecutable(localPath, systemCommand, name) {
        ; Check local path first
        if (FileExist(localPath)) {
            try {
                RunWait('"' . localPath . '" --version', , "Hide")
                return true
            } catch {
                ; Continue to system check
            }
        }
        
        ; Check system PATH
        try {
            RunWait(systemCommand, , "Hide")
            return true
        } catch {
            return false
        }
    }
    
    CheckVoicesDirectory(path) {
        if (!DirExist(path)) {
            return false
        }
        
        ; Check for .onnx and .onnx.json files
        onnxExists := false
        jsonExists := false
        
        Loop Files, path . "\*.onnx" {
            onnxExists := true
            break
        }
        
        Loop Files, path . "\*.onnx.json" {
            jsonExists := true
            break
        }
        
        return onnxExists && jsonExists
    }
    
    AllDependenciesInstalled() {
        for name, info in this.dependencies {
            if (!info.exists) {
                return false
            }
        }
        return true
    }
    
    UpdateDependencyDisplay() {
        for name, info in this.dependencies {
            if (this.controls.Has("status_" . name)) {
                this.controls["status_" . name].Text := this.FormatDependencyName(name) . ": " . info.status
            }
        }
    }
    
    FormatDependencyName(name) {
        switch name {
            case "mainApp": return "piperAnywhere"
            case "piper": return "Piper TTS"
            case "ffmpeg": return "FFmpeg"
            case "ffplay": return "FFplay"
            case "voices": return "Voice Models"
            default: return name
        }
    }
    
    ; Installation Process
    StartInstallation() {
        this.installStep := 0
        this.totalSteps := 0
        
        ; Count steps needed
        for name, info in this.dependencies {
            if (!info.exists) {
                switch name {
                    case "mainApp": this.totalSteps += 1  ; just copy the executable
                    case "piper": this.totalSteps += 3  ; download, extract, move
                    case "ffmpeg", "ffplay": this.totalSteps += 3  ; download, extract, move (counted once)
                    case "voices": this.totalSteps += 2  ; download both files
                }
            }
        }
        
        ; Adjust for ffmpeg/ffplay being handled together
        if (!this.dependencies["ffmpeg"].exists || !this.dependencies["ffplay"].exists) {
            this.totalSteps -= 3  ; Remove double count
        }
        
        this.totalSteps += 1  ; Cleanup step
        
        this.LogProgress("Starting installation process...")
        try {
            this.InstallNextComponent()
        } finally {
            this.CleanUpDownloadsFolder()
        }
    }
    
    InstallNextComponent() {
        ; Install the main application
        if (!this.dependencies["mainApp"].exists && !this.Get("mainAppInstalled", false)) {
            this.InstallMainApplication()
            return
        }
        
        ; Install the main application
        if (!this.Get("mainAppInstalled", false)) {
            this.InstallMainApplication()
            return
        }
        
        ; Install Piper
        if (!this.dependencies["piper"].exists && !this.Get("piperInstalled", false)) {
            this.InstallPiper()
            return
        }
        
        ; Install FFmpeg (handles both ffmpeg and ffplay)
        if ((!this.dependencies["ffmpeg"].exists || !this.dependencies["ffplay"].exists) && !this.Get("ffmpegInstalled", false)) {
            this.InstallFFmpeg()
            return
        }
        
        ; Install voices
        if (!this.dependencies["voices"].exists && !this.Get("voicesInstalled", false)) {
            this.InstallVoices()
            return
        }
        
        ; Cleanup and finish
        this.CleanupAndFinish()
        this.ShowCompletePage()
    }
    
    InstallMainApplication() {
        this.controls["progress_status"].Text := "Installing Main Application..."
        this.UpdateProgress(this.installStep++, "Installing piperAnywhere.exe...")

        try {
            ; This will bundle piperAnywhere.exe into the compiled installer
            ; and extract it to the installation path.
            DirCreate(this.installPath)
            FileInstall "piperAnywhere.exe", this.installPath . "\piperAnywhere.exe", 1
            this.Set("mainAppInstalled", true)
            this.LogProgress("✅ Main application (piperAnywhere.exe) installed successfully.")
        } catch as e {
            this.LogProgress("❌ Error installing main application: " . e.Message)
            this.ShowError("Failed to install piperAnywhere.exe", e.Message)
            return
        }
        this.InstallNextComponent()
    }
    
    InstallPiper() {
        this.controls["progress_status"].Text := "Installing Piper TTS..."
        this.UpdateProgress(this.installStep++, "Preparing Piper TTS download...")
        
        downloadDir := this.installPath . "\downloads"
        DirCreate(downloadDir)
        piperZip := downloadDir . "\piper_windows_amd64.zip"
        
        try {
            ; Download step
            this.DownloadFile(PiperDependenciesInstaller.PIPER_URL, piperZip, "Piper TTS")
            
            ; Extract step
            this.controls["progress_status"].Text := "Extracting Piper TTS..."
            this.UpdateProgress(this.installStep++, "Extracting Piper TTS archive...")
            
            ; Extract using tar (native Windows command)
            RunWait('tar -xf "' . piperZip . '" -C "' . downloadDir . '"', , "Hide")
            this.LogProgress("Piper TTS archive extracted successfully.")
            
            ; Install step
            this.controls["progress_status"].Text := "Installing Piper TTS..."
            this.UpdateProgress(this.installStep++, "Installing Piper TTS to " . this.installPath . "...")
            
            ; Move to final location
            extractedDir := downloadDir . "\piper"
            targetDir := this.installPath . "\piper"
            
            
            ; Ensure parent directory exists
            SplitPath(targetDir, , &parentDir)
            DirCreate(parentDir)
            DirMove(extractedDir, targetDir, 2)
            
            this.Set("piperInstalled", true)
            this.LogProgress("✅ Piper TTS installed successfully to: " . targetDir)
            
        } catch as e {
            this.LogProgress("❌ Error installing Piper: " . e.Message)
            this.ShowError("Failed to install Piper TTS", e.Message)
            return
        }
        
        this.InstallNextComponent()
    }
    
    InstallFFmpeg() {
        this.controls["progress_status"].Text := "Installing FFmpeg..."
        this.UpdateProgress(this.installStep++, "Preparing FFmpeg download...")
        
        downloadDir := this.installPath . "\downloads"
        DirCreate(downloadDir)
        ffmpegArchive := downloadDir . "\ffmpeg-release-essentials.7z"
        
        try {
            ; Download step
            this.DownloadFile(PiperDependenciesInstaller.FFMPEG_URL, ffmpegArchive, "FFmpeg")
            
            ; Extract step
            this.controls["progress_status"].Text := "Extracting FFmpeg..."
            this.UpdateProgress(this.installStep++, "Extracting FFmpeg archive...")
            
            ; Extract using tar (supports 7z format)
            RunWait('tar -xf "' . ffmpegArchive . '" -C "' . downloadDir . '"', , "Hide")
            this.LogProgress("FFmpeg archive extracted successfully.")
            
            ; Install step
            this.controls["progress_status"].Text := "Installing FFmpeg..."
            this.UpdateProgress(this.installStep++, "Installing FFmpeg to " . this.installPath . "...")
            
            ; Find extracted directory (name may vary)
            extractedDir := ""
            Loop Files, downloadDir . "\ffmpeg-*", "D" {
                extractedDir := A_LoopFileFullPath
                this.LogProgress("Found extracted directory: " . A_LoopFileName)
                break
            }
            
            if (!extractedDir) {
                throw Error("Could not find extracted FFmpeg directory")
            }
            
            ; Move to final location
            targetDir := this.installPath . "\ffmpeg"
            if (DirExist(targetDir)) {
                DirDelete(targetDir, true)
                this.LogProgress("Removed existing FFmpeg installation.")
            }
            ; Ensure parent directory exists
            SplitPath(targetDir, , &parentDir)
            DirCreate(parentDir)
            DirMove(extractedDir, targetDir, 2)
            
            this.Set("ffmpegInstalled", true)
            this.LogProgress("✅ FFmpeg installed successfully to: " . targetDir)
            
        } catch as e {
            this.LogProgress("❌ Error installing FFmpeg: " . e.Message)
            this.ShowError("Failed to install FFmpeg", e.Message)
            return
        }
        
        this.InstallNextComponent()
    }
    
    InstallVoices() {
        this.controls["progress_status"].Text := "Installing voice models..."
        this.UpdateProgress(this.installStep++, "Preparing voice model downloads...")
        
        downloadDir := this.installPath . "\downloads"
        voicesDir := this.installPath . "\voices"
        DirCreate(downloadDir)
        DirCreate(voicesDir)
        
        try {
            ; Download both voice files
            onnxFile := downloadDir . "\en_GB-alba-medium.onnx"
            jsonFile := downloadDir . "\en_GB-alba-medium.onnx.json"
            
            this.controls["progress_status"].Text := "Downloading voice model..."
            this.DownloadFile(PiperDependenciesInstaller.VOICE_ONNX_URL, onnxFile, "Voice Model (.onnx)")
            
            this.controls["progress_status"].Text := "Downloading voice configuration..."
            this.DownloadFile(PiperDependenciesInstaller.VOICE_JSON_URL, jsonFile, "Voice Config (.json)")
            
            this.controls["progress_status"].Text := "Installing voice files..."
            this.UpdateProgress(this.installStep++, "Moving voice files to final location...")
            
            ; Move files to voices directory
            FileMove(onnxFile, voicesDir . "\en_GB-alba-medium.onnx", 1)
            FileMove(jsonFile, voicesDir . "\en_GB-alba-medium.onnx.json", 1)
            
            this.Set("voicesInstalled", true)
            this.LogProgress("✅ Voice models installed successfully to: " . voicesDir)
            this.LogProgress("   • en_GB-alba-medium.onnx")
            this.LogProgress("   • en_GB-alba-medium.onnx.json")
            
        } catch as e {
            this.LogProgress("❌ Error installing voices: " . e.Message)
            this.ShowError("Failed to install voice models", e.Message)
            return
        }
        
        this.InstallNextComponent()
    }
    
    CleanupAndFinish() {
        this.UpdateProgress(this.installStep++, "Cleaning up temporary files...")
        this.controls["progress_detail"].Text := "Removing temporary download files..."
        
        ; Create the main program's LICENSE file
        this.CreateMainLicenseFile()
        
        ; Final progress update - ensure we hit exactly 100%
        this.controls["progress_bar"].Value := 100
        this.controls["progress_status"].Text := "Installation completed successfully!"
        this.controls["progress_detail"].Text := "100% complete - All components installed to " . this.installPath
        this.LogProgress("🎉 Installation completed successfully!")
        this.LogProgress("All required components have been installed to: " . this.installPath)
        
        ; Re-check dependencies
        this.CheckDependencies()
    }
    
    CleanUpDownloadsFolder() {
        try {
            downloadDir := this.installPath . "\downloads"
            if (DirExist(downloadDir)) {
                DirDelete(downloadDir, true)
                this.LogProgress("Temporary files cleaned up successfully.")
            }
        } catch as e {
            this.LogProgress("Warning: Could not clean up download directory: " . e.Message)
        }
    }
    
    ; Utility Methods
    DownloadFile(url, destination, description) {
        this.controls["progress_status"].Text := "Downloading " . description . "..."
        this.LogProgress("Starting download: " . description)
        
        ; Show file size info if possible
        if (InStr(description, "Piper")) {
            this.controls["progress_detail"].Text := "Downloading " . description . " (~15MB)..."
        } else if (InStr(description, "FFmpeg")) {
            this.controls["progress_detail"].Text := "Downloading " . description . " (~50MB)..."
        } else {
            this.controls["progress_detail"].Text := "Downloading " . description . "..."
        }
        
        try {
            Download(url, destination)
            this.LogProgress("Download completed: " . description)
        } catch as e {
            this.LogProgress("Download failed: " . description . " - " . e.Message)
            throw Error("Failed to download " . description . ": " . e.Message)
        }
    }
    
    UpdateProgress(step, message) {
        ; Calculate progress with 5% starting point, scaling 5-100%
        progress := 5 + Round(((step / this.totalSteps) * 95))
        this.controls["progress_bar"].Value := progress
        this.controls["progress_status"].Text := message
        this.controls["progress_detail"].Text := progress . "% complete (" . step . "/" . this.totalSteps . " steps)"
        
        ; Add to log as well
        this.LogProgress(message)
    }
    
    LogProgress(message) {
        timestamp := FormatTime(A_Now, "HH:mm:ss")
        logEntry := "[" . timestamp . "] " . message . "`n"
        this.controls["progress_log"].Text := this.controls["progress_log"].Text . logEntry
        
        ; Auto-scroll to bottom
        PostMessage(0x0115, 7, 0, this.controls["progress_log"].Hwnd) ; WM_VSCROLL, SB_BOTTOM
    }
    
    ShowError(title, message) {
        MsgBox(message, title, "16")  ; Error icon
        this.controls["btn_cancel"].Enabled := true
        this.controls["btn_next"].Text := "Retry"
        this.controls["btn_next"].Enabled := true
    }
    
    ; Simple property storage for installation state
    static properties := Map()
    
    Set(key, value) {
        PiperDependenciesInstaller.properties[key] := value
    }
    
    Get(key, default := "") {
        return PiperDependenciesInstaller.properties.Get(key, default)
    }
    
    ; Event Handlers
    OnResize(gui, minMax, width, height) {
        if (minMax = -1)  ; Minimized
            return
        
        ; Adjust button positions
        buttonY := height - 45
        this.controls["button_line"].Move(0, height - 50, width)
        this.controls["btn_back"].Move(width - 260, buttonY)
        this.controls["btn_next"].Move(width - 180, buttonY)
        this.controls["btn_cancel"].Move(width - 100, buttonY)
        
        ; Adjust content width for most controls, but handle path controls specially
        contentWidth := width - 40
        editWidth := contentWidth - 100  ; Leave space for browse button
        
        for name, ctrl in this.controls {
            if (name = "path_edit") {
                ; Special handling for path edit - leave space for browse button
                ctrl.Move(, , editWidth)
            } else if (name = "path_browse") {
                ; Move browse button to the right of the edit box
                ctrl.Move(30 + editWidth, , 80)
            } else if (InStr(name, "btn_") != 1 && name != "button_line" && name != "path_edit" && name != "path_browse") {
                ; All other controls get full width
                ctrl.Move(, , contentWidth)
            }
        }
    }
    
    OnClose(*) {
        if (this.currentPage = "progress") {
            result := MsgBox("Installation is in progress. Are you sure you want to cancel?", 
                            "Cancel Installation", "YesNo Icon?")
            if (result = "No") {
                return
            }
            this.CleanUpDownloadsFolder() ; Clean up on user cancellation
        }
        ExitApp()
    }
    
    Show() {
        this.gui.Show("w" . PiperDependenciesInstaller.WINDOW_WIDTH . " h" . PiperDependenciesInstaller.WINDOW_HEIGHT)
    }
    
    ; Get components that need to be installed
    GetComponentsToInstall() {
        componentsToInstall := []
        
        ; Always include the main program license
        componentsToInstall.Push("piperAnywhere")
        
        ; Map dependencies to license components
        if (!this.dependencies["piper"].exists) {
            componentsToInstall.Push("piper")
            componentsToInstall.Push("espeak")  ; Piper always requires espeak
        }
        
        if (!this.dependencies["ffmpeg"].exists || !this.dependencies["ffplay"].exists) {
            componentsToInstall.Push("ffmpeg")
        }
        
        if (!this.dependencies["voices"].exists) {
            componentsToInstall.Push("voices")
        }
        
        return componentsToInstall
    }
    
    ; Generate dynamic license text based on what's being installed
    GetLicenseText() {
        componentsToInstall := this.GetComponentsToInstall()
        
        ; Always show at least the main program license
        if (componentsToInstall.Length <= 1) {  ; Only piperAnywhere in the list
            licenseText := "SOFTWARE LICENSE AGREEMENT`n`n" .
                          "This installer uses piperAnywhere, which is licensed under GPL v3:`n`n"
        } else {
            licenseText := "SOFTWARE LICENSE AGREEMENT`n`n" .
                          "This installer includes piperAnywhere and will download the following additional components:`n`n"
        }
        
        ; Add component list
        for component in componentsToInstall {
            if (PiperDependenciesInstaller.LICENSE_DATA.Has(component)) {
                licenseInfo := PiperDependenciesInstaller.LICENSE_DATA[component]
                licenseText .= "• " . licenseInfo.name . " (" . licenseInfo.license . ")`n"
            }
        }
        
        licenseText .= "`nLicensing terms for each component:`n`n"
        
        ; Add individual license sections
        for component in componentsToInstall {
            if (PiperDependenciesInstaller.LICENSE_DATA.Has(component)) {
                licenseInfo := PiperDependenciesInstaller.LICENSE_DATA[component]
                
                licenseText .= "═══════════════════════════════════════════════════════════════════════`n"
                licenseText .= licenseInfo.category . ": " . licenseInfo.name . "`n"
                licenseText .= "═══════════════════════════════════════════════════════════════════════`n"
                licenseText .= licenseInfo.text . "`n`n"
            }
        }
        
        ; Add combined licensing notice if GPL components are included
        hasGPL := false
        for component in componentsToInstall {
            if (component = "piper" || component = "espeak") {
                hasGPL := true
                break
            }
        }
        
        if (hasGPL) {
            licenseText .= "═══════════════════════════════════════════════════════════════════════`n"
            licenseText .= "IMPORTANT LICENSING NOTICE`n"
            licenseText .= "═══════════════════════════════════════════════════════════════════════`n"
            licenseText .= "This installation includes GPL v3 licensed components (eSpeak NG), which " .
                          "may affect the licensing of the combined system:`n`n " .
                          "• If you redistribute this software bundle, you may need to provide source code`n" .
                          "• Commercial distribution may require compliance with GPL v3 terms`n" .
                          "• The GPL is a `"copyleft`" license that can extend to derivative works`n`n" .
                          "For commercial use or redistribution, consult with legal counsel to ensure compliance.`n`n"
        }
        
        licenseText .= "BY PROCEEDING WITH INSTALLATION, YOU ACKNOWLEDGE THAT YOU HAVE READ AND " .
                      "UNDERSTOOD THE LICENSING TERMS OF THE COMPONENTS BEING INSTALLED AND AGREE " .
                      "TO COMPLY WITH THE APPLICABLE LICENSE REQUIREMENTS."
        
        return licenseText
    }
    
    ; Add method to get attribution text for all components (including main program)
    GetAttributionText() {
        componentsToInstall := this.GetComponentsToInstall()
        attributionText := "piperAnywhere - Text-to-Speech Annotation Tool`n" .
                          "Copyright (C) 2025 yousef abdullah`n`n" .
                          "This software is licensed under GPL v3 and includes these components:`n`n"
        
        for component in componentsToInstall {
            if (PiperDependenciesInstaller.LICENSE_DATA.Has(component)) {
                licenseInfo := PiperDependenciesInstaller.LICENSE_DATA[component]
                attributionText .= "• " . licenseInfo.name . " (" . licenseInfo.license . ")`n"
            }
        }
        
        ; Add specific attribution requirements
        for component in componentsToInstall {
            switch component {
                case "ffmpeg":
                    attributionText .= "`nFFmpeg Attribution: This software uses libraries from the FFmpeg project under the LGPLv2.1`n"
                case "voices":
                    attributionText .= "`nVoice Model Attribution: Alba Voice Model by University of Edinburgh, licensed under CC BY 4.0`n"
            }
        }
        
        attributionText .= "`nFor complete license terms, see the LICENSE files in the installation directory."
        
        return attributionText
    }
    
    ; Create LICENSE file for main program
    CreateMainLicenseFile() {
        try {
            licenseContent := PiperDependenciesInstaller.LICENSE_DATA["piperAnywhere"].text
            FileAppend(licenseContent, this.installPath . "\LICENSE", "UTF-8")
            this.LogProgress("Created main program LICENSE file")
        } catch as e {
            this.LogProgress("Warning: Could not create LICENSE file: " . e.Message)
        }
    }
    
    ; Path Selection Methods
    BrowsePath(*) {
        ; Get initial directory (parent of current install path)
        currentPath := this.controls["path_edit"].Text
        if (currentPath && DirExist(currentPath)) {
            initialDir := currentPath
        } else {
            ; Use parent directory or C:\ as fallback
            SplitPath(currentPath, , &parentDir)
            initialDir := (parentDir && DirExist(parentDir)) ? parentDir : "C:\"
        }
        
        selectedFolder := FileSelect("D", initialDir, "Select a folder")
        if (selectedFolder) {
            ; Ensure the path ends with \piperAnywhere
            if (!RegExMatch(selectedFolder, "\\piperAnywhere$", &match)) {
                selectedFolder := selectedFolder . "\piperAnywhere"
            }
            this.controls["path_edit"].Text := selectedFolder
        }
    }
    
    ValidateAndSetPath() {
        newPath := this.controls["path_edit"].Text
        ; Ensure path ends with \piperAnywhere
        if (!RegExMatch(newPath, "\\piperAnywhere$", &match)) {
            newPath := newPath . "\piperAnywhere"
        }
        this.installPath := newPath
        this.UpdateDependencyPaths()
        this.CheckDependencies()
    }
    
    UpdateDependencyPaths() {
        this.dependencies["mainApp"].path := this.installPath . "\piperAnywhere.exe"
        this.dependencies["piper"].path := this.installPath . "\piper\piper.exe"
        this.dependencies["ffmpeg"].path := this.installPath . "\ffmpeg\bin\ffmpeg.exe"
        this.dependencies["ffplay"].path := this.installPath . "\ffmpeg\bin\ffplay.exe"
        this.dependencies["voices"].path := this.installPath . "\voices"
    }
    
    ; Create desktop shortcut for piperAnywhere
    CreateDesktopShortcut() {
        try {
            targetExe := this.installPath . "\piperAnywhere.exe"
            shortcutPath := A_Desktop . "\piperAnywhere.lnk"
            
            ; Only create shortcut if the target executable exists
            if (!FileExist(targetExe)) {
                MsgBox("Cannot create desktop shortcut - piperAnywhere.exe not found at:`n" . targetExe, 
                       "Shortcut Creation Failed", "48")  ; Warning icon
                return
            }
            
            ; Create the desktop shortcut
            FileCreateShortcut(targetExe, shortcutPath, this.installPath, "", 
                "piperAnywhere - Text-to-Speech Annotation Tool", targetExe, "", 1, 1)
            
        } catch as e {
            MsgBox("Could not create desktop shortcut:`n" . e.Message, "Shortcut Creation Failed", "16")  ; Error icon
        }
    }
    
    ; Create Start Menu shortcut for piperAnywhere
    CreateStartMenuShortcut() {
        try {
            targetExe := this.installPath . "\piperAnywhere.exe"
            
            ; Only create shortcut if the target executable exists
            if (!FileExist(targetExe)) {
                MsgBox("Cannot create Start Menu shortcut - piperAnywhere.exe not found at:`n" . targetExe, 
                       "Shortcut Creation Failed", "48")  ; Warning icon
                return
            }
            
            ; Create directory if it doesn't exist
            startMenuDir := A_Programs . "\piperAnywhere"
            if (!DirExist(startMenuDir)) {
                DirCreate(startMenuDir)
            }
            
            shortcutPath := startMenuDir . "\piperAnywhere.lnk"
            
            ; Create the Start Menu shortcut
            FileCreateShortcut(targetExe, shortcutPath, this.installPath, "", 
                "piperAnywhere - Text-to-Speech Annotation Tool", targetExe, "", 1, 1)
        } catch as e {
            MsgBox("Could not create Start Menu shortcut:`n" . e.Message, "Shortcut Creation Failed", "16")  ; Error icon
        }
    }
    
    ; Launch piperAnywhere application
    LaunchApplication() {
        try {
            targetExe := this.installPath . "\piperAnywhere.exe"
            
            ; Only launch if the executable exists
            if (FileExist(targetExe)) {
                Run('"' . targetExe . '"', this.installPath)
            } else {
                MsgBox("Cannot launch piperAnywhere - executable not found at:`n" . targetExe, "Launch Failed", "48")
            }
        } catch as e {
            MsgBox("Could not launch piperAnywhere:`n" . e.Message, "Launch Failed", "16")
        }
    }
}

; Create and show the installer
try {
    installer := PiperDependenciesInstaller()
    installer.Show()
} catch as e {
    MsgBox("Failed to start installer: " . e.Message, "Error", "16")
    ExitApp()
}