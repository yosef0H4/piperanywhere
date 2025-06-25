class TTSPlayer {
    
    __New(audioSettings, voiceManager) {
        this.audioSettings := audioSettings
        this.voiceManager := voiceManager
        this.currentProcessPID := 0
        this.tempTextFile := ""
        this.tempAudioFile := ""
        this.playbackTimer := ObjBindMethod(this, "CheckPlaybackStatus")
        this.tooltipTimer := ObjBindMethod(this, "UpdatePlayingTooltip")
    }
    
    PlayText(textBox, voiceDropdown, statusLabel, playButton, stopButton) {
        textToSpeak := textBox.Text
        
        if (textToSpeak = "") {
            MsgBox("Please enter some text to speak.", "No Text", "Iconx")
            statusLabel.Text := "❌ No text entered"
            return false
        }
        
        voice := this.voiceManager.GetSelectedVoice(voiceDropdown)
        if (!voice.valid) {
            MsgBox("Please select a valid voice from the dropdown.", "Invalid Voice", "Iconx")
            statusLabel.Text := "❌ Invalid voice"
            return false
        }
        
        if (this.currentProcessPID != 0) {
            this.StopPlayback(statusLabel, playButton, stopButton)
        }
        
        this.CleanupTempFiles()
        
        this.tempTextFile := A_Temp . "\piper_text_" . A_TickCount . ".txt"
        
        try {
            FileAppend(textToSpeak, this.tempTextFile, "UTF-8")
        } catch as e {
            MsgBox("Failed to create temporary file: " . e.Message, "File Error", "Iconx")
            statusLabel.Text := "❌ File error"
            return false
        }
        
        playButton.Enabled := true
        playButton.Text := "▶ Play"
        stopButton.Enabled := true
        
        command := this.audioSettings.BuildAudioCommand(voice.file, this.tempTextFile)
        
        statusText := "🎵 Playing: " . StrSplit(voice.display, "(")[1]
        statusText .= " (" . Round(this.audioSettings.speechSpeed, 1) . "x"
        if (this.audioSettings.useAudioEnhancement) {
            statusText .= ", Enhanced"
        }
        statusText .= ")"
        statusLabel.Text := statusText
        
        try {
            Run(command, , "Hide", &this.currentProcessPID)
            SetTimer(this.playbackTimer, 500)
            SetTimer(this.tooltipTimer, 50)
            return true
        } catch as e {
            MsgBox("Failed to start playback: " . e.Message, "Playback Error", "Iconx")
            this.CleanupTempFiles()
            this.ResetPlaybackState(playButton, stopButton)
            return false
        }
    }
    
    SaveAudio(textBox, voiceDropdown, statusLabel) {
        textToSpeak := textBox.Text
        
        if (textToSpeak = "") {
            MsgBox("Please enter some text to save as audio.", "No Text", "Iconx")
            statusLabel.Text := "❌ No text to save"
            return false
        }
        
        voice := this.voiceManager.GetSelectedVoice(voiceDropdown)
        if (!voice.valid) {
            MsgBox("Please select a valid voice from the dropdown.", "Invalid Voice", "Iconx")
            statusLabel.Text := "❌ Invalid voice"
            return false
        }
        
        saveFile := FileSelect("S", "piper_audio.wav", "Save Audio File", "Wave Files (*.wav)")
        if (saveFile = "") {
            return false
        }
        
        this.CleanupTempFiles()
        
        this.tempTextFile := A_Temp . "\piper_text_" . A_TickCount . ".txt"
        
        try {
            FileAppend(textToSpeak, this.tempTextFile, "UTF-8")
        } catch as e {
            MsgBox("Failed to create temporary file: " . e.Message, "File Error", "Iconx")
            statusLabel.Text := "❌ File error"
            return false
        }
        
        command := this.audioSettings.BuildSaveCommand(voice.file, this.tempTextFile, saveFile)
        
        statusLabel.Text := "💾 Saving audio file..."
        
        try {
            RunWait(command, , "Hide")
            statusLabel.Text := "✅ Audio saved: " . saveFile
            MsgBox("Audio saved successfully!", "Save Complete", "Iconi")
            this.CleanupTempFiles()
            return true
        } catch as e {
            MsgBox("Failed to save audio: " . e.Message, "Save Error", "Iconx")
            statusLabel.Text := "❌ Failed to save"
            this.CleanupTempFiles()
            return false
        }
    }
    
    StopPlayback(statusLabel, playButton, stopButton) {
        if (this.currentProcessPID = 0) {
            return
        }
        
        try {
            RunWait('taskkill /F /T /PID ' . this.currentProcessPID, , "Hide")
            statusLabel.Text := "⏹ Playback stopped"
        } catch as e {
            try {
                ProcessClose(this.currentProcessPID)
                statusLabel.Text := "⏹ Playback stopped"
            } catch {
                statusLabel.Text := "❌ Failed to stop"
            }
        }
        
        this.ResetPlaybackState(playButton, stopButton)
        ToolTip()
        this.CleanupTempFiles()
    }
    
    CheckPlaybackStatus() {
        if (this.currentProcessPID = 0) {
            SetTimer(this.playbackTimer, 0)
            return
        }
        
        if (!ProcessExist(this.currentProcessPID)) {
            ; Find the UI elements through the global app instance
            ; This is a limitation - we need access to UI elements
            ; In a more complex app, we'd use events/callbacks
            this.ResetPlaybackState()
            ToolTip()
            this.CleanupTempFiles()
        }
    }
    
    ResetPlaybackState(playButton?, stopButton?) {
        SetTimer(this.tooltipTimer, 0)
        SetTimer(this.playbackTimer, 0)
        this.currentProcessPID := 0
        ToolTip()
        
        if (IsSet(playButton)) {
            playButton.Enabled := true
            playButton.Text := "▶ Play"
        }
        if (IsSet(stopButton)) {
            stopButton.Enabled := false
        }
    }
    
    UpdatePlayingTooltip() {
        if (this.currentProcessPID != 0) {
            MouseGetPos(&mouseX, &mouseY)
            ToolTip("🎵 Playing...", mouseX + 15, mouseY - 30)
        }
    }
    
    CleanupTempFiles() {
        if (this.tempTextFile != "") {
            try {
                if (FileExist(this.tempTextFile)) {
                    FileDelete(this.tempTextFile)
                }
            } catch {
                ; Ignore errors
            }
        }
        
        if (this.tempAudioFile != "") {
            try {
                if (FileExist(this.tempAudioFile)) {
                    FileDelete(this.tempAudioFile)
                }
            } catch {
                ; Ignore errors
            }
        }
    }
    
    Cleanup() {
        if (this.currentProcessPID != 0) {
            try {
                ProcessClose(this.currentProcessPID)
            } catch {
                ; Ignore errors
            }
        }
        this.CleanupTempFiles()
    }
} 