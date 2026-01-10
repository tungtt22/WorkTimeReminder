import SwiftUI

// MARK: - Statistics View
struct StatisticsView: View {
    @ObservedObject var stats = StatisticsManager.shared
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
                    todaySection
                    weekSection
                    allTimeSection
                    resetButton
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
            
            Text(l10n.statistics)
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
    
    // MARK: - Today Section
    private var todaySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "sun.max.fill")
                    .foregroundColor(.orange)
                Text(l10n.todayStats)
                    .font(.system(size: 13, weight: .semibold))
            }
            
            HStack(spacing: 12) {
                statCard(
                    value: "\(stats.todayCompletedSessions)",
                    label: l10n.sessions,
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                
                statCard(
                    value: formatDuration(stats.todayWorkMinutes),
                    label: l10n.workTime,
                    icon: "clock.fill",
                    color: accentColor
                )
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(NSColor.controlBackgroundColor).opacity(0.5))
        )
    }
    
    // MARK: - Week Section
    private var weekSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.purple)
                Text(l10n.weekStats)
                    .font(.system(size: 13, weight: .semibold))
            }
            
            HStack(spacing: 12) {
                statCard(
                    value: "\(stats.thisWeekCompletedSessions)",
                    label: l10n.sessions,
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                
                statCard(
                    value: formatDuration(stats.thisWeekWorkMinutes),
                    label: l10n.workTime,
                    icon: "clock.fill",
                    color: accentColor
                )
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(NSColor.controlBackgroundColor).opacity(0.5))
        )
    }
    
    // MARK: - All Time Section
    private var allTimeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(.teal)
                Text("All Time")
                    .font(.system(size: 13, weight: .semibold))
            }
            
            HStack(spacing: 12) {
                statCard(
                    value: "\(stats.totalBreaksTaken)",
                    label: l10n.breaksCompleted,
                    icon: "cup.and.saucer.fill",
                    color: .orange
                )
                
                statCard(
                    value: "\(stats.longestStreak)",
                    label: l10n.longestStreak,
                    icon: "flame.fill",
                    color: .red
                )
            }
            
            HStack(spacing: 12) {
                statCard(
                    value: "\(stats.averageSessionMinutes) \(l10n.minutes)",
                    label: l10n.avgSession,
                    icon: "timer",
                    color: .indigo
                )
                
                statCard(
                    value: "\(stats.sessions.count)",
                    label: "Total Sessions",
                    icon: "list.bullet",
                    color: .gray
                )
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(NSColor.controlBackgroundColor).opacity(0.5))
        )
    }
    
    // MARK: - Reset Button
    private var resetButton: some View {
        Button(action: {
            stats.resetStatistics()
        }) {
            HStack {
                Image(systemName: "trash")
                Text(l10n.resetStats)
            }
            .font(.system(size: 12))
            .foregroundColor(.red.opacity(0.8))
        }
        .buttonStyle(.plain)
        .padding(.top, 8)
    }
    
    // MARK: - Helper Views
    private func statCard(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 10))
                    .foregroundColor(color)
                Text(label)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(color.opacity(0.08))
        )
    }
    
    // MARK: - Helpers
    private func formatDuration(_ minutes: Int) -> String {
        if minutes < 60 {
            return "\(minutes) \(l10n.minutes)"
        } else {
            let hours = minutes / 60
            let mins = minutes % 60
            if mins == 0 {
                return "\(hours)\(l10n.hours)"
            }
            return "\(hours)\(l10n.hours) \(mins)\(l10n.minutes)"
        }
    }
}

