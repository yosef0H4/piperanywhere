class HotkeyManager {
    
    __New(ttsPlayer, ocrHandler, uiManager) {
        this.ttsPlayer := ttsPlayer
        this.ocrHandler := ocrHandler
        this.uiManager := uiManager
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
        HotKey("CapsLock & WheelDown", ObjBindMethod(this, "OnPreviousSentenceHotkey"))
        
        ; Next sentence hotkey
        HotKey("CapsLock & WheelUp", ObjBindMethod(this, "OnNextSentenceHotkey"))
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
    
    OnPreviousSentenceHotkey(*) {
        this.ttsPlayer.GoToPreviousSentence(this.uiManager.controls.statusLabel, this.uiManager.controls.playButton, this.uiManager.controls.stopButton)
    }
    
    OnNextSentenceHotkey(*) {
        this.ttsPlayer.GoToNextSentence(this.uiManager.controls.statusLabel, this.uiManager.controls.playButton, this.uiManager.controls.stopButton)
    }
} 