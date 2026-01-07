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
    
    // Consistent accent color
    private let accentColor = Color(red: 0.4, green: 0.6, blue: 0.8)
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            Divider().opacity(0.5)
            
            // Content
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    statusCard
                    intervalSection
                }
                .padding(16)
            }
            
            Divider().opacity(0.5)
            
            // Footer
            footerView
        }
        .frame(width: 320, height: 420)
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    // MARK: - Header
    var headerView: some View {
        HStack(spacing: 12) {
            // App icon
            Image(systemName: "clock.fill")
                .font(.system(size: 20))
                .foregroundColor(accentColor)
            
            VStack(alignment: .leading, spacing: 1) {
                Text(l10n.appTitle)
                    .font(.system(size: 13, weight: .semibold))
                Text(l10n.appSubtitle)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Power toggle
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
            .toggleStyle(.switch)
            .tint(accentColor)
            .labelsHidden()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
    
    // MARK: - Status Card
    var statusCard: some View {
        VStack(spacing: 10) {
            if reminderManager.isEnabled {
                // Active status
                HStack {
                    Circle()
                        .fill(Color.green.opacity(0.8))
                        .frame(width: 6, height: 6)
                    Text(l10n.statusActive)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.green)
                    Spacer()
                }
                
                if let nextDate = reminderManager.nextReminderDate {
                    Divider().opacity(0.3)
                    
                    HStack {
                        Text(l10n.nextReminder)
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                        Spacer()
                        TimeRemainingView(targetDate: nextDate)
                    }
                }
            } else {
                // Inactive status
                HStack {
                    Circle()
                        .fill(Color.gray.opacity(0.5))
                        .frame(width: 6, height: 6)
                    Text(l10n.statusInactive)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(NSColor.controlBackgroundColor).opacity(0.5))
        )
    }
    
    // MARK: - Interval Section
    var intervalSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title
            HStack {
                Text(l10n.workInterval)
                    .font(.system(size: 13))
                Spacer()
                Text("\(reminderManager.intervalMinutes) \(l10n.minutes)")
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundColor(accentColor)
            }
            
            // Stepper control
            HStack {
                Button(action: {
                    if reminderManager.intervalMinutes > 5 {
                        reminderManager.intervalMinutes -= 5
                        if reminderManager.isEnabled {
                            appDelegate?.startTimer()
                        }
                    }
                }) {
                    Image(systemName: "minus")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(accentColor)
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(accentColor.opacity(0.1)))
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                Text("\(reminderManager.intervalMinutes)")
                    .font(.system(size: 36, weight: .light, design: .rounded))
                    .foregroundColor(.primary)
                + Text(" \(l10n.minutes)")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button(action: {
                    if reminderManager.intervalMinutes < 180 {
                        reminderManager.intervalMinutes += 5
                        if reminderManager.isEnabled {
                            appDelegate?.startTimer()
                        }
                    }
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(accentColor)
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(accentColor.opacity(0.1)))
                }
                .buttonStyle(.plain)
            }
            .padding(.vertical, 8)
            
            // Quick presets
            HStack(spacing: 8) {
                ForEach([15, 25, 30, 45, 60], id: \.self) { interval in
                    Button(action: {
                        reminderManager.intervalMinutes = interval
                        if reminderManager.isEnabled {
                            appDelegate?.startTimer()
                        }
                    }) {
                        Text("\(interval)")
                            .font(.system(size: 11, weight: .medium))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(reminderManager.intervalMinutes == interval ?
                                          accentColor : Color(NSColor.controlBackgroundColor))
                            )
                            .foregroundColor(reminderManager.intervalMinutes == interval ? .white : .secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(NSColor.controlBackgroundColor).opacity(0.5))
        )
    }
    
    // MARK: - Footer
    var footerView: some View {
        HStack {
            Button(action: {
                appDelegate?.quitApp()
            }) {
                Text(l10n.quit)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            Button(action: onSettingsTapped) {
                HStack(spacing: 4) {
                    Image(systemName: "gearshape")
                    Text(l10n.settings)
                }
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(accentColor)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - Settings Screen
struct SettingsScreenView: View {
    @ObservedObject var reminderManager = ReminderManager.shared
    @ObservedObject var localization = LocalizationManager.shared
    weak var appDelegate: AppDelegate?
    var onBackTapped: () -> Void
    
    private var l10n: L10n { L10n.shared }
    
    // Single accent color for consistency
    private let accentColor = Color(red: 0.4, green: 0.6, blue: 0.8) // Soft blue
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: onBackTapped) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 12, weight: .semibold))
                        Text(l10n.back)
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundColor(accentColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(accentColor.opacity(0.1))
                    )
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                Text(l10n.settings)
                    .font(.system(size: 14, weight: .semibold))
                
                Spacer()
                
                // Invisible placeholder for centering
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 12, weight: .semibold))
                    Text(l10n.back)
                        .font(.system(size: 13, weight: .medium))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .opacity(0)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            
            Divider().opacity(0.5)
            
            // Content
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    
                    // MARK: - Language
                    settingSection {
                        HStack {
                            Text(l10n.language)
                                .font(.system(size: 13))
                            
                            Spacer()
                            
                            Picker("", selection: $localization.currentLanguage) {
                                ForEach(Language.allCases, id: \.self) { lang in
                                    Text(lang.displayName).tag(lang)
                                }
                            }
                            .pickerStyle(.segmented)
                            .frame(width: 160)
                        }
                    }
                    
                    // MARK: - Break Alert
                    settingSection {
                        VStack(spacing: 12) {
                            // Toggle row
                            HStack {
                                Text(l10n.overlay)
                                    .font(.system(size: 13))
                                Spacer()
                                Toggle("", isOn: $reminderManager.enableOverlay)
                                    .toggleStyle(.switch)
                                    .labelsHidden()
                                    .tint(accentColor)
                            }
                            
                            if reminderManager.enableOverlay {
                                Divider().opacity(0.3)
                                
                                // Duration control
                                HStack {
                                    Text(l10n.overlayDuration)
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                    
                                    Spacer()
                                    
                                    // Simple stepper
                                    HStack(spacing: 12) {
                                        Button(action: {
                                            if reminderManager.overlayDurationSeconds > 5 {
                                                reminderManager.overlayDurationSeconds -= 5
                                            }
                                        }) {
                                            Image(systemName: "minus")
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(accentColor)
                                                .frame(width: 28, height: 28)
                                                .background(Circle().fill(accentColor.opacity(0.1)))
                                        }
                                        .buttonStyle(.plain)
                                        
                                        Text("\(reminderManager.overlayDurationSeconds)s")
                                            .font(.system(size: 14, weight: .medium, design: .monospaced))
                                            .frame(width: 50)
                                        
                                        Button(action: {
                                            if reminderManager.overlayDurationSeconds < 300 {
                                                reminderManager.overlayDurationSeconds += 5
                                            }
                                        }) {
                                            Image(systemName: "plus")
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(accentColor)
                                                .frame(width: 28, height: 28)
                                                .background(Circle().fill(accentColor.opacity(0.1)))
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                
                                // Color picker
                                HStack {
                                    Text(l10n.overlayColorLabel)
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                    
                                    Spacer()
                                    
                                    HStack(spacing: 6) {
                                        ForEach(OverlayColor.allCases, id: \.self) { color in
                                            Button(action: {
                                                reminderManager.overlayColor = color
                                            }) {
                                                Circle()
                                                    .fill(color.primaryColor)
                                                    .frame(width: 22, height: 22)
                                                    .overlay(
                                                        Circle()
                                                            .stroke(Color.white, lineWidth: reminderManager.overlayColor == color ? 2 : 0)
                                                    )
                                                    .shadow(color: color.primaryColor.opacity(0.5), 
                                                            radius: reminderManager.overlayColor == color ? 3 : 0)
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                }
                                
                                // Preview
                                Button(action: {
                                    BreakOverlayController.shared.showOverlay()
                                }) {
                                    Text(l10n.previewSound)
                                        .font(.system(size: 12))
                                        .foregroundColor(accentColor)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    
                    // MARK: - Sound
                    settingSection {
                        VStack(spacing: 12) {
                            HStack {
                                Text(l10n.sound)
                                    .font(.system(size: 13))
                                Spacer()
                                Toggle("", isOn: $reminderManager.enableSound)
                                    .toggleStyle(.switch)
                                    .labelsHidden()
                                    .tint(accentColor)
                            }
                            
                            if reminderManager.enableSound {
                                Divider().opacity(0.3)
                                
                                // Sound picker - simple dropdown
                                HStack {
                                    Text(l10n.selectSound)
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                    
                                    Spacer()
                                    
                                    Picker("", selection: $reminderManager.notificationSound) {
                                        ForEach(NotificationSound.allCases, id: \.self) { sound in
                                            Text(sound.displayName).tag(sound)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .onChange(of: reminderManager.notificationSound) { newSound in
                                        reminderManager.playSound(newSound)
                                    }
                                }
                            }
                        }
                    }
                    
                    // MARK: - Screen Saver
                    settingSection {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(l10n.screenSaverTitle)
                                    .font(.system(size: 13))
                                Text(l10n.screenSaverSubtitle)
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Toggle("", isOn: $reminderManager.enableScreenSaver)
                                .toggleStyle(.switch)
                                .labelsHidden()
                                .tint(accentColor)
                        }
                    }
                    
                    // MARK: - Test Button
                    Button(action: {
                        appDelegate?.sendNotification()
                        if reminderManager.enableOverlay {
                            BreakOverlayController.shared.showOverlay()
                        }
                        if reminderManager.enableScreenSaver {
                            appDelegate?.activateScreenSaver()
                        }
                    }) {
                        Text(l10n.testNotification)
                            .font(.system(size: 13, weight: .medium))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                    
                    // Version
                    Text("v1.0.0")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary.opacity(0.6))
                        .padding(.top, 4)
                }
                .padding(16)
            }
        }
        .frame(width: 320, height: 420)
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    // MARK: - Setting Section
    @ViewBuilder
    private func settingSection<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(NSColor.controlBackgroundColor).opacity(0.5))
            )
    }
}

// MARK: - Settings Card (unused, kept for compatibility)
struct SettingsCard<Content: View>: View {
    @ViewBuilder var content: Content
    
    var body: some View {
        content
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(NSColor.controlBackgroundColor))
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
