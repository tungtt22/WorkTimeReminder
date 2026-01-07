import SwiftUI

// MARK: - Navigation State
enum AppScreen {
    case main
    case settings
}

// MARK: - Main Content View
struct ContentView: View {
    @ObservedObject var reminderManager = ReminderManager.shared
    @ObservedObject var localization = LocalizationManager.shared
    weak var appDelegate: AppDelegate?
    @State private var currentScreen: AppScreen = .main
    
    var body: some View {
        ZStack {
            // Main Screen
            MainScreenView(
                appDelegate: appDelegate,
                onSettingsTapped: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        currentScreen = .settings
                    }
                }
            )
            .offset(x: currentScreen == .main ? 0 : -320)
            .opacity(currentScreen == .main ? 1 : 0)
            
            // Settings Screen
            SettingsScreenView(
                appDelegate: appDelegate,
                onBackTapped: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        currentScreen = .main
                    }
                }
            )
            .offset(x: currentScreen == .settings ? 0 : 320)
            .opacity(currentScreen == .settings ? 1 : 0)
        }
        .frame(width: 320, height: 420)
        .background(Color(NSColor.windowBackgroundColor))
        .clipped()
    }
}

// MARK: - Main Screen
struct MainScreenView: View {
    @ObservedObject var reminderManager = ReminderManager.shared
    @ObservedObject var localization = LocalizationManager.shared
    weak var appDelegate: AppDelegate?
    var onSettingsTapped: () -> Void
    @State private var customInterval: String = ""
    
    private var l10n: L10n { L10n.shared }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            Divider()
            
            ScrollView {
                VStack(spacing: 16) {
                    // Status Card
                    statusCard
                    
                    // Interval Selection
                    intervalSection
                }
                .padding(16)
            }
            
            Divider()
            
            // Footer
            footerView
        }
        .frame(width: 320, height: 420)
    }
    
    // MARK: - Header
    var headerView: some View {
        HStack {
            Image(systemName: "clock.badge.checkmark.fill")
                .font(.system(size: 24))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.orange, Color.red],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(l10n.appTitle)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                Text(l10n.appSubtitle)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: Binding(
                get: { reminderManager.isEnabled },
                set: { newValue in
                    reminderManager.isEnabled = newValue
                    if newValue {
                        appDelegate?.startTimer()
                    } else {
                        appDelegate?.stopTimer()
                    }
                }
            ))
            .toggleStyle(SwitchToggleStyle(tint: .orange))
            .labelsHidden()
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [Color.orange.opacity(0.1), Color.clear],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    // MARK: - Status Card
    var statusCard: some View {
        VStack(spacing: 12) {
            if reminderManager.isEnabled {
                HStack {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                    Text(l10n.statusActive)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.green)
                    Spacer()
                }
                
                if let nextDate = reminderManager.nextReminderDate {
                    HStack {
                        Image(systemName: "bell.fill")
                            .foregroundColor(.orange)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(l10n.nextReminder)
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                            TimeRemainingView(targetDate: nextDate)
                        }
                        Spacer()
                    }
                }
            } else {
                HStack {
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 8, height: 8)
                    Text(l10n.statusInactive)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
                .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
        )
    }
    
    // MARK: - Interval Section
    var intervalSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "timer")
                    .foregroundColor(.orange)
                Text(l10n.workInterval)
                    .font(.system(size: 13, weight: .medium))
                Spacer()
                Text("\(reminderManager.intervalMinutes) \(l10n.minutes)")
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    .foregroundColor(.orange)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.15))
                    .cornerRadius(6)
            }
            
            // Preset buttons
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
                ForEach(ReminderManager.presetIntervals, id: \.self) { interval in
                    Button(action: {
                        withAnimation(.spring(response: 0.3)) {
                            reminderManager.intervalMinutes = interval
                            if reminderManager.isEnabled {
                                appDelegate?.startTimer()
                            }
                        }
                    }) {
                        Text("\(interval)")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(reminderManager.intervalMinutes == interval ? 
                                          Color.orange : Color(NSColor.controlBackgroundColor))
                            )
                            .foregroundColor(reminderManager.intervalMinutes == interval ? .white : .primary)
                    }
                    .buttonStyle(.plain)
                }
            }
            
            // Custom interval input
            HStack {
                TextField(l10n.customPlaceholder, text: $customInterval)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 120)
                
                Button(l10n.setButton) {
                    if let value = Int(customInterval), value > 0 {
                        reminderManager.intervalMinutes = value
                        if reminderManager.isEnabled {
                            appDelegate?.startTimer()
                        }
                        customInterval = ""
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
                .disabled(Int(customInterval) == nil || Int(customInterval)! <= 0)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
                .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
        )
    }
    
    // MARK: - Footer
    var footerView: some View {
        HStack {
            Button(action: {
                NSApplication.shared.terminate(nil)
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "power")
                    Text(l10n.quit)
                }
                .font(.system(size: 11))
                .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            // Settings Button
            Button(action: onSettingsTapped) {
                HStack(spacing: 4) {
                    Image(systemName: "gearshape.fill")
                    Text(l10n.settings)
                }
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [Color.purple, Color.blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
            }
            .buttonStyle(.plain)
        }
        .padding(12)
    }
}

// MARK: - Settings Screen
struct SettingsScreenView: View {
    @ObservedObject var reminderManager = ReminderManager.shared
    @ObservedObject var localization = LocalizationManager.shared
    weak var appDelegate: AppDelegate?
    var onBackTapped: () -> Void
    
    private var l10n: L10n { L10n.shared }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            settingsHeader
            
            Divider()
            
            ScrollView {
                VStack(spacing: 16) {
                    // Language Section
                    languageSection
                    
                    // Sound Section
                    soundSection
                    
                    // Screen Saver Section
                    screenSaverSection
                    
                    // Notification Section
                    notificationSection
                    
                    // About Section
                    aboutSection
                }
                .padding(16)
            }
        }
        .frame(width: 320, height: 420)
    }
    
    // MARK: - Settings Header
    var settingsHeader: some View {
        HStack {
            Button(action: onBackTapped) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                    Text(l10n.back)
                        .font(.system(size: 13, weight: .medium))
                }
                .foregroundColor(.purple)
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            Text(l10n.settings)
                .font(.system(size: 16, weight: .bold, design: .rounded))
            
            Spacer()
            
            // Invisible placeholder for centering
            HStack(spacing: 4) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .semibold))
                Text(l10n.back)
                    .font(.system(size: 13, weight: .medium))
            }
            .opacity(0)
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [Color.purple.opacity(0.1), Color.clear],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    // MARK: - Language Section
    var languageSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "globe")
                    .foregroundColor(.purple)
                Text(l10n.language)
                    .font(.system(size: 13, weight: .medium))
                Spacer()
            }
            
            HStack(spacing: 8) {
                ForEach(Language.allCases, id: \.self) { lang in
                    Button(action: {
                        withAnimation(.spring(response: 0.3)) {
                            localization.currentLanguage = lang
                        }
                    }) {
                        HStack {
                            Text(lang.displayName)
                                .font(.system(size: 12, weight: .medium))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(localization.currentLanguage == lang ?
                                      Color.purple : Color(NSColor.controlBackgroundColor))
                        )
                        .foregroundColor(localization.currentLanguage == lang ? .white : .primary)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
                .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
        )
    }
    
    // MARK: - Screen Saver Section
    var screenSaverSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "tv.fill")
                    .foregroundColor(.blue)
                Text("Screen Saver")
                    .font(.system(size: 13, weight: .medium))
                Spacer()
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(l10n.screenSaverTitle)
                        .font(.system(size: 12))
                    Text(l10n.screenSaverSubtitle)
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Toggle("", isOn: $reminderManager.enableScreenSaver)
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                    .labelsHidden()
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(NSColor.windowBackgroundColor))
            )
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
                .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
        )
    }
    
    // MARK: - Sound Section
    var soundSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "speaker.wave.3.fill")
                    .foregroundColor(.green)
                Text(l10n.sound)
                    .font(.system(size: 13, weight: .medium))
                Spacer()
            }
            
            // Enable sound toggle
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(l10n.enableSound)
                        .font(.system(size: 12))
                    Text(l10n.soundWhenNotify)
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Toggle("", isOn: $reminderManager.enableSound)
                    .toggleStyle(SwitchToggleStyle(tint: .green))
                    .labelsHidden()
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(NSColor.windowBackgroundColor))
            )
            
            // Sound picker
            if reminderManager.enableSound {
                VStack(alignment: .leading, spacing: 8) {
                    Text(l10n.selectSound)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    
                    // Sound grid
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 3), spacing: 6) {
                        ForEach(NotificationSound.allCases, id: \.self) { sound in
                            Button(action: {
                                withAnimation(.spring(response: 0.2)) {
                                    reminderManager.notificationSound = sound
                                    reminderManager.playSound(sound)
                                }
                            }) {
                                Text(sound.displayName)
                                    .font(.system(size: 10, weight: .medium))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(reminderManager.notificationSound == sound ?
                                                  Color.green : Color(NSColor.controlBackgroundColor))
                                    )
                                    .foregroundColor(reminderManager.notificationSound == sound ? .white : .primary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(NSColor.windowBackgroundColor))
                )
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
                .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
        )
    }
    
    // MARK: - Notification Section
    var notificationSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "bell.badge.fill")
                    .foregroundColor(.orange)
                Text(l10n.notifications)
                    .font(.system(size: 13, weight: .medium))
                Spacer()
            }
            
            Button(action: {
                appDelegate?.sendNotification()
                if reminderManager.enableScreenSaver {
                    appDelegate?.activateScreenSaver()
                }
            }) {
                HStack {
                    Image(systemName: "bell.and.waves.left.and.right")
                    Text(l10n.testNotification)
                }
                .font(.system(size: 12, weight: .medium))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [Color.orange.opacity(0.2), Color.red.opacity(0.2)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
                .foregroundColor(.orange)
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
                .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
        )
    }
    
    // MARK: - About Section
    var aboutSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.gray)
                Text(l10n.about)
                    .font(.system(size: 13, weight: .medium))
                Spacer()
            }
            
            VStack(spacing: 8) {
                HStack {
                    Text("Version")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("1.0.0")
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                }
                
                Divider()
                
                HStack {
                    Text(l10n.developer)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("Your Name")
                        .font(.system(size: 11, weight: .medium))
                }
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(NSColor.windowBackgroundColor))
            )
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
                .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
        )
    }
}

// MARK: - Time Remaining View
struct TimeRemainingView: View {
    let targetDate: Date
    @State private var timeRemaining: String = ""
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Text(timeRemaining)
            .font(.system(size: 18, weight: .bold, design: .monospaced))
            .foregroundColor(.primary)
            .onReceive(timer) { _ in
                updateTime()
            }
            .onAppear {
                updateTime()
            }
    }
    
    func updateTime() {
        let remaining = targetDate.timeIntervalSinceNow
        if remaining > 0 {
            let minutes = Int(remaining) / 60
            let seconds = Int(remaining) % 60
            timeRemaining = String(format: "%02d:%02d", minutes, seconds)
        } else {
            timeRemaining = "00:00"
        }
    }
}

#Preview {
    ContentView(appDelegate: nil)
}
