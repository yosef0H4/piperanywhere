class TTSPlayer {
    
    __New(audioSettings, voiceManager) {
        this.audioSettings := audioSettings
        this.voiceManager := voiceManager
        this.currentProcessPID := 0
        this.tempTextFile := ""
        this.tempAudioFile := ""
        this.playbackTimer := ObjBindMethod(this, "CheckPlaybackStatus")
        this.tooltipTimer := ObjBindMethod(this, "UpdateSentenceTooltip")
        this.sentences := []
        this.currentSentenceIndex := 0
        this.isPlayingSentences := false
        this.isPaused := false
        this.pausedSentenceIndex := 0
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
        
        if (this.currentProcessPID != 0 && !this.isPaused) {
            this.StopPlayback(statusLabel, playButton, stopButton)
        }
        
        this.CleanupTempFiles()
        
        ; Split text into sentences
        this.sentences := this.SplitTextIntoSentences(textToSpeak)
        if (this.sentences.Length = 0) {
            MsgBox("No sentences found in the text.", "No Sentences", "Iconx")
            statusLabel.Text := "❌ No sentences found"
            return false
        }
        ; Filter sentences by word count
        this.sentences := this.CombineShortSentences(this.sentences)
        if (this.sentences.Length = 0) {
            MsgBox("No sentences meet the word count criteria.", "No Valid Sentences", "Iconx")
            statusLabel.Text := "❌ No valid sentences"
            return false
        }
        
        ; If resuming from pause, use saved index, otherwise start from beginning
        if (this.isPaused && this.pausedSentenceIndex > 0) {
            this.currentSentenceIndex := this.pausedSentenceIndex
            this.isPaused := false
        } else {
            this.currentSentenceIndex := 1
            this.pausedSentenceIndex := 0
        }
        
        this.isPlayingSentences := true
        playButton.Enabled := true
        playButton.Text := "▶ Play"
        stopButton.Enabled := true
        statusText := "🎵 Playing: " . StrSplit(voice.display, "(")[1]
        statusText .= " (" . Round(this.audioSettings.speechSpeed, 1) . "x"
        if (this.audioSettings.useAudioEnhancement) {
            statusText .= ", Enhanced"
        }
        statusText .= ", " . this.sentences.Length . " sentences)"
        statusLabel.Text := statusText
        this.PlayNextSentence(voice, statusLabel, playButton, stopButton)
        return true
    }
    
    PlayNextSentence(voice, statusLabel, playButton, stopButton) {
        if (!this.isPlayingSentences || this.currentSentenceIndex > this.sentences.Length) {
            this.FinishSentencePlayback(statusLabel, playButton, stopButton)
            return
        }
        currentSentence := this.sentences[this.currentSentenceIndex]
        this.tempTextFile := A_Temp . "\piper_sentence_" . A_TickCount . ".txt"
        try {
            FileAppend(currentSentence, this.tempTextFile, "UTF-8")
        } catch as e {
            MsgBox("Failed to create temporary file: " . e.Message, "File Error", "Iconx")
            statusLabel.Text := "❌ File error"
            this.FinishSentencePlayback(statusLabel, playButton, stopButton)
            return
        }
        command := this.audioSettings.BuildAudioCommand(voice.file, this.tempTextFile)
        SetTimer(this.tooltipTimer, 50)
        try {
            Run(command, , "Hide", &this.currentProcessPID)
            SetTimer(this.playbackTimer, 250)
        } catch as e {
            MsgBox("Failed to start playback: " . e.Message, "Playback Error", "Iconx")
            this.CleanupTempFiles()
            this.FinishSentencePlayback(statusLabel, playButton, stopButton)
        }
    }
    
    FinishSentencePlayback(statusLabel, playButton, stopButton) {
        ; Reset pause state when playback finishes
        this.isPaused := false
        this.pausedSentenceIndex := 0
        this.ResetPauseButton()
        
        this.isPlayingSentences := false
        this.currentSentenceIndex := 0
        this.sentences := []
        statusLabel.Text := "✅ Playback completed"
        this.ResetPlaybackState(playButton, stopButton)
        ToolTip()
        this.CleanupTempFiles()
    }
    
    SplitTextIntoSentences(text) {
        finalSentences := []
        if (Trim(text) = "") {
            return finalSentences
        }
        tempText := StrReplace(text, "`r`n", "`n")
        delimiter := "|~|"
        tempText := StrReplace(tempText, ".", "." . delimiter)
        tempText := StrReplace(tempText, "!", "!" . delimiter)
        tempText := StrReplace(tempText, "?", "?" . delimiter)
        tempText := StrReplace(tempText, "`n", delimiter)
        initialChunks := StrSplit(tempText, delimiter)
        for chunk in initialChunks {
            if (Trim(chunk) = "") {
                continue
            }
            finalSentences.Push(Trim(chunk))
        }
        return finalSentences
    }
    
    CombineShortSentences(sentences) {
        combinedSentences := []
        i := 1
        
        while (i <= sentences.Length) {
            currentSentence := Trim(sentences[i])
            
            ; Skip completely empty sentences
            if (currentSentence = "") {
                i++
                continue
            }
            
            ; Count words in current sentence
            wordCount := StrSplit(currentSentence, [" ", A_Tab]).Length
            
            ; If sentence is too short, try to combine with next sentences
            while (wordCount < this.audioSettings.minWordsPerSentence && i < sentences.Length) {
                i++
                nextSentence := Trim(sentences[i])
                if (nextSentence != "") {
                    currentSentence .= " " . nextSentence
                    wordCount := StrSplit(currentSentence, [" ", A_Tab]).Length
                }
            }
            
            combinedSentences.Push(currentSentence)
            i++
        }
        
        return combinedSentences
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
        ; Reset pause state when stop is pressed
        this.isPaused := false
        this.pausedSentenceIndex := 0
        this.ResetPauseButton()
        
        if (this.currentProcessPID = 0) {
            return
        }
        this.isPlayingSentences := false
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
        ; If paused, don't continue to next sentence
        if (this.isPaused) {
            SetTimer(this.playbackTimer, 0)
            SetTimer(this.tooltipTimer, 0)
            ToolTip()
            return
        }
        
        if (this.currentProcessPID = 0) {
            SetTimer(this.playbackTimer, 0)
            return
        }
        if (!ProcessExist(this.currentProcessPID)) {
            if (this.isPlayingSentences) {
                this.currentSentenceIndex++
                SetTimer(this.playbackTimer, 0)
                SetTimer(this.tooltipTimer, 0)
                this.currentProcessPID := 0
                try {
                    voice := piperApp.voiceManager.GetSelectedVoice(piperApp.uiManager.controls.voiceDropdown)
                    if (voice.valid) {
                        this.PlayNextSentence(voice, piperApp.uiManager.controls.statusLabel, piperApp.uiManager.controls.playButton, piperApp.uiManager.controls.stopButton)
                    }
                } catch {
                    this.FinishSentencePlayback("", "", "")
                }
            } else {
                this.ResetPlaybackState()
                ToolTip()
                this.CleanupTempFiles()
            }
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
        
        ; Reset pause button if it exists
        this.ResetPauseButton()
    }
    
    UpdateSentenceTooltip() {
        if (this.currentProcessPID != 0 && this.isPlayingSentences && this.currentSentenceIndex > 0 && this.currentSentenceIndex <= this.sentences.Length) {
            MouseGetPos(&mouseX, &mouseY)
            currentSentence := this.sentences[this.currentSentenceIndex]
            ToolTip(currentSentence, mouseX + 15, mouseY - 30)
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
    
    PausePlayback(statusLabel, playButton, pauseButton, stopButton) {
        if (!this.isPlayingSentences) {
            return
        }
        
        if (this.isPaused) {
            ; Resume playback
            this.isPaused := false
            pauseButton.Text := "⏸ Pause"
            playButton.Enabled := false
            stopButton.Enabled := true
            statusLabel.Text := "🎵 Resuming playback..."
            
            ; Get voice and continue from paused sentence
            try {
                voice := piperApp.voiceManager.GetSelectedVoice(piperApp.uiManager.controls.voiceDropdown)
                if (voice.valid) {
                    this.PlayNextSentence(voice, statusLabel, playButton, stopButton)
                }
            } catch {
                this.FinishSentencePlayback(statusLabel, playButton, stopButton)
            }
        } else {
            ; Pause playback
            this.isPaused := true
            this.pausedSentenceIndex := this.currentSentenceIndex
            pauseButton.Text := "▶ Resume"
            playButton.Enabled := true
            stopButton.Enabled := true
            statusLabel.Text := "⏸ Paused at sentence " . this.currentSentenceIndex . " of " . this.sentences.Length
            this.StopCurrentProcess()
        }
    }
    
    StopCurrentProcess() {
        if (this.currentProcessPID != 0) {
            try {
                RunWait('taskkill /F /T /PID ' . this.currentProcessPID, , "Hide")
            } catch {
                ProcessClose(this.currentProcessPID)
            }
            this.currentProcessPID := 0
        }
    }
    
    ResetPauseButton() {
        ; Reset pause button text if it exists
        try {
            if (piperApp.uiManager.controls.HasOwnProp("pauseButton")) {
                piperApp.uiManager.controls.pauseButton.Text := piperApp.uiManager.GetText("pauseButton")
            }
        } catch {
            ; Ignore if UI not available
        }
    }
} 