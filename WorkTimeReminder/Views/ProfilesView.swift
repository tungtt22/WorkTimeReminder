import SwiftUI

// MARK: - Profiles View
struct ProfilesView: View {
    @ObservedObject var profileManager = ProfileManager.shared
    @ObservedObject var localization = LocalizationManager.shared
    weak var appDelegate: AppDelegate?
    var onBack: () -> Void
    
    private var l10n: L10n { L10n.shared }
    private let accentColor = Color(red: 0.4, green: 0.6, blue: 0.8)
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            Divider().opacity(0.5)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    // Custom mode option
                    customOption
                    
                    // Profile list
                    ForEach(profileManager.profiles) { profile in
                        profileRow(profile)
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
            
            Text(l10n.profiles)
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
    
    // MARK: - Custom Option
    private var customOption: some View {
        let isSelected = profileManager.currentProfileId == nil
        
        return Button(action: {
            profileManager.clearProfile()
        }) {
            HStack(spacing: 12) {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 18))
                    .foregroundColor(isSelected ? .white : accentColor)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(isSelected ? accentColor : accentColor.opacity(0.15))
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(l10n.customProfile)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Text(LocalizationManager.shared.currentLanguage == .vietnamese ?
                         "Tự điều chỉnh thời gian" : "Manually adjust timing")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(accentColor)
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(NSColor.controlBackgroundColor).opacity(0.5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(isSelected ? accentColor : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Profile Row
    private func profileRow(_ profile: WorkProfile) -> some View {
        let isSelected = profileManager.currentProfileId == profile.id
        
        return Button(action: {
            profileManager.selectProfile(profile)
            appDelegate?.startTimer()
            // Auto navigate back after selection
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                onBack()
            }
        }) {
            HStack(spacing: 12) {
                Image(systemName: profile.icon)
                    .font(.system(size: 18))
                    .foregroundColor(isSelected ? .white : profileColor(for: profile))
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(isSelected ? profileColor(for: profile) : profileColor(for: profile).opacity(0.15))
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(profile.displayName)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Text("\(profile.intervalMinutes) \(l10n.minutes) → \(profile.breakDurationMinutes) \(l10n.minutes) break")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(profileColor(for: profile))
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(NSColor.controlBackgroundColor).opacity(0.5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(isSelected ? profileColor(for: profile) : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(.plain)
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
}

