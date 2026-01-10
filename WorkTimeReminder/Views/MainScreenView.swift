import SwiftUI

// MARK: - Main Screen
struct MainScreenView: View {
    @ObservedObject var reminderManager = ReminderManager.shared
    @ObservedObject var localization = LocalizationManager.shared
    @ObservedObject var profileManager = ProfileManager.shared
    @ObservedObject var stats = StatisticsManager.shared
    weak var appDelegate: AppDelegate?
    var onSettingsTapped: () -> Void
    var onStatsTapped: (() -> Void)?
    var onProfilesTapped: (() -> Void)?
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
                    
                    // Show either profile selector OR manual interval (not both)
                    if profileManager.currentProfile != nil {
                        activeProfileCard
                    } else {
                        intervalSection
                    }
                    
                    quickActionsSection
                    quickStatsSection
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
    
    // MARK: - Active Profile Card (when profile is selected)
    private var activeProfileCard: some View {
        VStack(spacing: 12) {
            if let profile = profileManager.currentProfile {
                // Current profile display
                HStack(spacing: 12) {
                    Image(systemName: profile.icon)
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(profileColor(for: profile))
                        )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(profile.displayName)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 12) {
                            Label("\(profile.intervalMinutes)\(l10n.minutes)", systemImage: "clock")
                            Label("\(profile.breakDurationMinutes)\(l10n.minutes)", systemImage: "cup.and.saucer")
                        }
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                
                Divider().opacity(0.3)
                
                // Quick actions row
                HStack(spacing: 12) {
                    // Change profile
                    Button(action: { onProfilesTapped?() }) {
                        Label(l10n.selectProfile, systemImage: "arrow.triangle.2.circlepath")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(accentColor)
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                    
                    // Switch to custom
                    Button(action: {
                        profileManager.clearProfile()
                    }) {
                        Text(l10n.customProfile)
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(NSColor.controlBackgroundColor).opacity(0.5))
        )
    }
    
    private func profileColor(for profile: WorkProfile) -> Color {
        switch profile.icon {
        case "timer": return .red
        case "brain.head.profile": return .purple
        case "leaf": return .green
        case "hourglass": return .orange
        default: return accentColor
        }
    }
    
    // MARK: - Quick Actions Section
    private var quickActionsSection: some View {
        HStack(spacing: 10) {
            // Profiles button (only show when in custom mode)
            if profileManager.currentProfile == nil {
                quickActionButton(
                    icon: "list.bullet.rectangle",
                    title: l10n.profiles,
                    color: .purple
                ) {
                    onProfilesTapped?()
                }
            }
            
            // Quick profile buttons
            ForEach(ProfileManager.builtInProfiles.prefix(profileManager.currentProfile == nil ? 3 : 4), id: \.id) { profile in
                quickProfileButton(profile)
            }
        }
    }
    
    private func quickActionButton(icon: String, title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)
                Text(title)
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(NSColor.controlBackgroundColor).opacity(0.5))
            )
        }
        .buttonStyle(.plain)
    }
    
    private func quickProfileButton(_ profile: WorkProfile) -> some View {
        let isActive = profileManager.currentProfileId == profile.id
        let color = profileColor(for: profile)
        
        return Button(action: {
            if isActive {
                profileManager.clearProfile()
            } else {
                profileManager.selectProfile(profile)
                appDelegate?.startTimer()
            }
        }) {
            VStack(spacing: 4) {
                Image(systemName: profile.icon)
                    .font(.system(size: 16))
                    .foregroundColor(isActive ? .white : color)
                Text("\(profile.intervalMinutes)m")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(isActive ? .white : .secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isActive ? color : Color(NSColor.controlBackgroundColor).opacity(0.5))
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Quick Stats Section
    private var quickStatsSection: some View {
        Button(action: { onStatsTapped?() }) {
            HStack(spacing: 16) {
                VStack(spacing: 2) {
                    Text("\(stats.todayCompletedSessions)")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.green)
                    Text(l10n.sessions)
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                }
                
                Divider()
                    .frame(height: 30)
                
                VStack(spacing: 2) {
                    Text(formatMinutes(stats.todayWorkMinutes))
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(accentColor)
                    Text(l10n.todayStats)
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(NSColor.controlBackgroundColor).opacity(0.5))
            )
        }
        .buttonStyle(.plain)
    }
    
    private func formatMinutes(_ minutes: Int) -> String {
        if minutes < 60 {
            return "\(minutes)m"
        } else {
            let h = minutes / 60
            let m = minutes % 60
            return m > 0 ? "\(h)h\(m)m" : "\(h)h"
        }
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

