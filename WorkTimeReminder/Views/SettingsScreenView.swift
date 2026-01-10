import SwiftUI

// MARK: - Settings Screen
struct SettingsScreenView: View {
    @ObservedObject var reminderManager = ReminderManager.shared
    @ObservedObject var localization = LocalizationManager.shared
    @ObservedObject var schedule = WorkSchedule.shared
    weak var appDelegate: AppDelegate?
    var onBackTapped: () -> Void
    var onScheduleTapped: (() -> Void)?
    
    private var l10n: L10n { L10n.shared }
    private let accentColor = Color(red: 0.4, green: 0.6, blue: 0.8)
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            Divider().opacity(0.5)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // Basic settings
                    languageSection
                    scheduleSection
                    
                    // Notification settings (grouped)
                    notificationSettingsSection
                    
                    // Power & behavior settings (grouped)
                    behaviorSettingsSection
                    
                    // Info section
                    shortcutsInfo
                    
                    testButton
                    versionLabel
                }
                .padding(16)
            }
        }
        .frame(width: 320, height: 420)
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    // MARK: - Header
    private var headerView: some View {
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
    }
    
    // MARK: - Language Section
    private var languageSection: some View {
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
    }
    
    // MARK: - Schedule Section
    private var scheduleSection: some View {
        Button(action: { onScheduleTapped?() }) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(l10n.scheduleTitle)
                        .font(.system(size: 13))
                        .foregroundColor(.primary)
                    
                    if schedule.isScheduleEnabled {
                        Text("\(schedule.startTimeString) - \(schedule.endTimeString)")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    } else {
                        Text(l10n.scheduleSubtitle)
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                if schedule.isScheduleEnabled {
                    Text("ON")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(Color.green))
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(NSColor.controlBackgroundColor).opacity(0.5))
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Notification Settings (Grouped)
    private var notificationSettingsSection: some View {
        settingSection {
            VStack(spacing: 0) {
                // Section header
                HStack {
                    Image(systemName: "bell.badge")
                        .foregroundColor(accentColor)
                    Text(LocalizationManager.shared.currentLanguage == .vietnamese ? "Thông báo" : "Notifications")
                        .font(.system(size: 13, weight: .medium))
                    Spacer()
                }
                .padding(.bottom, 12)
                
                Divider().opacity(0.3)
                
                // Full screen overlay
                VStack(spacing: 10) {
                    HStack {
                        Text(l10n.overlay)
                            .font(.system(size: 12))
                        Spacer()
                        Toggle("", isOn: $reminderManager.enableOverlay)
                            .toggleStyle(.switch)
                            .labelsHidden()
                            .tint(accentColor)
                            .scaleEffect(0.85)
                    }
                    .padding(.top, 10)
                    
                    if reminderManager.enableOverlay {
                        // Overlay duration
                        HStack {
                            Text(l10n.overlayDuration)
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                            Spacer()
                            compactStepper(
                                value: $reminderManager.overlayDurationSeconds,
                                range: 5...300,
                                step: 5,
                                suffix: "s"
                            )
                        }
                        
                        // Snooze duration
                        HStack {
                            Text(l10n.snoozeDuration)
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                            Spacer()
                            compactStepper(
                                value: $reminderManager.snoozeDurationMinutes,
                                range: 1...30,
                                step: 1,
                                suffix: l10n.minutes
                            )
                        }
                        
                        // Color picker
                        HStack {
                            Text(l10n.overlayColorLabel)
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                            Spacer()
                            HStack(spacing: 5) {
                                ForEach(OverlayColor.allCases, id: \.self) { color in
                                    Button(action: { reminderManager.overlayColor = color }) {
                                        Circle()
                                            .fill(color.primaryColor)
                                            .frame(width: 20, height: 20)
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.white, lineWidth: reminderManager.overlayColor == color ? 2 : 0)
                                            )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                }
                
                Divider().opacity(0.3).padding(.vertical, 8)
                
                // Sound
                HStack {
                    Text(l10n.sound)
                        .font(.system(size: 12))
                    Spacer()
                    
                    if reminderManager.enableSound {
                        Picker("", selection: $reminderManager.notificationSound) {
                            ForEach(NotificationSound.allCases, id: \.self) { sound in
                                Text(sound.displayName).tag(sound)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(width: 100)
                        .onChange(of: reminderManager.notificationSound) { newSound in
                            reminderManager.playSound(newSound)
                        }
                    }
                    
                    Toggle("", isOn: $reminderManager.enableSound)
                        .toggleStyle(.switch)
                        .labelsHidden()
                        .tint(accentColor)
                        .scaleEffect(0.85)
                }
                
                Divider().opacity(0.3).padding(.vertical, 8)
                
                // Screen saver
                HStack {
                    Text(l10n.screenSaverTitle)
                        .font(.system(size: 12))
                    Spacer()
                    Toggle("", isOn: $reminderManager.enableScreenSaver)
                        .toggleStyle(.switch)
                        .labelsHidden()
                        .tint(accentColor)
                        .scaleEffect(0.85)
                }
            }
        }
    }
    
    // MARK: - Behavior Settings (Grouped)
    private var behaviorSettingsSection: some View {
        settingSection {
            VStack(spacing: 0) {
                // Section header
                HStack {
                    Image(systemName: "gearshape.2")
                        .foregroundColor(accentColor)
                    Text(LocalizationManager.shared.currentLanguage == .vietnamese ? "Hành vi" : "Behavior")
                        .font(.system(size: 13, weight: .medium))
                    Spacer()
                }
                .padding(.bottom, 12)
                
                Divider().opacity(0.3)
                
                // Keep awake
                VStack(spacing: 8) {
                    HStack {
                        VStack(alignment: .leading, spacing: 1) {
                            Text(l10n.keepAwakeTitle)
                                .font(.system(size: 12))
                            Text(l10n.keepAwakeSubtitle)
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Toggle("", isOn: $reminderManager.keepAwake)
                            .toggleStyle(.switch)
                            .labelsHidden()
                            .tint(accentColor)
                            .scaleEffect(0.85)
                    }
                    .padding(.top, 10)
                }
                
                Divider().opacity(0.3).padding(.vertical, 8)
                
                // Auto reset
                VStack(spacing: 8) {
                    HStack {
                        VStack(alignment: .leading, spacing: 1) {
                            Text(l10n.autoResetTitle)
                                .font(.system(size: 12))
                            Text(l10n.autoResetSubtitle)
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Toggle("", isOn: $reminderManager.autoResetOnScreenLock)
                            .toggleStyle(.switch)
                            .labelsHidden()
                            .tint(accentColor)
                            .scaleEffect(0.85)
                    }
                    
                    if reminderManager.autoResetOnScreenLock {
                        HStack {
                            Text(l10n.breakDuration)
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                            Spacer()
                            compactStepper(
                                value: $reminderManager.breakDurationMinutes,
                                range: 1...30,
                                step: 1,
                                suffix: l10n.minutes
                            )
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Compact Stepper Helper
    private func compactStepper(value: Binding<Int>, range: ClosedRange<Int>, step: Int, suffix: String) -> some View {
        HStack(spacing: 8) {
            Button(action: {
                if value.wrappedValue > range.lowerBound {
                    value.wrappedValue -= step
                }
            }) {
                Image(systemName: "minus")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(accentColor)
                    .frame(width: 22, height: 22)
                    .background(Circle().fill(accentColor.opacity(0.1)))
            }
            .buttonStyle(.plain)
            
            Text("\(value.wrappedValue)\(suffix)")
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .frame(width: 50)
            
            Button(action: {
                if value.wrappedValue < range.upperBound {
                    value.wrappedValue += step
                }
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(accentColor)
                    .frame(width: 22, height: 22)
                    .background(Circle().fill(accentColor.opacity(0.1)))
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Test Button
    private var testButton: some View {
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
    }
    
    // MARK: - Shortcuts Info
    private var shortcutsInfo: some View {
        settingSection {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "keyboard")
                        .foregroundColor(accentColor)
                    Text(l10n.shortcuts)
                        .font(.system(size: 13, weight: .medium))
                    Spacer()
                }
                
                VStack(spacing: 6) {
                    shortcutRow(keys: "⌘⇧P", action: l10n.pauseResume)
                    shortcutRow(keys: "⌘⇧S", action: l10n.skipReminder)
                    shortcutRow(keys: "⌘⇧R", action: l10n.resetTimer)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    private func shortcutRow(keys: String, action: String) -> some View {
        HStack {
            Text(keys)
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundColor(accentColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(accentColor.opacity(0.1))
                )
                .frame(width: 60)
            
            Text(action)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
    
    // MARK: - Version Label
    private var versionLabel: some View {
        Text("v1.1.0")
            .font(.system(size: 10))
            .foregroundColor(.secondary.opacity(0.6))
            .padding(.top, 4)
    }
    
    // MARK: - Helper Views
    
    @ViewBuilder
    private func settingSection<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(NSColor.controlBackgroundColor).opacity(0.5))
            )
    }
    
    private func stepperButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(accentColor)
                .frame(width: 28, height: 28)
                .background(Circle().fill(accentColor.opacity(0.1)))
        }
        .buttonStyle(.plain)
    }
}

