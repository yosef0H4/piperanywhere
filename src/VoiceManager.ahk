class VoiceManager {
    
    __New() {
        this.voices := []
        this.voicesPath := ".\voices\*.onnx"
    }
    
    PopulateVoices(dropdown, statusLabel) {
        this.voices := []
        dropdown.Delete()
        
        if (!DirExist(".\voices")) {
            dropdown.Add(["❌ No voices directory"])
            dropdown.Choose(1)
            statusLabel.Text := "⚠️ Voices directory not found"
            return false
        }
        
        Loop Files, this.voicesPath {
            cleanName := StrReplace(A_LoopFileName, ".onnx", "")
            cleanName := StrReplace(cleanName, "_", " ")
            displayName := cleanName . " (" . A_LoopFileName . ")"
            this.voices.Push({display: displayName, file: A_LoopFileName})
        }
        
        if (this.voices.Length = 0) {
            dropdown.Add(["❌ No voices found"])
            dropdown.Choose(1)
            statusLabel.Text := "⚠️ No .onnx files found"
            return false
        }
        
        voiceList := []
        for voice in this.voices {
            voiceList.Push(voice.display)
        }
        
        dropdown.Add(voiceList)
        dropdown.Choose(1)
        statusLabel.Text := "✅ " . this.voices.Length . " voice(s) loaded"
        return true
    }
    
    GetSelectedVoice(dropdown) {
        selectedIndex := dropdown.Value
        if (selectedIndex = 0 || selectedIndex > this.voices.Length) {
            return {display: "", file: "", valid: false}
        }
        
        voice := this.voices[selectedIndex]
        if (InStr(voice.display, "❌")) {
            return {display: voice.display, file: "", valid: false}
        }
        
        return {display: voice.display, file: voice.file, valid: true}
    }
    
    OpenVoicesFolder() {
        if (DirExist(".\voices")) {
            Run("explorer.exe .\voices")
            return true
        }
        return false
    }
} 