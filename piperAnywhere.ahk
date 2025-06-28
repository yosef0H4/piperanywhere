#Requires AutoHotkey v2
#include "Lib\OCR.ahk"
#include "src\RectangleCreator.ahk"
#include "src\Highlighter.ahk"
#include "src\AudioSettings.ahk"
#include "src\VoiceManager.ahk"
#include "src\TTSPlayer.ahk"
#include "src\UIManager.ahk"
#include "src\HotkeyManager.ahk"
#include "src\DependencyChecker.ahk"  ; Add the new dependency checker

; --- Global Settings ---
CoordMode "Mouse", "Screen"
CoordMode "ToolTip", "Screen"
DllCall("SetThreadDpiAwarenessContext", "ptr", -3)
SetCapsLockState("AlwaysOff")
CapsLock::SetCapsLockState("AlwaysOff")

; --- Main Application Class ---
class PiperTTSApp {
    
    __New() {
        this.settingsFile := A_ScriptDir "\piper_settings.ini"
        
        ; Initialize dependency checker first
        this.dependencyChecker := DependencyChecker()
        
        ; Check dependencies before initializing other components
        if (!this.CheckDependencies()) {
            ExitApp()
        }
        
        ; Initialize all components
        this.audioSettings := AudioSettings()
        
        ; Update audio settings with correct executable paths
        this.UpdateAudioSettingsPaths()
        
        this.voiceManager := VoiceManager()
        this.ttsPlayer := TTSPlayer(this.audioSettings, this.voiceManager)
        this.ocrHandler := OCRHandler()
        this.uiManager := UIManager(this, this.audioSettings, this.voiceManager, this.ttsPlayer, this.ocrHandler)
        this.hotkeyManager := HotkeyManager(this.ttsPlayer, this.ocrHandler, this.uiManager)
        
        ; Setup GUI and show
        this.uiManager.CreateGUI()
        this.voiceManager.PopulateVoices(this.uiManager.voiceDropdown, this.uiManager.statusLabel)
        this.LoadSettings()
        this.uiManager.UpdateQualityInfo()
        this.ShowStartupInfo()
        this.uiManager.ShowGUI()
    }
    
    __Delete() {
        ; Cleanup resources
        if (this.ttsPlayer)
            this.ttsPlayer.Cleanup()
    }
    
    ; Check all dependencies at startup
    CheckDependencies() {
        try {
            return this.dependencyChecker.CheckAllDependencies()
        } catch as err {
            MsgBox("Error checking dependencies: " . err.Message . "`n`nThe application will exit.", "Dependency Check Error", "Iconx")
            return false
        }
    }
    
    ; Update AudioSettings with the correct executable paths
    UpdateAudioSettingsPaths() {
        piperPath := this.dependencyChecker.GetDependencyPath("piper")
        ffmpegPath := this.dependencyChecker.GetDependencyPath("ffmpeg")
        ffplayPath := this.dependencyChecker.GetDependencyPath("ffplay")
        
        this.audioSettings.SetExecutablePaths(piperPath, ffmpegPath, ffplayPath)
    }
    
    ; Show startup information with dependency status
    ShowStartupInfo() {
        summary := this.dependencyChecker.GetDependencySummary()
        
        ; Update UI with dependency info
        this.uiManager.controls.statusLabel.Text := "✅ All dependencies found - Ready to use!"
        
        ; Optionally show detailed summary (uncomment if needed)
        ; MsgBox(summary, "Dependency Status", "Iconi")
    }
    
    ; Show dependency information (can be called from UI)
    ShowDependencyInfo() {
        summary := this.dependencyChecker.GetDependencySummary()
        
        ; Add validation info
        validation := this.audioSettings.ValidatePaths()
        if (!validation.valid) {
            summary .= "⚠️ Path Validation Issues:`n"
            for issue in validation.missing {
                summary .= "• " . issue . "`n"
            }
        } else {
            summary .= "✅ All paths validated successfully!"
        }
        
        MsgBox(summary, "Dependency Information", "Iconi")
    }
    
    SaveSettings() {
        try {
            IniWrite(this.uiManager.controls.voiceDropdown.Value, this.settingsFile, "Settings", "VoiceIndex")
            IniWrite(this.audioSettings.speechSpeed, this.settingsFile, "Settings", "SpeechSpeed")
            IniWrite(this.audioSettings.volumeBoost, this.settingsFile, "Settings", "Volume")
            IniWrite(this.audioSettings.useAudioEnhancement, this.settingsFile, "Settings", "Enhancement")
            IniWrite(this.uiManager.controls.textBox.Text, this.settingsFile, "Settings", "LastText")
            IniWrite(this.uiManager.controls.languageDropdown.Value, this.settingsFile, "Settings", "LanguageIndex")
            IniWrite(this.audioSettings.minWordsPerSentence, this.settingsFile, "Settings", "MinWords")
            IniWrite(this.audioSettings.maxWordsPerSentence, this.settingsFile, "Settings", "MaxWords")
        } catch as err {
            ; Optional: MsgBox("Error saving settings: " . err.Message, "Save Error", "Iconx")
        }
    }

    LoadSettings() {
        
            ; Read settings with defaults matching AudioSettings.__New() and UIManager initial text
            lastText := IniRead(this.settingsFile, "Settings", "LastText", this.uiManager.GetText("defaultText"))
            voiceIndex := IniRead(this.settingsFile, "Settings", "VoiceIndex", 1)
            speechSpeed := IniRead(this.settingsFile, "Settings", "SpeechSpeed", 1.0)
            volume := IniRead(this.settingsFile, "Settings", "Volume", 2)
            enhancement := IniRead(this.settingsFile, "Settings", "Enhancement", true)
            languageIndex := IniRead(this.settingsFile, "Settings", "LanguageIndex", 1)
            minWords := IniRead(this.settingsFile, "Settings", "MinWords", 6)
            maxWords := IniRead(this.settingsFile, "Settings", "MaxWords", 25)

            ; Apply settings
            this.uiManager.controls.textBox.Text := lastText
            
            try {
                if (voiceIndex > 0) {
                    this.uiManager.controls.voiceDropdown.Value := voiceIndex
                }
            } catch Error {
                this.uiManager.controls.voiceDropdown.Value :=1
            }
            
            this.audioSettings.SetSpeed(speechSpeed)
            this.audioSettings.SetVolume(volume)
            this.audioSettings.SetEnhancement(enhancement)
            this.uiManager.controls.languageDropdown.Value := languageIndex
            this.uiManager.UpdateAllTexts()
            this.audioSettings.SetMinWords(minWords)
            this.audioSettings.SetMaxWords(maxWords)

            ; Update UI controls to reflect loaded settings
            this.uiManager.controls.speedInput.Text := Round(this.audioSettings.speechSpeed, 2)
            this.uiManager.controls.speedSlider.Value := Round(this.audioSettings.speechSpeed * 100)
            this.uiManager.controls.volumeInput.Text := this.audioSettings.volumeBoost
            this.uiManager.controls.volumeSlider.Value := this.audioSettings.volumeBoost
            this.uiManager.controls.enhancementCheckbox.Value := this.audioSettings.useAudioEnhancement
            this.uiManager.controls.minWordsInput.Text := this.audioSettings.minWordsPerSentence
            this.uiManager.controls.maxWordsInput.Text := this.audioSettings.maxWordsPerSentence
        
    }
}

; --- OCR Handler Class ---
class OCRHandler {
    
    __New() {
        this.box := Rectangle_creator()
        ; Store last OCR coordinates for refresh functionality
        this.lastOCRCoords := {x: 0, y: 0, w: 0, h: 0, hasCoords: false}
    }
    
    StartOCR(textBox) {
        this.box.set_first_coord()
        
        while (GetKeyState("x", "P")) {
            this.box.set_second_coord()
            this.box.set_rectangle()
            
            Highlighter.Highlight(this.box.rectangle[1], this.box.rectangle[2], 
                                 this.box.rectangle[3], this.box.rectangle[4], 0, "Red", 2)
            
            capturedResult := OCR.FromRect(this.box.rectangle[1], this.box.rectangle[2], 
                                         this.box.rectangle[3], this.box.rectangle[4])
            
            textBox.Text := capturedResult.Text
            tooltipText := capturedResult.Text
            if (StrLen(capturedResult.Text) > 50) {
                tooltipText := "..." . SubStr(capturedResult.Text, -50)
            }
            ToolTip("OCR: " . tooltipText)
            
            Sleep(50)
        }
        
        ToolTip()
        Highlighter.Highlight()
        
        ; Save the coordinates if OCR was successful
        if (textBox.Text != "") {
            this.lastOCRCoords.x := this.box.rectangle[1]
            this.lastOCRCoords.y := this.box.rectangle[2] 
            this.lastOCRCoords.w := this.box.rectangle[3]
            this.lastOCRCoords.h := this.box.rectangle[4]
            this.lastOCRCoords.hasCoords := true
        }
        
        return textBox.Text != ""
    }
    
    RefreshOCR(textBox) {
        ; Check if we have saved coordinates
        if (!this.lastOCRCoords.hasCoords) {
            MsgBox("No previous OCR area saved. Please use CapsLock+X first to define an area.", "No Saved Area", "Iconx")
            return false
        }
        
        ; Show the saved rectangle briefly to indicate the refresh area
        
        
        ; Perform OCR on the saved area
        capturedResult := OCR.FromRect(this.lastOCRCoords.x, this.lastOCRCoords.y, 
                                     this.lastOCRCoords.w, this.lastOCRCoords.h)
        
        textBox.Text := capturedResult.Text
        tooltipText := capturedResult.Text
        if (StrLen(capturedResult.Text) > 50) {
            tooltipText := "..." . SubStr(capturedResult.Text, -50)
        }
        
        Highlighter.Highlight(this.lastOCRCoords.x, this.lastOCRCoords.y, 
            this.lastOCRCoords.w, this.lastOCRCoords.h, 0, "Blue", 3)
        Sleep(100)
        Highlighter.Highlight(this.lastOCRCoords.x, this.lastOCRCoords.y, 
            this.lastOCRCoords.w, this.lastOCRCoords.h, 0, "Red", 3)
        
        Highlighter.Highlight()
        
        return textBox.Text != ""
    }
}

; --- Initialize Application ---
; Create and start the application

    global piperApp := PiperTTSApp()


return