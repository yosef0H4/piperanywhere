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
        
        ; Clean the text if cleaning is enabled
        if (piperApp.GetTextCleaning()) {
            textToSpeak := this.CleanTextForTTS(textToSpeak)
        }
        
        this.CleanupTempFiles()
        
        if (piperApp.GetLegacyMode()) {
            ; Legacy mode: play all text at once, no segmentation
            this.sentences := [textToSpeak]
            this.currentSentenceIndex := 1
            this.isPlayingSentences := false
            playButton.Enabled := true
            playButton.Text := "▶ Play"
            stopButton.Enabled := true
            statusLabel.Text := "🎵 Playing (Legacy Mode)"
            this.PlayLegacyText(voice, textToSpeak, statusLabel, playButton, stopButton)
            return true
        }
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
        statusText .= " (" . Round(this.audioSettings.speechSpeed, 1) . "x, " . this.sentences.Length . " sentences)"
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
        tempText := StrReplace(tempText, ",", "," . delimiter)
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
            words := StrSplit(currentSentence, [" ", A_Tab])
            wordCount := words.Length
            
            ; If sentence is too long, split it
            if (wordCount > this.audioSettings.maxWordsPerSentence) {
                ; Split the sentence at the max word boundary
                firstPart := []
                secondPart := []
                
                ; Take the first maxWordsPerSentence words for the first part
                Loop this.audioSettings.maxWordsPerSentence {
                    if (A_Index <= words.Length) {
                        firstPart.Push(words[A_Index])
                    }
                }
                
                ; Put the remaining words in the second part
                Loop words.Length - this.audioSettings.maxWordsPerSentence {
                    remainingIndex := this.audioSettings.maxWordsPerSentence + A_Index
                    if (remainingIndex <= words.Length) {
                        secondPart.Push(words[remainingIndex])
                    }
                }
                
                ; Join the first part and add it to combined sentences
                if (firstPart.Length > 0) {
                    firstSentence := ""
                    for word in firstPart {
                        firstSentence .= (firstSentence = "" ? "" : " ") . word
                    }
                    combinedSentences.Push(firstSentence)
                }
                
                ; If there are remaining words, insert them back into the sentences array
                ; for processing in the next iteration
                if (secondPart.Length > 0) {
                    remainingSentence := ""
                    for word in secondPart {
                        remainingSentence .= (remainingSentence = "" ? "" : " ") . word
                    }
                    
                    ; Insert the remaining sentence at the current position + 1
                    sentences.InsertAt(i + 1, remainingSentence)
                }
                
                i++
                continue
            }
            
            ; If sentence is too short, try to combine with next sentences
            while (wordCount < this.audioSettings.minWordsPerSentence && i < sentences.Length) {
                i++
                nextSentence := Trim(sentences[i])
                if (nextSentence != "") {
                    ; Check if adding the next sentence would exceed max words
                    combinedWords := StrSplit(currentSentence . " " . nextSentence, [" ", A_Tab])
                    if (combinedWords.Length <= this.audioSettings.maxWordsPerSentence) {
                        currentSentence .= " " . nextSentence
                        wordCount := combinedWords.Length
                    } else {
                        ; Adding the full next sentence would exceed max, so break
                        i-- ; Step back since we didn't use this sentence
                        break
                    }
                }
            }
            
            combinedSentences.Push(currentSentence)
            i++
        }
        
        return combinedSentences
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
        
        if (IsSet(playButton))
            playButton.Text := "▶ Play"
        
        ; Reset pause button if it exists
        this.ResetPauseButton()
    }
    
    UpdateSentenceTooltip() {
        if (piperApp.GetLegacyMode()) {
            return ; No tooltip updates in legacy mode
        }
        ; Show tooltip during playback OR during navigation (when waitingForCapsLockRelease)
        if (!GetKeyState("CapsLock", "p") || !GetKeyState("x", "p")) {
            if ((this.currentProcessPID != 0 || piperApp.hotkeyManager.waitingForCapsLockRelease) && 
                this.isPlayingSentences && this.currentSentenceIndex > 0 && this.currentSentenceIndex <= this.sentences.Length) {
                MouseGetPos(&mouseX, &mouseY)
                currentIndex := this.currentSentenceIndex
                currentSentence := this.sentences[currentIndex]
                sentenceWithIndex := "(" . currentIndex . "/" . this.sentences.Length . ") " . currentSentence
                ToolTip(sentenceWithIndex, mouseX + 15, mouseY + 30)
            }
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
    
    GoToPreviousSentence(statusLabel, playButton, stopButton) {
        ; Only allow navigation during sentence playback
        if (!this.isPlayingSentences || this.sentences.Length = 0) {
            return
        }
        
        ; Stop current process first
        this.StopCurrentProcess()
        
        ; Move to previous sentence with bounds checking
        if (this.currentSentenceIndex > 1) {
            this.currentSentenceIndex--
        } else {
            ; If at first sentence, go to last sentence (wrap around)
            this.currentSentenceIndex := this.sentences.Length
        }
        
        ; Update status and continue playback
        statusLabel.Text := "⏮ Previous sentence (" . this.currentSentenceIndex . "/" . this.sentences.Length . ")"
        
        ; Get voice and play the selected sentence
        try {
            voice := piperApp.voiceManager.GetSelectedVoice(piperApp.uiManager.controls.voiceDropdown)
            if (voice.valid) {
                this.PlayNextSentence(voice, statusLabel, playButton, stopButton)
            }
        } catch {
            this.FinishSentencePlayback(statusLabel, playButton, stopButton)
        }
    }
    
    GoToNextSentence(statusLabel, playButton, stopButton) {
        ; Only allow navigation during sentence playback
        if (!this.isPlayingSentences || this.sentences.Length = 0) {
            return
        }
        
        ; Stop current process first
        this.StopCurrentProcess()
        
        ; Move to next sentence with bounds checking
        if (this.currentSentenceIndex < this.sentences.Length) {
            this.currentSentenceIndex++
        } else {
            ; If at last sentence, go to first sentence (wrap around)
            this.currentSentenceIndex := 1
        }
        
        ; Update status and continue playback
        statusLabel.Text := "⏭ Next sentence (" . this.currentSentenceIndex . "/" . this.sentences.Length . ")"
        
        ; Get voice and play the selected sentence
        try {
            voice := piperApp.voiceManager.GetSelectedVoice(piperApp.uiManager.controls.voiceDropdown)
            if (voice.valid) {
                this.PlayNextSentence(voice, statusLabel, playButton, stopButton)
            }
        } catch {
            this.FinishSentencePlayback(statusLabel, playButton, stopButton)
        }
    }
    
    GoToPreviousSentenceNoPlay(statusLabel) {
        ; Clear any existing tooltip first
        ToolTip()
        
        ; Only allow navigation during sentence playback
        if (!this.isPlayingSentences || this.sentences.Length = 0) {
            return
        }
        
        ; Move to previous sentence with bounds checking
        if (this.currentSentenceIndex > 1) {
            this.currentSentenceIndex--
        } else {
            ; If at first sentence, go to last sentence (wrap around)
            this.currentSentenceIndex := this.sentences.Length
        }
        
        ; Update status but don't play
        statusLabel.Text := "⏮ Previous sentence (" . this.currentSentenceIndex . "/" . this.sentences.Length . ") - Release CapsLock to play"
        
        ; Start the tooltip timer to follow the cursor during navigation
        SetTimer(this.tooltipTimer, 50)
    }
    
    GoToNextSentenceNoPlay(statusLabel) {
        ; Clear any existing tooltip first
        ToolTip()
        
        ; Only allow navigation during sentence playback
        if (!this.isPlayingSentences || this.sentences.Length = 0) {
            return
        }
        
        ; Move to next sentence with bounds checking
        if (this.currentSentenceIndex < this.sentences.Length) {
            this.currentSentenceIndex++
        } else {
            ; If at last sentence, go to first sentence (wrap around)
            this.currentSentenceIndex := 1
        }
        
        ; Update status but don't play
        statusLabel.Text := "⏭ Next sentence (" . this.currentSentenceIndex . "/" . this.sentences.Length . ") - Release CapsLock to play"
        
        ; Start the tooltip timer to follow the cursor during navigation
        SetTimer(this.tooltipTimer, 50)
    }
    
    GoToSentenceIndex(index, statusLabel) {
        ; Only allow navigation during sentence playback
        if (!this.isPlayingSentences || this.sentences.Length = 0) {
            return
        }
        
        ; Validate index bounds
        if (index < 1 || index > this.sentences.Length) {
            statusLabel.Text := "❌ Invalid sentence index: " . index . " (valid range: 1-" . this.sentences.Length . ")"
            return
        }
        
        ; Set the current sentence index
        this.currentSentenceIndex := index
        
        ; Update status
        statusLabel.Text := "📍 Jumped to sentence " . this.currentSentenceIndex . " of " . this.sentences.Length . " (Paused)"
    }
    
    CleanTextForTTS(text) {
        ; Remove any character that is not a letter, number, punctuation, or separator/whitespace
        ; This approach is language-agnostic and effectively removes emojis, decorative symbols, etc.
        cleanedText := RegExReplace(text, "[^\p{L}\p{N}\p{P}\p{Z}]", "")
        
        ; Clean up multiple spaces/newlines that might result from removals
        cleanedText := RegExReplace(cleanedText, "\s+", " ")
        cleanedText := RegExReplace(cleanedText, "^\s+|\s+$", "") ; Trim start/end
        
        ; Clean up multiple punctuation marks (keep max 3 for emphasis)
        cleanedText := RegExReplace(cleanedText, "([.!?]){4,}", "$1$1$1")
        
        return cleanedText
    }
    
    PlayLegacyText(voice, textToSpeak, statusLabel, playButton, stopButton) {
        this.tempTextFile := A_Temp . "\piper_legacy_" . A_TickCount . ".txt"
        try {
            FileAppend(textToSpeak, this.tempTextFile, "UTF-8")
        } catch as e {
            MsgBox("Failed to create temporary file: " . e.Message, "File Error", "Iconx")
            statusLabel.Text := "❌ File error"
            this.FinishSentencePlayback(statusLabel, playButton, stopButton)
            return
        }
        command := this.audioSettings.BuildAudioCommand(voice.file, this.tempTextFile)
        MouseGetPos(&mouseX, &mouseY)
        ToolTip("🎵 Playing all text (Legacy Mode)", mouseX + 15, mouseY + 30)
        SetTimer(() => ToolTip(), -1000) ; Hide tooltip after 1s
        try {
            Run(command, , "Hide", &this.currentProcessPID)
            SetTimer(this.playbackTimer, 250)
        } catch as e {
            MsgBox("Failed to start playback: " . e.Message, "Playback Error", "Iconx")
            this.CleanupTempFiles()
            this.FinishSentencePlayback(statusLabel, playButton, stopButton)
        }
    }
} 