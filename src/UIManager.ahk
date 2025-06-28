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
       
       ; Language maps for UI text
       this.englishMap := Map(
           "playButton", "▶ Play",
           "stopButton", "⏹ Stop",
           "pauseButton", "⏸ Pause",
           "refreshButton", "↻",
           "voicesButton", "📁",
           "languageGroup", "Language",
           "voiceGroup", "Voice Selection",
           "audioGroup", "Audio Settings",
           "textGroup", "Text to Speak",
           "controlsGroup", "Controls",
           "enhancedCheckbox", "🔊 Enhanced",
           "speedLabel", "Speed:",
           "slowLabel", "Slow",
           "fastLabel", "Fast",
           "volumeLabel", "Volume:",
           "quietLabel", "Quiet",
           "loudLabel", "Loud",
           "dbLabel", "dB",
           "readyStatus", "Ready",
           "hintsText", "💡 Hotkeys: CapsLock+C (Copy & Play) • CapsLock+X (OCR & Play) • CapsLock+Z (Refresh OCR) • CapsLock+S (Stop)",
           "defaultText", "Enhanced Piper TTS with object-oriented design and improved maintainability.",
           "saveAudioMenu", "💾 &Save Audio",
           "dependenciesMenu", "ℹ️ &Dependencies",
           "helpMenu", "❓ &Help",
           "aboutMenu", "ℹ️ &About",
           "exitMenu", "✖️ &Exit",
           "voiceRefreshed", "Voice list refreshed",
           "voicesFolderOpened", "Opened voices folder",
           "voicesFolderNotFound", "Voices folder not found!",
           "audioEnhancementEnabled", "Audio enhancement enabled",
           "audioEnhancementDisabled", "Audio enhancement disabled",
           "invalidSpeed", "❌ Invalid speed: Not a number",
           "speedSet", "Speed set to",
           "invalidVolume", "❌ Invalid volume: Not a number",
           "volumeSet", "Volume set to",
           "invalidSpeedInput", "❌ Invalid speed input",
           "invalidVolumeInput", "❌ Invalid volume input",
           "ocrSelectArea", "Select area for OCR...",
           "languageChangedTo", "Language changed to",
           "invalidSpeedTitle", "Invalid Speed",
           "invalidVolumeTitle", "Invalid Volume",
           "invalidSpeedMessage", "Please enter a valid number for speed.",
           "invalidVolumeMessage", "Please enter a valid number for volume.",
           "errorTitle", "Error",
           "minWordsLabel", "Min:",
           "minWordsInput", "Min words:",
           "maxWordsLabel", "Max:",
           "maxWordsInput", "Max words:",
           "invalidMinWords", "❌ Invalid min words: Not a number",
           "minWordsSet", "Min words set to",
           "invalidMaxWords", "❌ Invalid max words: Not a number",
           "maxWordsSet", "Max words set to"
       )
       
       this.arabicMap := Map(
           "playButton", "▶ تشغيل",
           "stopButton", "⏹ إيقاف",
           "pauseButton", "⏸ إيقاف مؤقت",
           "refreshButton", "↻",
           "voicesButton", "📁",
           "languageGroup", "اللغة",
           "voiceGroup", "اختيار الصوت",
           "audioGroup", "إعدادات الصوت",
           "textGroup", "النص المراد قراءته",
           "controlsGroup", "التحكم",
           "enhancedCheckbox", "🔊 محسن",
           "speedLabel", "السرعة:",
           "slowLabel", "بطيء",
           "fastLabel", "سريع",
           "volumeLabel", "الصوت:",
           "quietLabel", "هادئ",
           "loudLabel", "عالي",
           "dbLabel", "ديسيبل",
           "readyStatus", "جاهز",
           "hintsText", "💡 المفاتيح المختصرة: CapsLock+C (نسخ وتشغيل) • CapsLock+X (OCR وتشغيل) • CapsLock+Z (تحديث OCR) • CapsLock+S (إيقاف)",
           "defaultText", "محرك Piper TTS المحسن مع تصميم شيئي ومرونة محسنة في الصيانة.",
           "saveAudioMenu", "💾 &حفظ الصوت",
           "dependenciesMenu", "ℹ️ &التبعيات",
           "helpMenu", "❓ &مساعدة",
           "aboutMenu", "ℹ️ &حول",
           "exitMenu", "✖️ &خروج",
           "voiceRefreshed", "تم تحديث قائمة الأصوات",
           "voicesFolderOpened", "تم فتح مجلد الأصوات",
           "voicesFolderNotFound", "لم يتم العثور على مجلد الأصوات!",
           "audioEnhancementEnabled", "تم تفعيل تحسين الصوت",
           "audioEnhancementDisabled", "تم إلغاء تحسين الصوت",
           "invalidSpeed", "❌ سرعة غير صحيحة: ليس رقماً",
           "speedSet", "تم تعيين السرعة إلى",
           "invalidVolume", "❌ مستوى صوت غير صحيح: ليس رقماً",
           "volumeSet", "تم تعيين مستوى الصوت إلى",
           "invalidSpeedInput", "❌ إدخال سرعة غير صحيح",
           "invalidVolumeInput", "❌ إدخال مستوى صوت غير صحيح",
           "ocrSelectArea", "حدد المنطقة لـ OCR...",
           "languageChangedTo", "تم تغيير اللغة إلى",
           "invalidSpeedTitle", "سرعة غير صحيحة",
           "invalidVolumeTitle", "مستوى صوت غير صحيح",
           "invalidSpeedMessage", "يرجى إدخال رقم صحيح للسرعة.",
           "invalidVolumeMessage", "يرجى إدخال رقم صحيح لمستوى الصوت.",
           "errorTitle", "خطأ",
           "minWordsLabel", "أدنى:",
           "minWordsInput", "أدنى كلمات:",
           "maxWordsLabel", "أعلى:",
           "maxWordsInput", "أعلى كلمات:",
           "invalidMinWords", "❌ أدنى كلمات غير صحيح: ليس رقماً",
           "minWordsSet", "تم تعيين أدنى كلمات إلى",
           "invalidMaxWords", "❌ أعلى كلمات غير صحيح: ليس رقماً",
           "maxWordsSet", "تم تعيين أعلى كلمات إلى"
       )
    }
    
    CreateGUI() {
        this.gui := Gui("+Resize -MaximizeBox", "PiperAnywhere")
        this.gui.MarginX := 8
        this.gui.MarginY := 8
        this.gui.SetFont("s9", "Segoe UI")
        
        ; Create a MenuBar and a File menu
        this.menuBar := MenuBar()
        this.fileMenu := Menu()
        this.menuBar.Add("&File", this.fileMenu)
        this.gui.MenuBar := this.menuBar
        
        ; Language section (New)
        this.CreateLanguageSection()
        
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
        
        ; Add menu items to the File menu
        this.CreateMenuItems()
    }
    
    CreateLanguageSection() {
        this.controls.languageGroup := this.gui.AddGroupBox("x8 y8 w280 h50", this.GetText("languageGroup"))
        this.controls.languageGroup.SetFont("s8 Bold", "Segoe UI")
        this.controls.languageDropdown := this.gui.AddDropDownList("x16 y26 w200 h200", ["English", "Arabic"])
        this.controls.languageDropdown.Choose(1)
       
       ; Set up language change event handler
       this.controls.languageDropdown.OnEvent("Change", ObjBindMethod(this, "OnLanguageChanged"))
    }
    
    CreateVoiceSection() {
        this.controls.voiceGroup := this.gui.AddGroupBox("x8 y66 w280 h50", this.GetText("voiceGroup"))
        this.controls.voiceGroup.SetFont("s8 Bold", "Segoe UI")
        
        this.controls.voiceDropdown := this.gui.AddDropDownList("x16 y84 w200 h200", [])
        this.controls.refreshButton := this.gui.AddButton("x220 y84 w25 h21", this.GetText("refreshButton"))
        this.controls.refreshButton.SetFont("s8")
        
        this.controls.voicesButton := this.gui.AddButton("x248 y84 w32 h21", this.GetText("voicesButton"))
        this.controls.voicesButton.SetFont("s8")
    }
    
    CreateAudioSection() {
        this.controls.audioGroup := this.gui.AddGroupBox("x8 y124 w280 h110", this.GetText("audioGroup"))
        this.controls.audioGroup.SetFont("s8 Bold", "Segoe UI")
        
        ; Enhancement toggle
        this.controls.enhancementCheckbox := this.gui.AddCheckbox("x16 y142 w90 h16 Checked", this.GetText("enhancedCheckbox"))
        this.controls.enhancementCheckbox.SetFont("s8")
        
        ; Speed control
        this.controls.speedLabel := this.gui.AddText("x16 y162 w25", this.GetText("speedLabel"))
        this.controls.slowLabel := this.gui.AddText("x+6 y162 w35", this.GetText("slowLabel"))
        this.controls.speedSlider := this.gui.AddSlider("x100 y160 w60 h20 Range50-200 NoTicks", 100)
        this.controls.fastLabel := this.gui.AddText("x+6 y162 w25", this.GetText("fastLabel"))
        this.controls.speedInput := this.gui.AddEdit("x+6 y162 w30 h16", "1.0")
        this.controls.speedInput.SetFont("s8 Bold")
        
        ; Volume control
        this.controls.volumeLabel := this.gui.AddText("x16 y178", this.GetText("volumeLabel"))
        this.controls.quietLabel := this.gui.AddText("x+3 y178", this.GetText("quietLabel"))
        this.controls.volumeSlider := this.gui.AddSlider("x100 y176 w60 h20 Range-10-20 NoTicks", 2)
        this.controls.loudLabel := this.gui.AddText("x+6 y178 w30 h16", this.GetText("loudLabel"))
        this.controls.volumeInput := this.gui.AddEdit("x+6 y178 w30 h16", "2")
        this.controls.volumeInput.SetFont("s8 Bold")
        this.controls.dbLabel := this.gui.AddText("x+6 y178 w30 h16", this.GetText("dbLabel"))
        
        ; Word count controls
        this.controls.minWordsLabel := this.gui.AddText("x16 y194 w40", this.GetText("minWordsLabel"))
        this.controls.minWordsInput := this.gui.AddEdit("x+6 y194 w30 h16", "6")
        this.controls.minWordsInput.SetFont("s8 Bold")
        this.controls.maxWordsLabel := this.gui.AddText("x+6 y194 w40", this.GetText("maxWordsLabel"))
        this.controls.maxWordsInput := this.gui.AddEdit("x+6 y194 w30 h16", "25")
        this.controls.maxWordsInput.SetFont("s8 Bold")
    }
    
    CreateTextSection() {
        this.controls.textGroup := this.gui.AddGroupBox("x8 y215 w280 h80", this.GetText("textGroup"))
        this.controls.textGroup.SetFont("s8 Bold", "Segoe UI")
        
        this.controls.textBox := this.gui.AddEdit("x16 y235 w264 h54 VScroll", 
                                            this.GetText("defaultText"))
    }
    
    CreateControlButtons() {
        this.controls.buttonGroup := this.gui.AddGroupBox("x8 y290 w280 h60", this.GetText("controlsGroup"))
        this.controls.buttonGroup.SetFont("s8 Bold", "Segoe UI")
        
        ; Control buttons
       this.controls.playButton := this.gui.AddButton("x16 y308 w50 h24 Default", this.GetText("playButton"))
        this.controls.playButton.SetFont("s8 Bold")
        
        this.controls.pauseButton := this.gui.AddButton("x70 y308 w60 h24 Disabled", this.GetText("pauseButton"))
        this.controls.pauseButton.SetFont("s8 Bold")
        
        this.controls.stopButton := this.gui.AddButton("x135 y308 w50 h24 Disabled", this.GetText("stopButton"))
        this.controls.stopButton.SetFont("s8 Bold")
        
        
    }
    
    CreateStatusSection() {
        this.controls.statusLabel := this.gui.AddText("x8 y334 w280 h16 Center", this.GetText("readyStatus"))
        this.controls.statusLabel.SetFont("s8", "Segoe UI")
        
        this.controls.qualityLabel := this.gui.AddText("x8 y350 w280 h16 Center", "")
        this.controls.qualityLabel.SetFont("s7", "Segoe UI")
        
        this.controls.hintLabel := this.gui.AddText("x8 y366 w280 h32 Center", 
                                              this.GetText("hintsText"))
        this.controls.hintLabel.SetFont("s7", "Segoe UI")
    }
    
    CreateMenuItems() {
        this.fileMenu.Add(this.GetText("saveAudioMenu"), ObjBindMethod(this, "OnSaveAudio"))
        this.fileMenu.Add(this.GetText("dependenciesMenu"), ObjBindMethod(this, "OnShowDependencyInfo"))
        this.fileMenu.Add(this.GetText("helpMenu"), ObjBindMethod(this, "OnShowHelp"))
        this.fileMenu.Add(this.GetText("aboutMenu"), ObjBindMethod(this, "OnShowAbout"))
        this.fileMenu.Add(this.GetText("exitMenu"), ObjBindMethod(this, "OnExit"))
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
        this.controls.pauseButton.OnEvent("Click", ObjBindMethod(this, "OnPausePlayback"))
        this.controls.minWordsInput.OnEvent("LoseFocus", ObjBindMethod(this, "OnMinWordsInputChanged"))
        this.controls.maxWordsInput.OnEvent("LoseFocus", ObjBindMethod(this, "OnMaxWordsInputChanged"))
        
        ; GUI close event
        this.gui.OnEvent("Close", ObjBindMethod(this, "OnExit"))
    }
    
    ; Event handlers
    OnLanguageChanged(*) {
        this.UpdateAllTexts()
        selectedLanguage := this.controls.languageDropdown.Text
        this.controls.statusLabel.Text := this.GetText("languageChangedTo") . " " . selectedLanguage
    }
    
    UpdateAllTexts() {
        ; Update group boxes
        this.controls.languageGroup.Text := this.GetText("languageGroup")
        this.controls.voiceGroup.Text := this.GetText("voiceGroup")
        this.controls.audioGroup.Text := this.GetText("audioGroup")
        this.controls.textGroup.Text := this.GetText("textGroup")
        this.controls.buttonGroup.Text := this.GetText("controlsGroup")
        
        ; Update buttons
        this.controls.playButton.Text := this.GetText("playButton")
        this.controls.stopButton.Text := this.GetText("stopButton")
        this.controls.pauseButton.Text := this.GetText("pauseButton")
        this.controls.refreshButton.Text := this.GetText("refreshButton")
        this.controls.voicesButton.Text := this.GetText("voicesButton")
        
        ; Update checkbox
        this.controls.enhancementCheckbox.Text := this.GetText("enhancedCheckbox")
        
        ; Update labels
        this.controls.speedLabel.Text := this.GetText("speedLabel")
        this.controls.slowLabel.Text := this.GetText("slowLabel")
        this.controls.fastLabel.Text := this.GetText("fastLabel")
        this.controls.volumeLabel.Text := this.GetText("volumeLabel")
        this.controls.quietLabel.Text := this.GetText("quietLabel")
        this.controls.loudLabel.Text := this.GetText("loudLabel")
        this.controls.dbLabel.Text := this.GetText("dbLabel")
        
        ; Update hints
        this.controls.hintLabel.Text := this.GetText("hintsText")
        
        ; Update status
        this.controls.statusLabel.Text := this.GetText("readyStatus")
        
        ; Update text box placeholder
        if (this.controls.textBox.Text = this.englishMap["defaultText"] || this.controls.textBox.Text = this.arabicMap["defaultText"]) {
            this.controls.textBox.Text := this.GetText("defaultText")
        }
        
        ; Recreate menu items
        this.fileMenu.Delete()
        this.CreateMenuItems()
        
        ; Update word count labels
        this.controls.minWordsLabel.Text := this.GetText("minWordsLabel")
        this.controls.maxWordsLabel.Text := this.GetText("maxWordsLabel")
    }
    
    OnRefreshVoices(*) {
        this.voiceManager.PopulateVoices(this.controls.voiceDropdown, this.controls.statusLabel)
        this.controls.statusLabel.Text := this.GetText("voiceRefreshed")
    }
    
    OnOpenVoicesFolder(*) {
        if (this.voiceManager.OpenVoicesFolder()) {
            this.controls.statusLabel.Text := this.GetText("voicesFolderOpened")
        } else {
            MsgBox(this.GetText("voicesFolderNotFound"), this.GetText("errorTitle"), "Iconx")
        }
    }
    
    OnEnhancementToggled(*) {
        this.audioSettings.SetEnhancement(this.controls.enhancementCheckbox.Value)
        this.UpdateQualityInfo()
        this.controls.statusLabel.Text := this.audioSettings.useAudioEnhancement ? 
                                        this.GetText("audioEnhancementEnabled") : this.GetText("audioEnhancementDisabled")
    }
    
    OnSpeedChanged(*) {
        speed := this.controls.speedSlider.Value / 100.0
        this.audioSettings.SetSpeed(speed)
        this.controls.speedInput.Text := Round(speed, 2)
    }
    
    OnSpeedInputChanged(*) {
        newSpeed := this.controls.speedInput.Text
        
        if (!this.audioSettings.SetSpeed(newSpeed)) {
            this.controls.statusLabel.Text := this.GetText("invalidSpeed")
            this.controls.speedInput.Text := Round(this.audioSettings.speechSpeed, 2)
            return
        }
        
        this.controls.speedSlider.Value := Round(this.audioSettings.speechSpeed * 100)
        this.controls.statusLabel.Text := this.GetText("speedSet") . " " . Round(this.audioSettings.speechSpeed, 2) . "x"
    }
    
    OnVolumeChanged(*) {
        volume := this.controls.volumeSlider.Value
        this.audioSettings.SetVolume(volume)
        this.controls.volumeInput.Text := volume
    }
    
    OnVolumeInputChanged(*) {
        newVolume := this.controls.volumeInput.Text
        
        if (!this.audioSettings.SetVolume(newVolume)) {
            this.controls.statusLabel.Text := this.GetText("invalidVolume")
            this.controls.volumeInput.Text := this.audioSettings.volumeBoost
            return
        }
        
        this.controls.volumeSlider.Value := Round(this.audioSettings.volumeBoost)
        this.controls.statusLabel.Text := this.GetText("volumeSet") . " " . Round(this.audioSettings.volumeBoost, 1) . this.GetText("dbLabel")
    }
    
    OnPlayText(*) {
        ; Validate inputs before playback
        if (!IsNumber(this.controls.speedInput.Text)) {
            MsgBox(this.GetText("invalidSpeedMessage"), this.GetText("invalidSpeedTitle"), "Iconx")
            this.controls.speedInput.Text := Round(this.audioSettings.speechSpeed, 2)
            this.controls.statusLabel.Text := this.GetText("invalidSpeedInput")
            return
        }
        this.OnSpeedInputChanged()
        
        if (!IsNumber(this.controls.volumeInput.Text)) {
            MsgBox(this.GetText("invalidVolumeMessage"), this.GetText("invalidVolumeTitle"), "Iconx")
            this.controls.volumeInput.Text := this.audioSettings.volumeBoost
            this.controls.statusLabel.Text := this.GetText("invalidVolumeInput")
            return
        }
        this.OnVolumeInputChanged()
        
        this.ttsPlayer.PlayText(this.controls.textBox, this.controls.voiceDropdown, 
                               this.controls.statusLabel, this.controls.playButton, this.controls.stopButton)
        
        ; Enable pause button when playback starts
        this.controls.pauseButton.Enabled := true
    }
    
    OnStopPlayback(*) {
        this.ttsPlayer.StopPlayback(this.controls.statusLabel, this.controls.playButton, this.controls.stopButton)
        this.controls.pauseButton.Enabled := false
    }
    
    OnPausePlayback(*) {
        this.ttsPlayer.PausePlayback(this.controls.statusLabel, this.controls.playButton, this.controls.pauseButton, this.controls.stopButton)
    }
    
    OnSaveAudio(*) {
        ; Validate inputs before saving
        if (!IsNumber(this.controls.speedInput.Text)) {
            MsgBox(this.GetText("invalidSpeedMessage"), this.GetText("invalidSpeedTitle"), "Iconx")
            this.controls.speedInput.Text := Round(this.audioSettings.speechSpeed, 2)
            this.controls.statusLabel.Text := this.GetText("invalidSpeedInput")
            return
        }
        this.OnSpeedInputChanged()
        
        if (!IsNumber(this.controls.volumeInput.Text)) {
            MsgBox(this.GetText("invalidVolumeMessage"), this.GetText("invalidVolumeTitle"), "Iconx")
            this.controls.volumeInput.Text := this.audioSettings.volumeBoost
            this.controls.statusLabel.Text := this.GetText("invalidVolumeInput")
            return
        }
        this.OnVolumeInputChanged()
        
        this.ttsPlayer.SaveAudio(this.controls.textBox, this.controls.voiceDropdown, this.controls.statusLabel)
    }
    
    OnStartOCR(*) {
        this.controls.statusLabel.Text := this.GetText("ocrSelectArea")
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
        helpText .= "• CapsLock + Z: Refresh OCR from last saved area`n"
        helpText .= "• CapsLock + S: Stop playback`n"
        helpText .= "• CapsLock + A: Toggle pause playback`n"
        helpText .= "• CapsLock + Scroll Down: Go to previous sentence`n"
        helpText .= "• CapsLock + Scroll Up: Go to next sentence`n`n"
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
    
    OnShowAbout(*) {
        aboutText := "🎙️ piperAnywhere v0.2`n" .
                    "Text-to-Speech Annotation Tool`n`n" .
                    "Copyright (C) 2025 yousef abdullah`n" .
                    "Licensed under GPL v3.0`n`n" .
                    "Source: https://github.com/yosef0H4/piperanywhere`n`n" .
                    "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n" .
                    "THIRD-PARTY COMPONENTS:`n`n" .
                    "• This software uses libraries from the FFmpeg project under the LGPLv2.1`n" .
                    "  Source: https://github.com/FFmpeg/FFmpeg`n" .
                    "  License: https://www.gnu.org/licenses/old-licenses/lgpl-2.1.html`n`n" .
                    "• Piper TTS Engine (MIT License)`n" .
                    "  Source: https://github.com/rhasspy/piper`n`n" .
                    "• OCR Library by Descolada (MIT License)`n" .
                    "  Source: https://github.com/Descolada/OCR/`n`n" .
                    "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n" .
                    "For complete license terms, see LICENSE file in same directory."
        
        MsgBox(aboutText, "About piperAnywhere", "Iconi")
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
        this.gui.Show("w296 h418")
    }
    
    GetTextBox() {
        return this.controls.textBox
    }
    
    GetText(key) {
        selectedLanguage := this.controls.HasOwnProp("languageDropdown") ? this.controls.languageDropdown.Text : "English"
        
        if (selectedLanguage = "Arabic") {
            return this.arabicMap[key]
        } else {
            return this.englishMap[key]
        }
    }
    
    OnMinWordsInputChanged(*) {
        newMinWords := this.controls.minWordsInput.Text
        if (!this.audioSettings.SetMinWords(newMinWords)) {
            this.controls.statusLabel.Text := this.GetText("invalidMinWords")
            this.controls.minWordsInput.Text := this.audioSettings.minWordsPerSentence
            return
        }
        this.controls.statusLabel.Text := this.GetText("minWordsSet") . " " . this.audioSettings.minWordsPerSentence
    }
    
    OnMaxWordsInputChanged(*) {
        newMaxWords := this.controls.maxWordsInput.Text
        if (!this.audioSettings.SetMaxWords(newMaxWords)) {
            this.controls.statusLabel.Text := this.GetText("invalidMaxWords")
            this.controls.maxWordsInput.Text := this.audioSettings.maxWordsPerSentence
            return
        }
        this.controls.statusLabel.Text := this.GetText("maxWordsSet") . " " . this.audioSettings.maxWordsPerSentence
    }
    
    LoadSettings() {
        this.audioSettings.SetMinWords(IniRead(this.settingsFile, "Settings", "MinWords", 6))
        this.audioSettings.SetMaxWords(IniRead(this.settingsFile, "Settings", "MaxWords", 25))
        this.controls.minWordsInput.Text := this.audioSettings.minWordsPerSentence
        this.controls.maxWordsInput.Text := this.audioSettings.maxWordsPerSentence
    }
    
    SaveSettings() {
        try {
            IniWrite(this.audioSettings.minWordsPerSentence, this.settingsFile, "Settings", "MinWords")
            IniWrite(this.audioSettings.maxWordsPerSentence, this.settingsFile, "Settings", "MaxWords")
        } catch as err {
            ; Optional: MsgBox("Error saving settings: " . err.Message, "Save Error", "Iconx")
        }
    }
}