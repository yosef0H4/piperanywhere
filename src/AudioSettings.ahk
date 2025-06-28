; Updated AudioSettings.ahk - Now supports dynamic paths from DependencyChecker
#Requires AutoHotkey v2

class AudioSettings {
    
    __New() {
        this.speechSpeed := 1.0
        this.volumeBoost := 2
        this.sentenceSilence := 0.2
        this.minWordsPerSentence := 6
        this.maxWordsPerSentence := 25
        
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
    
    SetMinWords(minWords) {
        if (IsNumber(minWords) && minWords > 0) {
            this.minWordsPerSentence := minWords
            return true
        }
        return false
    }
    
    SetMaxWords(maxWords) {
        if (IsNumber(maxWords) && maxWords > 0) {
            this.maxWordsPerSentence := maxWords
            return true
        }
        return false
    }
    
    BuildAudioCommand(voiceFile, tempTextFile) {
        ; Build the piper command with dynamic path
        piperCmd := 'type "' . tempTextFile . '" | "' . this.piperPath . '" --model ".\voices\' . voiceFile . '"'
        piperCmd .= ' --length_scale ' . (1 / this.speechSpeed)
        piperCmd .= ' --sentence_silence ' . this.sentenceSilence
        piperCmd .= ' --output-raw'
        
        command := A_ComSpec . ' /c ' . piperCmd
        command .= ' | "' . this.ffplayPath . '" -f s16le -ar 22050 -ch_layout mono -nodisp -autoexit -'
        
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