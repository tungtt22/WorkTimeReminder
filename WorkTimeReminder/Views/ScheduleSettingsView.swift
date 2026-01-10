import SwiftUI

// MARK: - Schedule Preset
struct SchedulePreset: Identifiable {
    let id = UUID()
    let name: String
    let nameVI: String
    let startHour: Int
    let endHour: Int
    let icon: String
    
    var displayName: String {
        LocalizationManager.shared.currentLanguage == .vietnamese ? nameVI : name
    }
    
    var timeRange: String {
        String(format: "%02d:00 - %02d:00", startHour, endHour)
    }
    
    static let presets: [SchedulePreset] = [
        SchedulePreset(name: "Office Hours", nameVI: "Giờ văn phòng", startHour: 9, endHour: 17, icon: "building.2"),
        SchedulePreset(name: "Early Bird", nameVI: "Làm sớm", startHour: 7, endHour: 15, icon: "sunrise"),
        SchedulePreset(name: "Extended", nameVI: "Giờ mở rộng", startHour: 8, endHour: 18, icon: "clock"),
        SchedulePreset(name: "Night Owl", nameVI: "Làm khuya", startHour: 14, endHour: 22, icon: "moon.stars"),
    ]
}

// MARK: - Schedule Settings View
struct ScheduleSettingsView: View {
    @ObservedObject var schedule = WorkSchedule.shared
    @ObservedObject var localization = LocalizationManager.shared
    var onBack: () -> Void
    
    private var l10n: L10n { L10n.shared }
    private let accentColor = Color(red: 0.4, green: 0.6, blue: 0.8)
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            Divider().opacity(0.5)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    enableSection
                    
                    if schedule.isScheduleEnabled {
                        presetsSection
                        currentScheduleDisplay
                        daysSection
                    }
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
            Button(action: onBack) {
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
            
            Text(l10n.schedule)
                .font(.system(size: 14, weight: .semibold))
            
            Spacer()
            
            // Invisible placeholder
            HStack(spacing: 4) {
                Image(systemName: "chevron.left")
                Text(l10n.back)
            }
            .font(.system(size: 12))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .opacity(0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }
    
    // MARK: - Enable Section
    private var enableSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(l10n.scheduleTitle)
                    .font(.system(size: 13))
                Text(l10n.scheduleSubtitle)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $schedule.isScheduleEnabled)
                .toggleStyle(.switch)
                .labelsHidden()
                .tint(accentColor)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(NSColor.controlBackgroundColor).opacity(0.5))
        )
    }
    
    // MARK: - Presets Section
    private var presetsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(LocalizationManager.shared.currentLanguage == .vietnamese ? "Chọn nhanh" : "Quick Select")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(SchedulePreset.presets) { preset in
                    presetButton(preset)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(NSColor.controlBackgroundColor).opacity(0.5))
        )
    }
    
    private func presetButton(_ preset: SchedulePreset) -> some View {
        let isSelected = schedule.startHour == preset.startHour && schedule.endHour == preset.endHour
        
        return Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                schedule.startHour = preset.startHour
                schedule.startMinute = 0
                schedule.endHour = preset.endHour
                schedule.endMinute = 0
            }
        }) {
            HStack(spacing: 8) {
                Image(systemName: preset.icon)
                    .font(.system(size: 14))
                    .foregroundColor(isSelected ? .white : accentColor)
                
                VStack(alignment: .leading, spacing: 1) {
                    Text(preset.displayName)
                        .font(.system(size: 11, weight: .medium))
                    Text(preset.timeRange)
                        .font(.system(size: 9, design: .monospaced))
                        .opacity(0.8)
                }
                
                Spacer()
            }
            .padding(10)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? accentColor : Color(NSColor.controlBackgroundColor))
            )
            .foregroundColor(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Current Schedule Display
    private var currentScheduleDisplay: some View {
        VStack(spacing: 10) {
            HStack {
                Text(l10n.workHours)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            HStack(spacing: 0) {
                // Start time
                timeAdjuster(
                    hour: $schedule.startHour,
                    minute: $schedule.startMinute,
                    label: "Start"
                )
                
                // Arrow
                Image(systemName: "arrow.right")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                
                // End time
                timeAdjuster(
                    hour: $schedule.endHour,
                    minute: $schedule.endMinute,
                    label: "End"
                )
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(NSColor.controlBackgroundColor).opacity(0.5))
        )
    }
    
    private func timeAdjuster(hour: Binding<Int>, minute: Binding<Int>, label: String) -> some View {
        VStack(spacing: 6) {
            // Hour/Minute display
            HStack(spacing: 2) {
                Text(String(format: "%02d", hour.wrappedValue))
                    .font(.system(size: 24, weight: .medium, design: .monospaced))
                Text(":")
                    .font(.system(size: 24, weight: .light))
                    .foregroundColor(.secondary)
                Text(String(format: "%02d", minute.wrappedValue))
                    .font(.system(size: 24, weight: .medium, design: .monospaced))
            }
            .foregroundColor(accentColor)
            
            // Stepper buttons
            HStack(spacing: 16) {
                Button(action: {
                    if hour.wrappedValue > 0 {
                        hour.wrappedValue -= 1
                    }
                }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(accentColor.opacity(0.7))
                }
                .buttonStyle(.plain)
                
                Button(action: {
                    if hour.wrappedValue < 23 {
                        hour.wrappedValue += 1
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(accentColor.opacity(0.7))
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Days Section
    private var daysSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(l10n.workDays)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                // Quick select weekdays
                Button(action: {
                    schedule.workDays = Set([2, 3, 4, 5, 6]) // Mon-Fri
                }) {
                    Text(LocalizationManager.shared.currentLanguage == .vietnamese ? "T2-T6" : "M-F")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(accentColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(accentColor.opacity(0.1))
                        )
                }
                .buttonStyle(.plain)
            }
            
            HStack(spacing: 8) {
                ForEach([2, 3, 4, 5, 6, 7, 1], id: \.self) { day in
                    dayButton(day: day)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(NSColor.controlBackgroundColor).opacity(0.5))
        )
    }
    
    private func dayButton(day: Int) -> some View {
        let isSelected = schedule.workDays.contains(day)
        let isWeekend = day == 1 || day == 7
        
        return Button(action: {
            if isSelected {
                schedule.workDays.remove(day)
            } else {
                schedule.workDays.insert(day)
            }
        }) {
            Text(schedule.dayName(for: day))
                .font(.system(size: 10, weight: .medium))
                .frame(width: 34, height: 34)
                .background(
                    Circle()
                        .fill(isSelected ? accentColor : Color(NSColor.controlBackgroundColor))
                )
                .foregroundColor(isSelected ? .white : (isWeekend ? .orange : .secondary))
        }
        .buttonStyle(.plain)
    }
}

