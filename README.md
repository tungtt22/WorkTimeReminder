# Work Time Reminder

A lightweight macOS menu bar application that reminds you to take regular breaks while working, helping protect your health and maintain productivity.

![macOS](https://img.shields.io/badge/macOS-12.0+-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![License](https://img.shields.io/badge/License-MIT-green)

## ✨ Features

### Core Features
- 🕐 **Smart Reminders**: Get notified to take breaks after your set work interval
- ⚡ **Customizable Intervals**: Choose from presets (15, 25, 30, 45, 60 min) or use stepper control
- 🎨 **Beautiful Status Bar Icon**: Custom animated icon with progress indicator
- 📺 **Full Screen Alert**: Eye-catching overlay with customizable colors and duration
- 🔔 **System Notifications**: Native macOS notifications with sound options

### Advanced Features
- 🔄 **Auto Reset**: Automatically reset timer when screen is locked/sleep for break duration
- ☀️ **Keep Awake**: Option to prevent screen from sleeping while working
- 📺 **Screen Saver Integration**: Auto-activate screen saver on break time
- 🔊 **Sound Options**: Multiple notification sounds to choose from
- 🌐 **Multi-language**: English and Vietnamese support

### Performance
- ⚡ **Lightweight**: ~55 MB RAM, <1% CPU when idle
- 🚀 **Fast Startup**: ~0.1 second launch time
- 🔋 **Battery Friendly**: Optimized with icon caching and smart updates
- 💾 **Persistent Settings**: Preferences saved automatically

## 🚀 Installation

### Option 1: Homebrew (Recommended)

```bash
# Add the tap
brew tap tungtt22/tap

# Install the app
brew install --cask work-time-reminder
```

To update:
```bash
brew upgrade --cask work-time-reminder
```

### Option 2: Download from Releases

1. Go to [Releases](https://github.com/tungtt22/WorkTimeReminder/releases)
2. Download the latest `.zip` file
3. Extract and drag `WorkTimeReminder.app` to Applications folder

### Option 3: Build from Source

```bash
git clone https://github.com/tungtt22/WorkTimeReminder.git
cd WorkTimeReminder

# Build with the included script
./build.sh

# Install to Applications
cp -r build/WorkTimeReminder.app /Applications/

# Launch
open /Applications/WorkTimeReminder.app
```

## 📖 Usage

### Basic Usage
1. **Launch**: The app appears in the menu bar (top right)
2. **Toggle**: Click the icon and use the switch to enable/disable
3. **Set Time**: Use stepper or preset buttons to set work interval
4. **Settings**: Click the gear icon for more options

### Settings Options
- **Language**: Switch between English and Vietnamese
- **Full Screen Alert**: Enable/disable overlay, set duration and color
- **Sound**: Choose notification sound
- **Screen Saver**: Auto-activate on break time
- **Keep Awake**: Prevent screen sleep while working
- **Auto Reset**: Reset timer after screen lock/sleep

## 📱 Status Bar Icon States

| State | Color | Description |
|-------|-------|-------------|
| **Normal** | 🩵 Teal | >5 minutes remaining |
| **Warning** | 🟠 Orange | <5 minutes remaining |
| **Urgent** | 🔴 Red | <1 minute remaining |
| **Paused** | ⚫ Gray | Reminders disabled |

## 📊 Performance

| Metric | Value |
|--------|-------|
| Bundle Size | 1.4 MB |
| Startup Time | ~0.1s |
| Memory (idle) | ~55 MB |
| CPU (idle) | <1% |
| Threads | 12 |

Run performance tests:
```bash
./Tests/run_performance_tests.sh
```

## 🛠 Project Structure

```
WorkTimeReminder/
├── build.sh                    # Build script
├── README.md
├── LICENSE
│
├── WorkTimeReminder/
│   ├── App/
│   │   ├── WorkTimeReminderApp.swift   # Entry point
│   │   └── AppDelegate.swift           # App lifecycle & menu bar
│   │
│   ├── Views/
│   │   ├── ContentView.swift           # Main container
│   │   ├── MainScreenView.swift        # Home screen
│   │   ├── SettingsScreenView.swift    # Settings screen
│   │   ├── BreakOverlayView.swift      # Full screen alert
│   │   └── Components/
│   │       └── TimeRemainingView.swift
│   │
│   ├── Models/
│   │   ├── ReminderManager.swift       # State management
│   │   ├── OverlayColor.swift          # Color options
│   │   ├── NotificationSound.swift     # Sound options
│   │   └── AppNotifications.swift      # Notification names
│   │
│   ├── Localization/
│   │   └── LocalizationManager.swift   # Multi-language
│   │
│   └── Resources/
│       ├── AppIcon.icns
│       ├── Info.plist
│       └── WorkTimeReminder.entitlements
│
└── Tests/
    ├── run_performance_tests.sh
    ├── PERFORMANCE_REPORT.md
    └── PerformanceTests/
        ├── PerformanceTests.swift
        └── PerformanceMonitor.swift
```

## ⚙️ System Requirements

- macOS 12.0 (Monterey) or later
- Apple Silicon (M1/M2/M3) or Intel Mac

## 🔒 Permissions

- **Notifications**: For break reminders
- **Accessibility** (optional): For full screen overlay
- Runs as menu bar app (no Dock icon)

## 🌐 Supported Languages

- 🇺🇸 English
- 🇻🇳 Vietnamese (Tiếng Việt)

## 🔄 CI/CD

- **GitHub Actions**: Automated build on push/PR
- **Releases**: Auto-create DMG/ZIP on tag
- **Homebrew**: Auto-update tap on release

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---

Made with ❤️ for better work-life balance
