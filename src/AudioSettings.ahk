; Updated AudioSettings.ahk - Now supports dynamic paths from DependencyChecker
#Requires AutoHotkey v2

class AudioSettings {
    
    __New() {
        this.useAudioEnhancement := true
        this.speechSpeed := 1.0
        this.volumeBoost := 2
        this.sentenceSilence := 0.2
        
        ; Default paths (will be updated by DependencyChecker)
        this.piperPath := ".\piper\piper.exe"
        this.ffmpegPath := ".\ffmpeg\bin\ffmpeg.exe"
        this.ffplayPath := ".\ffmpeg\bin\ffplay.exe"
    }
    
    ; Set the paths for executables (called by DependencyChecker)
    SetExecutablePaths(piperPath, ffmpegPath, ffplayPath) {
        this.piperPath := piperPath
        this.ffmpegPath := ffmpegPath
        this.ffplayPath := ffplayPath
    }
    
    SetEnhancement(enabled) {
        this.useAudioEnhancement := enabled
    }
    
    SetSpeed(speed) {
        if (IsNumber(speed) && speed > 0) {
            this.speechSpeed := speed
            return true
        }
        return false
    }
    
    SetVolume(volume) {
        if (IsNumber(volume)) {
            this.volumeBoost := volume
            return true
        }
        return false
    }
    
    GetQualityDescription() {
        if (this.useAudioEnhancement) {
            return "🎵 Enhanced: Dynamic Normalization + Volume Control + Speech Compression"
        } else {
            return "🔇 Standard: Direct Piper output"
        }
    }
    
    BuildAudioCommand(voiceFile, tempTextFile) {
        ; Build the piper command with dynamic path
        piperCmd := 'type "' . tempTextFile . '" | "' . this.piperPath . '" --model ".\voices\' . voiceFile . '"'
        piperCmd .= ' --length_scale ' . (1 / this.speechSpeed)
        piperCmd .= ' --sentence_silence ' . this.sentenceSilence
        piperCmd .= ' --output-raw'
        
        if (this.useAudioEnhancement) {
            audioFilters := "dynaudnorm=p=0.9:s=5"
            
            if (this.volumeBoost != 0) {
                audioFilters .= ",volume=" . this.volumeBoost . "dB"
            }
            
            audioFilters .= ",compand=.3|.3:1|1:-90/-60|-60/-40|-40/-30|-20/-20:6:0:-90:0.2"
            
            command := A_ComSpec . ' /c ' . piperCmd 
            command .= ' | "' . this.ffmpegPath . '" -f s16le -ar 22050 -ch_layout mono -i - -af "' . audioFilters . '" -f wav -'
            command .= ' | "' . this.ffplayPath . '" -f wav -nodisp -autoexit -'
        } else {
            command := A_ComSpec . ' /c ' . piperCmd
            command .= ' | "' . this.ffplayPath . '" -f s16le -ar 22050 -ch_layout mono -nodisp -autoexit -'
        }
        
        return command
    }
    
    BuildSaveCommand(voiceFile, tempTextFile, outputFile) {
        ; Build the piper command with dynamic path
        piperCmd := 'type "' . tempTextFile . '" | "' . this.piperPath . '" --model ".\voices\' . voiceFile . '"'
        piperCmd .= ' --length_scale ' . (1 / this.speechSpeed)
        piperCmd .= ' --sentence_silence ' . this.sentenceSilence
        piperCmd .= ' --output-raw'
        
        if (this.useAudioEnhancement) {
            audioFilters := "dynaudnorm=p=0.9:s=5"
            
            if (this.volumeBoost != 0) {
                audioFilters .= ",volume=" . this.volumeBoost . "dB"
            }
            
            audioFilters .= ",compand=.3|.3:1|1:-90/-60|-60/-40|-40/-30|-20/-20:6:0:-90:0.2"
            
            command := A_ComSpec . ' /c ' . piperCmd 
            command .= ' | "' . this.ffmpegPath . '" -f s16le -ar 22050 -ch_layout mono -i - -af "' . audioFilters . '" "' . outputFile . '"'
        } else {
            command := A_ComSpec . ' /c ' . piperCmd
            command .= ' | "' . this.ffmpegPath . '" -f s16le -ar 22050 -ch_layout mono -i - "' . outputFile . '"'
        }
        
        return command
    }
    
    ; Get current executable paths for diagnostic purposes
    GetExecutablePaths() {
        return {
            piper: this.piperPath,
            ffmpeg: this.ffmpegPath,
            ffplay: this.ffplayPath
        }
    }
    
    ; Validate that all paths exist
    ValidatePaths() {
        paths := this.GetExecutablePaths()
        
        missingPaths := []
        for name, path in paths.OwnProps() {
            if (!FileExist(path)) {
                missingPaths.Push(name . ": " . path)
            }
        }
        
        return {
            valid: missingPaths.Length = 0,
            missing: missingPaths
        }
    }
}