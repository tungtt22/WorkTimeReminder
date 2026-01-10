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
                    languageSection
                    scheduleSection
                    overlaySection
                    snoozeSection
                    soundSection
                    screenSaverSection
                    keepAwakeSection
                    autoResetSection
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
    
    // MARK: - Snooze Section
    private var snoozeSection: some View {
        settingSection {
            HStack {
                Text(l10n.snoozeDuration)
                    .font(.system(size: 13))
                
                Spacer()
                
                HStack(spacing: 12) {
                    stepperButton(systemName: "minus") {
                        if reminderManager.snoozeDurationMinutes > 1 {
                            reminderManager.snoozeDurationMinutes -= 1
                        }
                    }
                    
                    Text("\(reminderManager.snoozeDurationMinutes) \(l10n.minutes)")
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .frame(width: 60)
                    
                    stepperButton(systemName: "plus") {
                        if reminderManager.snoozeDurationMinutes < 30 {
                            reminderManager.snoozeDurationMinutes += 1
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Overlay Section
    private var overlaySection: some View {
        settingSection {
            VStack(spacing: 12) {
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
                        
                        HStack(spacing: 12) {
                            stepperButton(systemName: "minus") {
                                if reminderManager.overlayDurationSeconds > 5 {
                                    reminderManager.overlayDurationSeconds -= 5
                                }
                            }
                            
                            Text("\(reminderManager.overlayDurationSeconds)s")
                                .font(.system(size: 14, weight: .medium, design: .monospaced))
                                .frame(width: 50)
                            
                            stepperButton(systemName: "plus") {
                                if reminderManager.overlayDurationSeconds < 300 {
                                    reminderManager.overlayDurationSeconds += 5
                                }
                            }
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
    }
    
    // MARK: - Sound Section
    private var soundSection: some View {
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
    }
    
    // MARK: - Screen Saver Section
    private var screenSaverSection: some View {
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
    }
    
    // MARK: - Keep Awake Section
    private var keepAwakeSection: some View {
        settingSection {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(l10n.keepAwakeTitle)
                        .font(.system(size: 13))
                    Text(l10n.keepAwakeSubtitle)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Toggle("", isOn: $reminderManager.keepAwake)
                    .toggleStyle(.switch)
                    .labelsHidden()
                    .tint(accentColor)
            }
        }
    }
    
    // MARK: - Auto Reset Section
    private var autoResetSection: some View {
        settingSection {
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(l10n.autoResetTitle)
                            .font(.system(size: 13))
                        Text(l10n.autoResetSubtitle)
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Toggle("", isOn: $reminderManager.autoResetOnScreenLock)
                        .toggleStyle(.switch)
                        .labelsHidden()
                        .tint(accentColor)
                }
                
                if reminderManager.autoResetOnScreenLock {
                    Divider().opacity(0.3)
                    
                    HStack {
                        Text(l10n.breakDuration)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        HStack(spacing: 12) {
                            stepperButton(systemName: "minus") {
                                if reminderManager.breakDurationMinutes > 1 {
                                    reminderManager.breakDurationMinutes -= 1
                                }
                            }
                            
                            Text("\(reminderManager.breakDurationMinutes) \(l10n.minutes)")
                                .font(.system(size: 14, weight: .medium, design: .monospaced))
                                .frame(width: 60)
                            
                            stepperButton(systemName: "plus") {
                                if reminderManager.breakDurationMinutes < 30 {
                                    reminderManager.breakDurationMinutes += 1
                                }
                            }
                        }
                    }
                }
            }
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

