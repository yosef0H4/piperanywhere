# 🎙️ piperAnywhere

**An advanced text-to-speech annotation tool that lets you read text anywhere on your screen**

piperAnywhere is a powerful, open-source application that brings high-quality text-to-speech capabilities to any text on your computer. Whether you want to listen to selected text, perform OCR on screen areas, or simply convert written content to speech, piperAnywhere makes it effortless with intuitive hotkeys and a user-friendly interface.

> **🎯 Usage Note**: This application is designed to be used primarily through **global hotkeys** for seamless, system-wide text-to-speech. The GUI is provided for configuration and user-friendliness, but the real power lies in the keyboard shortcuts that work anywhere on your system.

## 👥 Who Is This For?

### ✅ Perfect For:
- **Efficiency Seekers**: People who prefer listening to text while multitasking or want to consume content faster
- **Learning Differences**: Individuals with dyslexia, ADHD, or other conditions that make reading challenging
- **Vision Support**: Users with weak vision, eye strain, or visual fatigue who benefit from audio assistance
- **Language Learners**: People who can understand spoken language but struggle with reading comprehension
- **Accessibility Needs**: Those requiring reading assistance but not full screen reader functionality

### ❌ Not Designed For:
- **Blind Users**: This is not a full screen reader replacement - it's designed for sighted users who want selective text-to-speech
- **Screen Reader Expectations**: If you need comprehensive navigation and system accessibility, use dedicated screen reader software
- **Enterprise/Commercial Use**: The GPL v3.0 license restricts commercial distribution without source code availability

## ✨ Features

- **🎵 High-Quality Text-to-Speech**: Powered by Piper TTS for natural-sounding voice synthesis
- **⌨️ Global Hotkeys**: Read text anywhere with simple keyboard shortcuts
- **🔍 OCR Integration**: Select any screen area and have the text read aloud instantly
- **⏸️ Pause & Resume**: Pause playback at any sentence and resume exactly where you left off
- **🎛️ Advanced Audio Controls**: Speed adjustment, volume boost, and audio enhancement
- **🗣️ Multiple Voice Support**: Easy voice model management and selection - use any compatible voice model
- **💾 Audio Export**: Save speech as WAV files for later use
- **🎨 Modern UI**: Clean, intuitive interface with real-time status updates

## 🚀 Quick Start

### Automated Installation (Recommended)

1. **Download** the latest release from the releases page
2. **Run** `piperAnywhereWizard.exe` - the installer will automatically download and configure all dependencies
3. **Launch** the application and start converting text to speech!

### Manual Installation

If you prefer to set up dependencies manually or want more control over the installation:

#### Step 1: Download piperAnywhere
1. **Download** only `piperAnywhere.exe` from the [releases page](https://github.com/yosef0H4/piperanywhere/releases)
2. **Create** a folder structure like this:

```
piperAnywhere/
├── piperAnywhere.exe          # Main application
├── LICENSE                    # GPL v3.0 license
├── piper/                     # Piper TTS engine
│   └── piper.exe
├── ffmpeg/                    # Audio processing
│   ├── bin/
│   │   ├── ffmpeg.exe
│   │   └── ffplay.exe
└── voices/                    # Voice models (.onnx files)
    ├── en_GB-alba-medium.onnx      # Sample voice (optional)
    └── en_GB-alba-medium.onnx.json # Sample voice config (optional)
```

#### Step 2: Install Dependencies

You can install dependencies either **locally** (in the piperAnywhere folder) or **system-wide** (accessible from anywhere). piperAnywhere will automatically detect both.

##### 🎤 Piper TTS Engine
- **Download**: [Piper TTS Releases](https://github.com/rhasspy/piper/releases)
- **Local Installation**: Extract `piper` to `piperAnywhere/piper` ensure you have `piperAnywhere/piper/piper.exe`
- **System Installation**: Add piper.exe to your system PATH

##### 🎬 FFmpeg Audio Processing
- **Download**: [FFmpeg Official Downloads](https://ffmpeg.org/download.html)
- **Local Installation**: Extract the `bin` folder contents to `piperAnywhere/ffmpeg/bin/`
  - Ensure you have both `ffmpeg.exe` and `ffplay.exe`
- **System Installation**: Add FFmpeg to your system PATH

##### 🗣️ Voice Models
- **Browse All Voices**: [Piper Voice Models](https://huggingface.co/rhasspy/piper-voices/tree/main)
- **Local Installation**: Download both `.onnx` and `.onnx.json` files to `piperAnywhere/voices/`
- **Recommended Voice**: `en_GB-alba-medium.onnx`
- **Multiple languages available**: Browse the full collection for your preferred language and quality level

#### Step 3: Verify Installation
1. **Run** `piperAnywhere.exe`
2. **Check** that all dependencies are detected in the application
3. **Test** text-to-speech functionality

> **💡 Pro Tip**: You can mix local and system installations. For example, install FFmpeg system-wide but keep Piper and voices local to the application folder.

### Basic Usage

**Primary Method (Hotkeys - Recommended):**
1. **Copy & Play**: Select any text anywhere, press `CapsLock + C` to copy and play
2. **OCR & Play**: Press `CapsLock + X`, draw a rectangle around text, and it will be read aloud
3. **Pause & Resume**: Press `CapsLock + A` to pause playback and resume from the same sentence

**Secondary Method (GUI):**
1. **Manual Text Input**: Type or paste text into the text box and click "Play"
2. **Control Playback**: Use Play, Pause, and Stop buttons for full control

## ⌨️ Hotkeys

| Hotkey | Action |
|--------|--------|
| `CapsLock + C` | Copy selected text and play it |
| `CapsLock + X` | OCR screen area and play the detected text |
| `CapsLock + A` | Pause/Resume current playback |
| `CapsLock + S` | Stop current playback |

> **Note**: CapsLock is disabled and repurposed for these hotkeys to prevent accidental activation.

## 🎛️ Playback Controls

### Smart Pause & Resume
- **Sentence-Level Pausing**: Pause at any sentence and resume exactly where you left off
- **Memory Retention**: Pause position is remembered until you stop playback or change text
- **Visual Feedback**: Status shows current sentence position when paused
- **Hotkey & GUI Support**: Control playback through both keyboard shortcuts and interface buttons

### Playback States
- **▶ Play**: Start reading from the beginning or resume from paused position
- **⏸ Pause**: Stop at current sentence and save position for resuming
- **⏹ Stop**: Completely stop playback and reset to beginning
- **Auto-Reset**: Pause position resets when text changes or playback completes

## 🔧 Audio Settings

- **Enhanced Mode**: Enables dynamic normalization, volume control, and speech compression
- **Speed Control**: Adjust playback speed from 0.5x to 2.0x
- **Volume Boost**: Fine-tune audio levels from -10dB to +20dB
- **Voice Selection**: Choose from installed voice models
- **Sentence Management**: Control minimum and maximum words per sentence for optimal pacing

## 📁 Project Structure

```
piperAnywhere/
├── piperAnywhere.exe          # Main application
├── LICENSE                    # GPL v3.0 license
├── piper/                     # Piper TTS engine
│   └── piper.exe
├── ffmpeg/                    # Audio processing
│   ├── bin/
│   │   ├── ffmpeg.exe
│   │   └── ffplay.exe
└── voices/                    # Voice models (.onnx files)
    ├── en_GB-alba-medium.onnx      # Sample voice (optional)
    └── en_GB-alba-medium.onnx.json # Sample voice config (optional)
```

## 🛠️ Components & Dependencies

piperAnywhere integrates several high-quality open-source components:

### Core Components
- **[Piper TTS](https://github.com/rhasspy/piper)** - High-quality neural text-to-speech engine
- **[FFmpeg](https://ffmpeg.org/)** - Audio processing and playback
- **[eSpeak NG](https://github.com/espeak-ng/espeak-ng)** - Phoneme processing (used by Piper)
- **[OCR Library](https://github.com/Descolada/OCR/)** by Descolada - Screen text recognition
- **AutoHotkey v2** - Application framework

### Voice Models
- **Multiple Languages Available** - Browse the full collection at [Piper Voice Models](https://huggingface.co/rhasspy/piper-voices/tree/main)
- **Quality Levels**: Low, medium, and high quality models available
- **Note**: You can use any compatible Piper voice model

### APIs & Libraries
- **Windows.Media.Ocr** - Windows UWP OCR API

## 🏗️ Building from Source

### Prerequisites
- AutoHotkey v2 (v2.1-alpha.18 recommended, not tested on other versions)
- All dependencies (automatically managed by DependencyChecker)

### Development Structure
```
piperAnywhere/                     # Development directory
├── piperAnywhere.ahk              # Main application entry point
├── piperAnywhere.exe              # needed if you want to build wizard
├── piperAnywhereWizard.ahk        # needed if you want to edit the wizard
├── LICENSE                        # GPL v3.0 license
├── src/                           # Source code modules
│   ├── AudioSettings.ahk          # Audio processing configuration
│   ├── DependencyChecker.ahk      # Automatic dependency management
│   ├── HotkeyManager.ahk          # Global hotkey handling
│   ├── Highlighter.ahk            # Screen area highlighting
│   ├── RectangleCreator.ahk       # OCR area selection
│   ├── TTSPlayer.ahk              # Text-to-speech playback with pause/resume
│   ├── UIManager.ahk              # User interface management
│   └── VoiceManager.ahk           # Voice model management
├── Lib/                           # External libraries
│   └── OCR.ahk                    # OCR integration library
├── piper/                         # Piper TTS engine (required for dev)
│   └── piper.exe
├── ffmpeg/                        # Audio processing (required for dev)
│   ├── bin/
│   │   ├── ffmpeg.exe
│   │   └── ffplay.exe
└── voices/                        # Voice models (required for dev)
    ├── en_GB-alba-medium.onnx      # Sample voice
    └── en_GB-alba-medium.onnx.json # Sample voice config
```

### Build Steps
1. Clone the repository
2. Install AutoHotkey v2
3. Ensure piper, ffmpeg, and voices directories are present with required executables
4. Run `piperAnywhere.ahk` directly or compile with Ahk2Exe
5. For distribution, use `piperAnywhereWizard.exe` installer

## 🤝 Contributing

Contributions are welcome! Please ensure:

1. **License Compatibility**: All contributions must be compatible with GPL v3.0
2. **Code Style**: Follow the existing AutoHotkey v2 conventions
3. **Testing**: Test with multiple voice models and audio configurations
4. **Documentation**: Update README and code comments as needed

## 🆘 Support

### Troubleshooting

**"Dependencies not found"**: 
- **Automated Setup**: Run `piperAnywhereWizard.exe` to install or reinstall required components
- **Manual Setup**: Ensure all dependencies are properly installed either locally or system-wide

**"No voices found"**: 
- **Automated Setup**: Voice models are installed by the wizard installer. If missing, run the wizard installer again
- **Manual Setup**: Download voice models from [Piper Voice Models](https://huggingface.co/rhasspy/piper-voices/tree/main) and place them in the `voices/` folder

**"Audio issues"**: Try disabling audio enhancement in settings or adjusting volume levels.

**"Pause not working"**: Ensure text is actively playing before attempting to pause. The pause button is only enabled during playback.

### System Requirements
- Windows 10/11 (64-bit)
- Internet connection (for initial setup if using automated installer)
- ~100MB disk space for full installation

## 🙏 Acknowledgments

Special thanks to:

- **Michael Hansen** and the Rhasspy team for creating Piper TTS
- **Descolada** for the excellent AutoHotkey OCR library
- **University of Edinburgh** for the Alba voice dataset
- **FFmpeg developers** for audio processing capabilities
- **eSpeak NG contributors** for phoneme processing
- **AutoHotkey community** for the powerful scripting platform
- **Microsoft** for the Windows.Media.Ocr UWP API

## 📄 License & Attribution

piperAnywhere is released under the **GNU General Public License v3.0**.

### Component Licenses

| Component | License | Attribution |
|-----------|---------|-------------|
| **piperAnywhere** | GPL v3.0 | Copyright (C) 2025 |
| **Piper TTS** | MIT License | Copyright (c) 2022 Michael Hansen |
| **eSpeak NG** | GPL v3.0 | eSpeak NG contributors |
| **FFmpeg** | LGPL v2.1+ | FFmpeg developers |
| **Alba Voice Model** | CC BY 4.0 | University of Edinburgh (optional) |
| **OCR Library** | MIT License | Copyright (c) Descolada |

### Required Attributions

**FFmpeg LGPL Compliance**: This software uses code of [FFmpeg](http://ffmpeg.org) licensed under the [LGPLv2.1](http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html) and its source can be downloaded from the [FFmpeg project](https://github.com/FFmpeg/FFmpeg).

**OCR Library**: OCR functionality provided by Descolada's AutoHotkey OCR library (https://github.com/Descolada/OCR/), which utilizes the Windows UWP Windows.Media.Ocr library.

### GPL v3.0 Compliance

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

**Source Code**: Available in this repository under GPL v3.0 terms

### FFmpeg LGPL Compliance

This software complies with FFmpeg's LGPL v2.1 license requirements:

- **Dynamic Linking**: Uses FFmpeg through command-line execution (no static linking)
- **Source Code Availability**: FFmpeg source code is available at https://github.com/FFmpeg/FFmpeg
- **Attribution**: Proper attribution provided in application and documentation
- **License Distribution**: LGPL v2.1 license terms available to all users
- **No GPL Components**: Uses LGPL-only build of FFmpeg without GPL extensions

**LGPL v2.1 Requirements**: You must give prominent notice that the FFmpeg library is used and that it is covered by the LGPL v2.1 license. If you redistribute this software, you must provide access to FFmpeg source code and comply with LGPL terms.

---

**Made with ❤️ for the text-to-speech community**

*This project stands on the shoulders of giants - thank you to all the open-source contributors who made this possible!*# 🎙️ piperAnywhere

**An advanced text-to-speech annotation tool that lets you read text anywhere on your screen**

piperAnywhere is a powerful, open-source application that brings high-quality text-to-speech capabilities to any text on your computer. Whether you want to listen to selected text, perform OCR on screen areas, or simply convert written content to speech, piperAnywhere makes it effortless with intuitive hotkeys and a user-friendly interface.

> **🎯 Usage Note**: This application is designed to be used primarily through **global hotkeys** for seamless, system-wide text-to-speech. The GUI is provided for configuration and user-friendliness, but the real power lies in the keyboard shortcuts that work anywhere on your system.

## 👥 Who Is This For?

### ✅ Perfect For:
- **Efficiency Seekers**: People who prefer listening to text while multitasking or want to consume content faster
- **Learning Differences**: Individuals with dyslexia, ADHD, or other conditions that make reading challenging
- **Vision Support**: Users with weak vision, eye strain, or visual fatigue who benefit from audio assistance
- **Language Learners**: People who can understand spoken language but struggle with reading comprehension
- **Accessibility Needs**: Those requiring reading assistance but not full screen reader functionality

### ❌ Not Designed For:
- **Blind Users**: This is not a full screen reader replacement - it's designed for sighted users who want selective text-to-speech
- **Screen Reader Expectations**: If you need comprehensive navigation and system accessibility, use dedicated screen reader software
- **Enterprise/Commercial Use**: The GPL v3.0 license restricts commercial distribution without source code availability

## ✨ Features

- **🎵 High-Quality Text-to-Speech**: Powered by Piper TTS for natural-sounding voice synthesis
- **⌨️ Global Hotkeys**: Read text anywhere with simple keyboard shortcuts
- **🔍 OCR Integration**: Select any screen area and have the text read aloud instantly
- **⏸️ Pause & Resume**: Pause playback at any sentence and resume exactly where you left off
- **🎛️ Advanced Audio Controls**: Speed adjustment, volume boost, and audio enhancement
- **🗣️ Multiple Voice Support**: Easy voice model management and selection - use any compatible voice model
- **💾 Audio Export**: Save speech as WAV files for later use
- **🎨 Modern UI**: Clean, intuitive interface with real-time status updates

## 🚀 Quick Start

### Automated Installation (Recommended)

1. **Download** the latest release from the releases page
2. **Run** `piperAnywhereWizard.exe` - the installer will automatically download and configure all dependencies
3. **Launch** the application and start converting text to speech!

### Manual Installation

If you prefer to set up dependencies manually or want more control over the installation:

#### Step 1: Download piperAnywhere
1. **Download** only `piperAnywhere.exe` from the [releases page](https://github.com/yosef0H4/piperanywhere/releases)
2. **Create** a folder structure like this:

```
piperAnywhere/
├── piperAnywhere.exe          # Main application
├── LICENSE                    # GPL v3.0 license
├── piper/                     # Piper TTS engine
│   └── piper.exe
├── ffmpeg/                    # Audio processing
│   ├── bin/
│   │   ├── ffmpeg.exe
│   │   └── ffplay.exe
└── voices/                    # Voice models (.onnx files)
    ├── en_GB-alba-medium.onnx      # Sample voice (optional)
    └── en_GB-alba-medium.onnx.json # Sample voice config (optional)
```

#### Step 2: Install Dependencies

You can install dependencies either **locally** (in the piperAnywhere folder) or **system-wide** (accessible from anywhere). piperAnywhere will automatically detect both.

##### 🎤 Piper TTS Engine
- **Download**: [Piper TTS Releases](https://github.com/rhasspy/piper/releases)
- **Local Installation**: Extract `piper` to `piperAnywhere/piper` ensure you have `piperAnywhere/piper/piper.exe`
- **System Installation**: Add piper.exe to your system PATH

##### 🎬 FFmpeg Audio Processing
- **Download**: [FFmpeg Official Downloads](https://ffmpeg.org/download.html)
- **Local Installation**: Extract the `bin` folder contents to `piperAnywhere/ffmpeg/bin/`
  - Ensure you have both `ffmpeg.exe` and `ffplay.exe`
- **System Installation**: Add FFmpeg to your system PATH

##### 🗣️ Voice Models
- **Browse All Voices**: [Piper Voice Models](https://huggingface.co/rhasspy/piper-voices/tree/main)
- **Local Installation**: Download both `.onnx` and `.onnx.json` files to `piperAnywhere/voices/`
- **Recommended Voice**: `en_GB-alba-medium.onnx`
- **Multiple languages available**: Browse the full collection for your preferred language and quality level

#### Step 3: Verify Installation
1. **Run** `piperAnywhere.exe`
2. **Check** that all dependencies are detected in the application
3. **Test** text-to-speech functionality

> **💡 Pro Tip**: You can mix local and system installations. For example, install FFmpeg system-wide but keep Piper and voices local to the application folder.

### Basic Usage

**Primary Method (Hotkeys - Recommended):**
1. **Copy & Play**: Select any text anywhere, press `CapsLock + C` to copy and play
2. **OCR & Play**: Press `CapsLock + X`, draw a rectangle around text, and it will be read aloud
3. **Pause & Resume**: Press `CapsLock + A` to pause playback and resume from the same sentence

**Secondary Method (GUI):**
1. **Manual Text Input**: Type or paste text into the text box and click "Play"
2. **Control Playback**: Use Play, Pause, and Stop buttons for full control

## ⌨️ Hotkeys

| Hotkey | Action |
|--------|--------|
| `CapsLock + C` | Copy selected text and play it |
| `CapsLock + X` | OCR screen area and play the detected text |
| `CapsLock + A` | Pause/Resume current playback |
| `CapsLock + S` | Stop current playback |

> **Note**: CapsLock is disabled and repurposed for these hotkeys to prevent accidental activation.

## 🎛️ Playback Controls

### Smart Pause & Resume
- **Sentence-Level Pausing**: Pause at any sentence and resume exactly where you left off
- **Memory Retention**: Pause position is remembered until you stop playback or change text
- **Visual Feedback**: Status shows current sentence position when paused
- **Hotkey & GUI Support**: Control playback through both keyboard shortcuts and interface buttons

### Playback States
- **▶ Play**: Start reading from the beginning or resume from paused position
- **⏸ Pause**: Stop at current sentence and save position for resuming
- **⏹ Stop**: Completely stop playback and reset to beginning
- **Auto-Reset**: Pause position resets when text changes or playback completes

## 🔧 Audio Settings

- **Enhanced Mode**: Enables dynamic normalization, volume control, and speech compression
- **Speed Control**: Adjust playback speed from 0.5x to 2.0x
- **Volume Boost**: Fine-tune audio levels from -10dB to +20dB
- **Voice Selection**: Choose from installed voice models
- **Sentence Management**: Control minimum and maximum words per sentence for optimal pacing

## 📁 Project Structure

```
piperAnywhere/
├── piperAnywhere.exe          # Main application
├── LICENSE                    # GPL v3.0 license
├── piper/                     # Piper TTS engine
│   └── piper.exe
├── ffmpeg/                    # Audio processing
│   ├── bin/
│   │   ├── ffmpeg.exe
│   │   └── ffplay.exe
└── voices/                    # Voice models (.onnx files)
    ├── en_GB-alba-medium.onnx      # Sample voice (optional)
    └── en_GB-alba-medium.onnx.json # Sample voice config (optional)
```

## 🛠️ Components & Dependencies

piperAnywhere integrates several high-quality open-source components:

### Core Components
- **[Piper TTS](https://github.com/rhasspy/piper)** - High-quality neural text-to-speech engine
- **[FFmpeg](https://ffmpeg.org/)** - Audio processing and playback
- **[eSpeak NG](https://github.com/espeak-ng/espeak-ng)** - Phoneme processing (used by Piper)
- **[OCR Library](https://github.com/Descolada/OCR/)** by Descolada - Screen text recognition
- **AutoHotkey v2** - Application framework

### Voice Models
- **Multiple Languages Available** - Browse the full collection at [Piper Voice Models](https://huggingface.co/rhasspy/piper-voices/tree/main)
- **Quality Levels**: Low, medium, and high quality models available
- **Note**: You can use any compatible Piper voice model

### APIs & Libraries
- **Windows.Media.Ocr** - Windows UWP OCR API

## 🏗️ Building from Source

### Prerequisites
- AutoHotkey v2 (v2.1-alpha.18 recommended, not tested on other versions)
- All dependencies (automatically managed by DependencyChecker)

### Development Structure
```
piperAnywhere/                     # Development directory
├── piperAnywhere.ahk              # Main application entry point
├── piperAnywhere.exe              # needed if you want to build wizard
├── piperAnywhereWizard.ahk        # needed if you want to edit the wizard
├── LICENSE                        # GPL v3.0 license
├── src/                           # Source code modules
│   ├── AudioSettings.ahk          # Audio processing configuration
│   ├── DependencyChecker.ahk      # Automatic dependency management
│   ├── HotkeyManager.ahk          # Global hotkey handling
│   ├── Highlighter.ahk            # Screen area highlighting
│   ├── RectangleCreator.ahk       # OCR area selection
│   ├── TTSPlayer.ahk              # Text-to-speech playback with pause/resume
│   ├── UIManager.ahk              # User interface management
│   └── VoiceManager.ahk           # Voice model management
├── Lib/                           # External libraries
│   └── OCR.ahk                    # OCR integration library
├── piper/                         # Piper TTS engine (required for dev)
│   └── piper.exe
├── ffmpeg/                        # Audio processing (required for dev)
│   ├── bin/
│   │   ├── ffmpeg.exe
│   │   └── ffplay.exe
└── voices/                        # Voice models (required for dev)
    ├── en_GB-alba-medium.onnx      # Sample voice
    └── en_GB-alba-medium.onnx.json # Sample voice config
```

### Build Steps
1. Clone the repository
2. Install AutoHotkey v2
3. Ensure piper, ffmpeg, and voices directories are present with required executables
4. Run `piperAnywhere.ahk` directly or compile with Ahk2Exe
5. For distribution, use `piperAnywhereWizard.exe` installer

## 🤝 Contributing

Contributions are welcome! Please ensure:

1. **License Compatibility**: All contributions must be compatible with GPL v3.0
2. **Code Style**: Follow the existing AutoHotkey v2 conventions
3. **Testing**: Test with multiple voice models and audio configurations
4. **Documentation**: Update README and code comments as needed

## 🆘 Support

### Troubleshooting

**"Dependencies not found"**: 
- **Automated Setup**: Run `piperAnywhereWizard.exe` to install or reinstall required components
- **Manual Setup**: Ensure all dependencies are properly installed either locally or system-wide

**"No voices found"**: 
- **Automated Setup**: Voice models are installed by the wizard installer. If missing, run the wizard installer again
- **Manual Setup**: Download voice models from [Piper Voice Models](https://huggingface.co/rhasspy/piper-voices/tree/main) and place them in the `voices/` folder

**"Audio issues"**: Try disabling audio enhancement in settings or adjusting volume levels.

**"Pause not working"**: Ensure text is actively playing before attempting to pause. The pause button is only enabled during playback.

### System Requirements
- Windows 10/11 (64-bit)
- Internet connection (for initial setup if using automated installer)
- ~100MB disk space for full installation

## 🙏 Acknowledgments

Special thanks to:

- **Michael Hansen** and the Rhasspy team for creating Piper TTS
- **Descolada** for the excellent AutoHotkey OCR library
- **University of Edinburgh** for the Alba voice dataset
- **FFmpeg developers** for audio processing capabilities
- **eSpeak NG contributors** for phoneme processing
- **AutoHotkey community** for the powerful scripting platform
- **Microsoft** for the Windows.Media.Ocr UWP API

## 📄 License & Attribution

piperAnywhere is released under the **GNU General Public License v3.0**.

### Component Licenses

| Component | License | Attribution |
|-----------|---------|-------------|
| **piperAnywhere** | GPL v3.0 | Copyright (C) 2025 |
| **Piper TTS** | MIT License | Copyright (c) 2022 Michael Hansen |
| **eSpeak NG** | GPL v3.0 | eSpeak NG contributors |
| **FFmpeg** | LGPL v2.1+ | FFmpeg developers |
| **Alba Voice Model** | CC BY 4.0 | University of Edinburgh (optional) |
| **OCR Library** | MIT License | Copyright (c) Descolada |

### Required Attributions

**FFmpeg LGPL Compliance**: This software uses code of [FFmpeg](http://ffmpeg.org) licensed under the [LGPLv2.1](http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html) and its source can be downloaded from the [FFmpeg project](https://github.com/FFmpeg/FFmpeg).

**OCR Library**: OCR functionality provided by Descolada's AutoHotkey OCR library (https://github.com/Descolada/OCR/), which utilizes the Windows UWP Windows.Media.Ocr library.

### GPL v3.0 Compliance

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

**Source Code**: Available in this repository under GPL v3.0 terms

### FFmpeg LGPL Compliance

This software complies with FFmpeg's LGPL v2.1 license requirements:

- **Dynamic Linking**: Uses FFmpeg through command-line execution (no static linking)
- **Source Code Availability**: FFmpeg source code is available at https://github.com/FFmpeg/FFmpeg
- **Attribution**: Proper attribution provided in application and documentation
- **License Distribution**: LGPL v2.1 license terms available to all users
- **No GPL Components**: Uses LGPL-only build of FFmpeg without GPL extensions

**LGPL v2.1 Requirements**: You must give prominent notice that the FFmpeg library is used and that it is covered by the LGPL v2.1 license. If you redistribute this software, you must provide access to FFmpeg source code and comply with LGPL terms.

---

**Made with ❤️ for the text-to-speech community**

*This project stands on the shoulders of giants - thank you to all the open-source contributors who made this possible!*