; Updated UIManager.ahk - Now includes dependency information feature
#Requires AutoHotkey v2

class UIManager {
    
    __New(piperApp, audioSettings, voiceManager, ttsPlayer, ocrHandler) {
        this.app := piperApp
        this.audioSettings := audioSettings
        this.voiceManager := voiceManager
        this.ttsPlayer := ttsPlayer
        this.ocrHandler := ocrHandler
        this.gui := ""
        this.controls := {}
    }
    
    CreateGUI() {
        this.gui := Gui("+Resize -MaximizeBox", "🎙️ Piper TTS")
        this.gui.MarginX := 8
        this.gui.MarginY := 8
        this.gui.SetFont("s9", "Segoe UI")
        
        ; Voice section
        this.CreateVoiceSection()
        
        ; Audio settings section
        this.CreateAudioSection()
        
        ; Text input section
        this.CreateTextSection()
        
        ; Control buttons
        this.CreateControlButtons()
        
        ; Status and hints
        this.CreateStatusSection()
        
        ; Set up event handlers
        this.SetupEventHandlers()
        
        ; Store references for easy access
        this.voiceDropdown := this.controls.voiceDropdown
        this.statusLabel := this.controls.statusLabel
    }
    
    CreateVoiceSection() {
        voiceGroup := this.gui.AddGroupBox("x8 y8 w280 h50", "Voice Selection")
        voiceGroup.SetFont("s8 Bold", "Segoe UI")
        
        this.controls.voiceDropdown := this.gui.AddDropDownList("x16 y26 w200 h200", [])
        this.controls.refreshButton := this.gui.AddButton("x220 y26 w25 h21", "↻")
        this.controls.refreshButton.SetFont("s8")
        
        this.controls.voicesButton := this.gui.AddButton("x248 y26 w32 h21", "📁")
        this.controls.voicesButton.SetFont("s8")
    }
    
    CreateAudioSection() {
        audioGroup := this.gui.AddGroupBox("x8 y66 w280 h75", "Audio Settings")
        audioGroup.SetFont("s8 Bold", "Segoe UI")
        
        ; Enhancement toggle
        this.controls.enhancementCheckbox := this.gui.AddCheckbox("x16 y84 w90 h16 Checked", "🔊 Enhanced")
        this.controls.enhancementCheckbox.SetFont("s8")
        
        ; Speed control
        this.gui.AddText("x16 y104", "Speed:")
        this.gui.AddText("x+6 y104", "Slow")
        this.controls.speedSlider := this.gui.AddSlider("x100 y102 w60 h20 Range50-200 NoTicks", 100)
        this.gui.AddText("x+6 y104", "Fast")
        this.controls.speedInput := this.gui.AddEdit("x+6 y104 w30 h16", "1.0")
        this.controls.speedInput.SetFont("s8 Bold")
        
        ; Volume control
        this.gui.AddText("x16 y120", "Volume:")
        this.gui.AddText("x+3 y120", "Quiet")
        this.controls.volumeSlider := this.gui.AddSlider("x100 y118 w60 h20 Range-10-20 NoTicks", 2)
        this.gui.AddText("x+6 y120 w30 h16", "Loud")
        this.controls.volumeInput := this.gui.AddEdit("x+6 y120 w30 h16", "2")
        this.controls.volumeInput.SetFont("s8 Bold")
        this.gui.AddText("x+6 y120 w30 h16", "dB")
    }
    
    CreateTextSection() {
        textGroup := this.gui.AddGroupBox("x8 y144 w280 h80", "Text to Speak")
        textGroup.SetFont("s8 Bold", "Segoe UI")
        
        this.controls.textBox := this.gui.AddEdit("x16 y162 w264 h54 VScroll", 
                                            "Enhanced Piper TTS with object-oriented design and improved maintainability.")
    }
    
    CreateControlButtons() {
        buttonGroup := this.gui.AddGroupBox("x8 y232 w280 h70", "Controls")
        buttonGroup.SetFont("s8 Bold", "Segoe UI")
        
        ; First row of buttons
        this.controls.playButton := this.gui.AddButton("x16 y250 w50 h24 Default", "▶ Play")
        this.controls.playButton.SetFont("s8 Bold")
        
        this.controls.stopButton := this.gui.AddButton("x70 y250 w50 h24 Disabled", "⏹ Stop")
        this.controls.stopButton.SetFont("s8 Bold")
        
        this.controls.saveButton := this.gui.AddButton("x124 y250 w50 h24", "💾 Save")
        this.controls.saveButton.SetFont("s8 Bold")
        
        this.controls.ocrButton := this.gui.AddButton("x178 y250 w50 h24", "👁 OCR")
        this.controls.ocrButton.SetFont("s8 Bold")
        
        this.controls.exitButton := this.gui.AddButton("x232 y250 w50 h24", "✖ Exit")
        this.controls.exitButton.SetFont("s8")
        
        ; Second row - Info and diagnostic buttons
        this.controls.infoButton := this.gui.AddButton("x16 y276 w70 h20", "ℹ️ Dependencies")
        this.controls.infoButton.SetFont("s7")
        
        this.controls.helpButton := this.gui.AddButton("x90 y276 w50 h20", "❓ Help")
        this.controls.helpButton.SetFont("s7")
    }
    
    CreateStatusSection() {
        this.controls.statusLabel := this.gui.AddText("x8 y308 w280 h16 Center", "Ready")
        this.controls.statusLabel.SetFont("s8", "Segoe UI")
        
        this.controls.qualityLabel := this.gui.AddText("x8 y324 w280 h16 Center", "")
        this.controls.qualityLabel.SetFont("s7", "Segoe UI")
        
        this.controls.hintLabel := this.gui.AddText("x8 y340 w280 h32 Center", 
                                              "💡 Hotkeys: CapsLock+C (Copy & Play) • CapsLock+X (OCR & Play) • CapsLock+S (Stop)")
        this.controls.hintLabel.SetFont("s7", "Segoe UI")
    }
    
    SetupEventHandlers() {
        ; Use bound methods to maintain 'this' context
        this.controls.refreshButton.OnEvent("Click", ObjBindMethod(this, "OnRefreshVoices"))
        this.controls.voicesButton.OnEvent("Click", ObjBindMethod(this, "OnOpenVoicesFolder"))
        this.controls.enhancementCheckbox.OnEvent("Click", ObjBindMethod(this, "OnEnhancementToggled"))
        this.controls.speedSlider.OnEvent("Change", ObjBindMethod(this, "OnSpeedChanged"))
        this.controls.speedInput.OnEvent("LoseFocus", ObjBindMethod(this, "OnSpeedInputChanged"))
        this.controls.volumeSlider.OnEvent("Change", ObjBindMethod(this, "OnVolumeChanged"))
        this.controls.volumeInput.OnEvent("LoseFocus", ObjBindMethod(this, "OnVolumeInputChanged"))
        this.controls.playButton.OnEvent("Click", ObjBindMethod(this, "OnPlayText"))
        this.controls.stopButton.OnEvent("Click", ObjBindMethod(this, "OnStopPlayback"))
        this.controls.saveButton.OnEvent("Click", ObjBindMethod(this, "OnSaveAudio"))
        this.controls.ocrButton.OnEvent("Click", ObjBindMethod(this, "OnStartOCR"))
        this.controls.exitButton.OnEvent("Click", ObjBindMethod(this, "OnExit"))
        
        ; New event handlers
        this.controls.infoButton.OnEvent("Click", ObjBindMethod(this, "OnShowDependencyInfo"))
        this.controls.helpButton.OnEvent("Click", ObjBindMethod(this, "OnShowHelp"))
        
        ; GUI close event
        this.gui.OnEvent("Close", ObjBindMethod(this, "OnExit"))
    }
    
    ; Event handlers
    OnRefreshVoices(*) {
        this.voiceManager.PopulateVoices(this.controls.voiceDropdown, this.controls.statusLabel)
        this.controls.statusLabel.Text := "Voice list refreshed"
    }
    
    OnOpenVoicesFolder(*) {
        if (this.voiceManager.OpenVoicesFolder()) {
            this.controls.statusLabel.Text := "Opened voices folder"
        } else {
            MsgBox("Voices folder not found!", "Error", "Iconx")
        }
    }
    
    OnEnhancementToggled(*) {
        this.audioSettings.SetEnhancement(this.controls.enhancementCheckbox.Value)
        this.UpdateQualityInfo()
        this.controls.statusLabel.Text := this.audioSettings.useAudioEnhancement ? 
                                        "Audio enhancement enabled" : "Audio enhancement disabled"
    }
    
    OnSpeedChanged(*) {
        speed := this.controls.speedSlider.Value / 100.0
        this.audioSettings.SetSpeed(speed)
        this.controls.speedInput.Text := Round(speed, 2)
    }
    
    OnSpeedInputChanged(*) {
        newSpeed := this.controls.speedInput.Text
        
        if (!this.audioSettings.SetSpeed(newSpeed)) {
            this.controls.statusLabel.Text := "❌ Invalid speed: Not a number"
            this.controls.speedInput.Text := Round(this.audioSettings.speechSpeed, 2)
            return
        }
        
        this.controls.speedSlider.Value := Round(this.audioSettings.speechSpeed * 100)
        this.controls.statusLabel.Text := "Speed set to " . Round(this.audioSettings.speechSpeed, 2) . "x"
    }
    
    OnVolumeChanged(*) {
        volume := this.controls.volumeSlider.Value
        this.audioSettings.SetVolume(volume)
        this.controls.volumeInput.Text := volume
    }
    
    OnVolumeInputChanged(*) {
        newVolume := this.controls.volumeInput.Text
        
        if (!this.audioSettings.SetVolume(newVolume)) {
            this.controls.statusLabel.Text := "❌ Invalid volume: Not a number"
            this.controls.volumeInput.Text := this.audioSettings.volumeBoost
            return
        }
        
        this.controls.volumeSlider.Value := Round(this.audioSettings.volumeBoost)
        this.controls.statusLabel.Text := "Volume set to " . Round(this.audioSettings.volumeBoost, 1) . "dB"
    }
    
    OnPlayText(*) {
        ; Validate inputs before playback
        if (!IsNumber(this.controls.speedInput.Text)) {
            MsgBox("Please enter a valid number for speed.", "Invalid Speed", "Iconx")
            this.controls.speedInput.Text := Round(this.audioSettings.speechSpeed, 2)
            this.controls.statusLabel.Text := "❌ Invalid speed input"
            return
        }
        this.OnSpeedInputChanged()
        
        if (!IsNumber(this.controls.volumeInput.Text)) {
            MsgBox("Please enter a valid number for volume.", "Invalid Volume", "Iconx")
            this.controls.volumeInput.Text := this.audioSettings.volumeBoost
            this.controls.statusLabel.Text := "❌ Invalid volume input"
            return
        }
        this.OnVolumeInputChanged()
        
        this.ttsPlayer.PlayText(this.controls.textBox, this.controls.voiceDropdown, 
                               this.controls.statusLabel, this.controls.playButton, this.controls.stopButton)
    }
    
    OnStopPlayback(*) {
        this.ttsPlayer.StopPlayback(this.controls.statusLabel, this.controls.playButton, this.controls.stopButton)
    }
    
    OnSaveAudio(*) {
        ; Validate inputs before saving
        if (!IsNumber(this.controls.speedInput.Text)) {
            MsgBox("Please enter a valid number for speed.", "Invalid Speed", "Iconx")
            this.controls.speedInput.Text := Round(this.audioSettings.speechSpeed, 2)
            this.controls.statusLabel.Text := "❌ Invalid speed input"
            return
        }
        this.OnSpeedInputChanged()
        
        if (!IsNumber(this.controls.volumeInput.Text)) {
            MsgBox("Please enter a valid number for volume.", "Invalid Volume", "Iconx")
            this.controls.volumeInput.Text := this.audioSettings.volumeBoost
            this.controls.statusLabel.Text := "❌ Invalid volume input"
            return
        }
        this.OnVolumeInputChanged()
        
        this.ttsPlayer.SaveAudio(this.controls.textBox, this.controls.voiceDropdown, this.controls.statusLabel)
    }
    
    OnStartOCR(*) {
        this.controls.statusLabel.Text := "Select area for OCR..."
        ; OCR functionality handled by hotkey manager
    }
    
    ; New event handlers
    OnShowDependencyInfo(*) {
        this.app.ShowDependencyInfo()
    }
    
    OnShowHelp(*) {
        helpText := "🎙️ Piper TTS Help`n`n"
        helpText .= "📝 Basic Usage:`n"
        helpText .= "1. Select a voice from the dropdown`n"
        helpText .= "2. Enter text to speak`n"
        helpText .= "3. Click Play or use hotkeys`n`n"
        helpText .= "⌨️ Hotkeys:`n"
        helpText .= "• CapsLock + C: Copy selected text and play`n"
        helpText .= "• CapsLock + X: OCR screen area and play`n"
        helpText .= "• CapsLock + S: Stop playback`n`n"
        helpText .= "🔧 Audio Settings:`n"
        helpText .= "• Enhanced: Better quality with filters`n"
        helpText .= "• Speed: 0.5x to 2.0x playback speed`n"
        helpText .= "• Volume: -10dB to +20dB boost`n`n"
        helpText .= "📁 Files:`n"
        helpText .= "• Voices: Place .onnx files in voices folder`n"
        helpText .= "• Dependencies: FFmpeg and Piper required`n`n"
        helpText .= "ℹ️ Click 'Dependencies' to check installation status."
        
        MsgBox(helpText, "Help - Piper TTS", "Iconi")
    }
    
    OnExit(*) {
        this.app.SaveSettings()
        this.ttsPlayer.Cleanup()
        ExitApp()
    }
    
    UpdateQualityInfo() {
        this.controls.qualityLabel.Text := this.audioSettings.GetQualityDescription()
    }
    
    ShowGUI() {
        this.gui.Show("w296 h380")  ; Increased height for new buttons
    }
    
    GetTextBox() {
        return this.controls.textBox
    }
}