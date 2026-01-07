# Work Time Reminder

A macOS menu bar application that reminds you to take regular breaks while working, helping protect your health and maintain productivity.

![Preview](preview.png)

## ✨ Features

- 🕐 **Regular Reminders**: Get notified to take breaks after your set work interval
- ⚡ **Customizable Intervals**: Choose from presets (15, 20, 25, 30, 45, 60, 90, 120 minutes) or set custom duration
- 📺 **Auto Screen Saver**: Optionally activate screen saver when break time arrives
- 🔔 **Native Notifications**: Uses macOS system notifications
- 💾 **Persistent Settings**: Your preferences are automatically saved
- 🌐 **Multi-language**: Supports English and Vietnamese
- 🎨 **Beautiful UI**: Custom animated status bar icon with progress indicator

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
2. Download the latest `.dmg` file
3. Open the DMG and drag the app to Applications folder

### Option 3: Build from Xcode

1. Open Xcode and create a new project:
   - File → New → Project
   - Select "macOS" → "App"
   - Product Name: `WorkTimeReminder`
   - Interface: SwiftUI
   - Language: Swift

2. Copy the Swift files into the project:
   - `WorkTimeReminderApp.swift`
   - `ContentView.swift`
   - `ReminderManager.swift`
   - `LocalizationManager.swift`

3. Update Info.plist with the content from the `Info.plist` file in this folder

4. Build and run (Cmd + R)

### Option 4: Build from Terminal

```bash
cd WorkTimeReminder

# Build with the included script
./build.sh

# The app will be created at build/WorkTimeReminder.app
```

## 📖 Usage

1. **Launch the app**: The app will appear in the menu bar (top right corner of the screen)
2. **Enable/Disable reminders**: Click the icon and toggle the switch at the top
3. **Set work interval**: Click preset time buttons or enter a custom duration in minutes
4. **Screen Saver**: Enable this option in Settings if you want the screen saver to activate automatically on break time
5. **Test**: Click "Test notification" to preview the notification

## 📱 Status Bar Icon States

| State | Color | Description |
|-------|-------|-------------|
| **Normal** | 🩵 Teal | Counting down (>5 minutes remaining) |
| **Warning** | 🟠 Orange | Less than 5 minutes remaining |
| **Urgent** | 🔴 Red | Less than 1 minute remaining |
| **Paused** | ⚫ Gray | Reminders disabled |

## ⚙️ System Requirements

- macOS 12.0 (Monterey) or later
- Xcode 14.0 or later (for building)

## 🔒 Permissions Required

- **Notifications**: To send break reminders
- The app runs as a menu bar app (no Dock icon)

## 📝 Notes

- Uses the Pomodoro technique with a default of 25 minutes work interval
- Settings are saved to UserDefaults and persist across app restarts
- Screen saver is activated using the system command `open -a ScreenSaverEngine`

## 🛠 Project Structure

```
WorkTimeReminder/
├── Package.swift
├── README.md
├── build.sh
├── project.yml                      # XcodeGen configuration
└── WorkTimeReminder/
    ├── WorkTimeReminderApp.swift    # App entry point & AppDelegate
    ├── ContentView.swift            # Main UI with navigation
    ├── ReminderManager.swift        # Settings management
    ├── LocalizationManager.swift    # Multi-language support
    ├── Info.plist                   # App configuration
    └── WorkTimeReminder.entitlements
```

## 🌐 Supported Languages

- 🇺🇸 English
- 🇻🇳 Vietnamese (Tiếng Việt)

## 📄 License

MIT License
