class HotkeyManager {
    
    __New(ttsPlayer, ocrHandler, uiManager) {
        this.ttsPlayer := ttsPlayer
        this.ocrHandler := ocrHandler
        this.uiManager := uiManager
        this.waitingForCapsLockRelease := false
        this.pendingPlay := false
        this.capsLockMonitorTimer := ObjBindMethod(this, "MonitorCapsLockState")
        this.SetupHotkeys()
    }
    
    SetupHotkeys() {
        ; Stop playback hotkey
        HotKey("CapsLock & s", ObjBindMethod(this, "OnStopHotkey"))
        
        ; Copy and play hotkey
        HotKey("CapsLock & c", ObjBindMethod(this, "OnCopyAndPlayHotkey"))
        
        ; OCR and play hotkey
        HotKey("CapsLock & x", ObjBindMethod(this, "OnOCRAndPlayHotkey"))
        
        ; Refresh OCR hotkey (same area as last OCR)
        HotKey("CapsLock & z", ObjBindMethod(this, "OnRefreshOCRHotkey"))
        
        ; Toggle pause hotkey
        HotKey("CapsLock & a", ObjBindMethod(this, "OnTogglePauseHotkey"))
        
        ; Sentence navigation hotkeys
        HotKey("CapsLock & WheelDown", ObjBindMethod(this, "OnNavigatePreviousSentence"))
        
        ; Next sentence hotkey
        HotKey("CapsLock & WheelUp", ObjBindMethod(this, "OnNavigateNextSentence"))
    }
    
    MonitorCapsLockState() {
        ; Check if CapsLock is still being held down
        if (!GetKeyState("CapsLock", "P")) {
            ; CapsLock has been released
            SetTimer(this.capsLockMonitorTimer, 0)  ; Stop the timer
            this.waitingForCapsLockRelease := false
            
            ; If we have a pending play, execute it now
            if (this.pendingPlay) {
                this.pendingPlay := false
                this.PlayCurrentSentence()
            } else {
                ; If no pending play but we were navigating, clean up
                if (this.waitingForCapsLockRelease) {
                    ; Stop the tooltip timer and clear tooltip
                    SetTimer(this.ttsPlayer.tooltipTimer, 0)
                    ToolTip()
                }
            }
        }
    }
    
    OnStopHotkey(*) {
        this.ttsPlayer.StopPlayback(this.uiManager.controls.statusLabel, 
                                   this.uiManager.controls.playButton, this.uiManager.controls.stopButton)
        this.uiManager.controls.pauseButton.Enabled := false
    }
    
    OnCopyAndPlayHotkey(*) {
        oldClipboard := A_Clipboard
        A_Clipboard := ""
        Send("^c")
        
        if (!ClipWait(1)) {
            MsgBox("No text was selected.", "Copy Failed", "Iconx")
            A_Clipboard := oldClipboard
            return
        }
        
        copiedText := A_Clipboard
        A_Clipboard := oldClipboard
        
        if (copiedText = "" || StrLen(Trim(copiedText)) = 0) {
            MsgBox("No text was copied.", "No Text", "Iconx")
            return
        }
        
        textBox := this.uiManager.GetTextBox()
        textBox.Text := copiedText
        this.uiManager.OnPlayText()
        this.uiManager.controls.pauseButton.Enabled := true
    }
    
    OnOCRAndPlayHotkey(*) {
        textBox := this.uiManager.GetTextBox()
        if (this.ocrHandler.StartOCR(textBox)) {
            this.uiManager.OnPlayText()
        }
        this.uiManager.controls.pauseButton.Enabled := true
    }
    
    OnRefreshOCRHotkey(*) {
        textBox := this.uiManager.GetTextBox()
        if (this.ocrHandler.RefreshOCR(textBox)) {
            this.uiManager.OnPlayText()
        }
        this.uiManager.controls.pauseButton.Enabled := true
    }
    
    OnTogglePauseHotkey(*) {
        this.uiManager.OnPausePlayback()
    }
    
    OnNavigatePreviousSentence(*) {
        ; Stop any current playback to prevent overlapping
        if (this.ttsPlayer.currentProcessPID != 0) {
            this.ttsPlayer.StopCurrentProcess()
        }
        
        ; Navigate to previous sentence but don't play yet
        this.ttsPlayer.GoToPreviousSentenceNoPlay(this.uiManager.controls.statusLabel)
        
        ; Set up waiting for CapsLock release
        this.waitingForCapsLockRelease := true
        this.pendingPlay := true
        
        ; Start monitoring CapsLock state
        SetTimer(this.capsLockMonitorTimer, 50)  ; Check every 50ms
    }
    
    OnNavigateNextSentence(*) {
        ; Stop any current playback to prevent overlapping
        if (this.ttsPlayer.currentProcessPID != 0) {
            this.ttsPlayer.StopCurrentProcess()
        }
        
        ; Navigate to next sentence but don't play yet
        this.ttsPlayer.GoToNextSentenceNoPlay(this.uiManager.controls.statusLabel)
        
        ; Set up waiting for CapsLock release
        this.waitingForCapsLockRelease := true
        this.pendingPlay := true
        
        ; Start monitoring CapsLock state
        SetTimer(this.capsLockMonitorTimer, 50)  ; Check every 50ms
    }
    
    PlayCurrentSentence() {
        ; Only play if we're in sentence playback mode
        if (!this.ttsPlayer.isPlayingSentences || this.ttsPlayer.sentences.Length = 0) {
            return
        }
        
        ; Get voice and play the current sentence
        try {
            voice := piperApp.voiceManager.GetSelectedVoice(piperApp.uiManager.controls.voiceDropdown)
            if (voice.valid) {
                this.ttsPlayer.PlayNextSentence(voice, piperApp.uiManager.controls.statusLabel, 
                                              piperApp.uiManager.controls.playButton, 
                                              piperApp.uiManager.controls.stopButton)
            }
        } catch {
            this.ttsPlayer.FinishSentencePlayback(piperApp.uiManager.controls.statusLabel, 
                                                 piperApp.uiManager.controls.playButton, 
                                                 piperApp.uiManager.controls.stopButton)
        }
    }
    
    ; Legacy methods for backward compatibility
    OnPreviousSentenceHotkey(*) {
        this.OnNavigatePreviousSentence()
    }
    
    OnNextSentenceHotkey(*) {
        this.OnNavigateNextSentence()
    }
} 