import SwiftUI

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
                        hoursSection
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
    
    // MARK: - Hours Section
    private var hoursSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(l10n.workHours)
                .font(.system(size: 13, weight: .medium))
            
            HStack(spacing: 12) {
                // Start time
                VStack(spacing: 4) {
                    Text("Start")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 4) {
                        Picker("", selection: $schedule.startHour) {
                            ForEach(0..<24, id: \.self) { hour in
                                Text(String(format: "%02d", hour)).tag(hour)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(width: 60)
                        
                        Text(":")
                        
                        Picker("", selection: $schedule.startMinute) {
                            ForEach([0, 15, 30, 45], id: \.self) { min in
                                Text(String(format: "%02d", min)).tag(min)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(width: 60)
                    }
                }
                
                Text(l10n.to)
                    .foregroundColor(.secondary)
                
                // End time
                VStack(spacing: 4) {
                    Text("End")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 4) {
                        Picker("", selection: $schedule.endHour) {
                            ForEach(0..<24, id: \.self) { hour in
                                Text(String(format: "%02d", hour)).tag(hour)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(width: 60)
                        
                        Text(":")
                        
                        Picker("", selection: $schedule.endMinute) {
                            ForEach([0, 15, 30, 45], id: \.self) { min in
                                Text(String(format: "%02d", min)).tag(min)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(width: 60)
                    }
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(NSColor.controlBackgroundColor).opacity(0.5))
        )
    }
    
    // MARK: - Days Section
    private var daysSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(l10n.workDays)
                .font(.system(size: 13, weight: .medium))
            
            HStack(spacing: 6) {
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
        
        return Button(action: {
            if isSelected {
                schedule.workDays.remove(day)
            } else {
                schedule.workDays.insert(day)
            }
        }) {
            Text(schedule.dayName(for: day))
                .font(.system(size: 11, weight: .medium))
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(isSelected ? accentColor : Color(NSColor.controlBackgroundColor))
                )
                .foregroundColor(isSelected ? .white : .secondary)
        }
        .buttonStyle(.plain)
    }
}

