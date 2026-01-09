import SwiftUI

// MARK: - Main Screen
struct MainScreenView: View {
    @ObservedObject var reminderManager = ReminderManager.shared
    @ObservedObject var localization = LocalizationManager.shared
    weak var appDelegate: AppDelegate?
    var onSettingsTapped: () -> Void
    @State private var customInterval: String = ""
    
    private var l10n: L10n { L10n.shared }
    private let accentColor = Color(red: 0.4, green: 0.6, blue: 0.8)
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            Divider().opacity(0.5)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    statusCard
                    intervalSection
                }
                .padding(16)
            }
            
            Divider().opacity(0.5)
            footerView
        }
        .frame(width: 320, height: 420)
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack(spacing: 12) {
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
    private var statusCard: some View {
        VStack(spacing: 10) {
            if reminderManager.isEnabled {
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
    private var intervalSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(l10n.workInterval)
                    .font(.system(size: 13))
                Spacer()
                Text("\(reminderManager.intervalMinutes) \(l10n.minutes)")
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundColor(accentColor)
            }
            
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
    private var footerView: some View {
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

