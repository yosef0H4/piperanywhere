# 🎙️ piperAnywhere

**Advanced text-to-speech tool that reads text anywhere on your screen**

High-quality text-to-speech with global hotkeys, OCR integration, and smart playback controls. Run from source code to avoid antivirus false positives.

## 👥 Who This Is For
✅ Perfect for: People with dyslexia/ADHD, vision strain, language learners, efficiency seekers, and anyone needing selective text-to-speech assistance.
❌ Not for: Blind users (use dedicated screen readers), enterprise/commercial use (GPL v3.0 restrictions).

> **💡 Recommended**: Run from source code rather than compiled executables to avoid antivirus issues.

## ✨ Key Features

- **🎵 High-Quality TTS**: Neural text-to-speech powered by Piper TTS
- **⌨️ Global Hotkeys**: Read text anywhere with CapsLock combinations
- **🔍 Smart OCR**: Select screen areas and have text read aloud instantly
- **⏸️ Sentence Navigation**: Pause/resume at any sentence, navigate with scroll wheel
- **🎛️ Audio Controls**: Speed (0.5x-2.0x), volume boost, audio enhancement
- **🌐 Multi-Language**: English/Arabic interface, supports all Piper voice models
- **🧹 Text Processing**: Optional cleaning, smart sentence splitting

## 🚀 Quick Start

### 🔧 Running from Source (Recommended)

1. **Clone repository**: `git clone https://github.com/yosef0H4/piperanywhere.git`
2. **Download OCR library**: Save [OCR.ahk](https://raw.githubusercontent.com/Descolada/OCR/main/Lib/OCR.ahk) to `Lib/OCR.ahk`
3. **Create folders**: Make these directories in your piperAnywhere folder:
   - `piper/`
   - `ffmpeg/bin/` 
   - `voices/`

**Download Dependencies:**
- **Piper TTS**: [Download piper.exe](https://github.com/rhasspy/piper/releases) → `piper/piper.exe`
- **FFmpeg**: [Download FFmpeg](https://ffmpeg.org/download.html) → `ffmpeg/bin/ffmpeg.exe` & `ffplay.exe`
- **Voice Models**: [Browse voices](https://huggingface.co/rhasspy/piper-voices/tree/main) → `voices/` (try `en_GB-alba-medium.onnx`)

**Requirements:** [AutoHotkey v2.1-alpha.18 installed](https://www.autohotkey.com/download/2.1/)

**Run:** Double-click `piperAnywhere.ahk` or run from command line

### 🎯 Automated Installation (Convenience)

Download `piperAnywhereWizard.exe` from releases. May trigger antivirus false positives.

## ⌨️ Hotkeys

| Hotkey | Action |
|--------|--------|
| `CapsLock + C` | Copy selected text and play |
| `CapsLock + X` | OCR screen area and play |
| `CapsLock + Z` | Refresh last OCR area |
| `CapsLock + A` | Pause/Resume |
| `CapsLock + S` | Stop |
| `CapsLock + Scroll` | Navigate sentences (release CapsLock to play) |

## 🎛️ Advanced Features

### Smart Playback
- **Sentence-level control**: Navigate, pause, and resume at any sentence
- **Mouse wheel navigation**: Hold CapsLock + scroll to jump between sentences
- **Visual feedback**: Real-time tooltips show current sentence
- **Index jumping**: Type sentence number to jump directly

### OCR Memory
- **Area persistence**: Last OCR area automatically saved
- **Quick refresh**: Re-scan same area without redrawing
- **Visual confirmation**: Highlights show OCR operations

### Audio Enhancement
- **Professional processing**: Dynamic normalization, compression, volume control
- **Text cleaning**: Remove emojis and decorative characters
- **Sentence management**: Configurable word limits for optimal pacing

## 🛠️ Components & Legal

piperAnywhere integrates these open-source components:

| Component | License | Source |
|-----------|---------|---------|
| **piperAnywhere** | GPL v3.0 | Copyright (C) 2025 |
| **Piper TTS** | MIT | [GitHub](https://github.com/rhasspy/piper) |
| **FFmpeg** | LGPL v2.1+ | [GitHub](https://github.com/FFmpeg/FFmpeg) |
| **OCR Library** | MIT | [GitHub](https://github.com/Descolada/OCR/) |
| **eSpeak NG** | GPL v3.0 | Used by Piper TTS |

### FFmpeg LGPL Compliance
This software uses [FFmpeg](http://ffmpeg.org) licensed under [LGPLv2.1](http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html). Source available at the [FFmpeg project](https://github.com/FFmpeg/FFmpeg). Uses dynamic execution (no static linking).

### GPL v3.0 License
This program is free software under GPL v3.0. You can redistribute and/or modify it under the terms of the GNU General Public License. Source code available in this repository.

## 🆘 Troubleshooting

**Antivirus flags executable**: Use source code method instead of compiled .exe
**Dependencies not found**: Check folder structure, use Dependencies menu in app
**No voices found**: Download .onnx files to voices/ folder, click refresh button
**Navigation issues**: Ensure text is playing, release CapsLock after scrolling
**System Requirements**: Windows 10/11 (64-bit), AutoHotkey v2, ~100MB disk space

## 🙏 Acknowledgments

Special thanks to:

- **Michael Hansen** and the Rhasspy team for creating [Piper TTS](https://github.com/rhasspy/piper)
- **Descolada** for the excellent [AutoHotkey OCR library](https://github.com/Descolada/OCR/)
- **University of Edinburgh** for the Alba voice dataset
- **FFmpeg developers** for [audio processing capabilities](https://ffmpeg.org/)
- **eSpeak NG contributors** for [phoneme processing](https://github.com/espeak-ng/espeak-ng)
- **AutoHotkey community** for the [powerful scripting platform](https://www.autohotkey.com/)
- **Microsoft** for the Windows.Media.Ocr UWP API

## 📝 Creator's Note

**I take no credit for creating this software.** This project is essentially an integration of existing excellent open-source components:

- **Most of the actual work** was done by the brilliant developers acknowledged above
- **Most of the code** was generated and refined with AI assistance
- **My contribution** was primarily project assembly, testing, and documentation

This is a testament to the power of open-source collaboration and modern AI-assisted development. The real heroes are the original library authors and the open-source community.

---

**Made with ❤️ for the text-to-speech community**

*GPL v3.0 licensed • Source code transparency • No proprietary components*