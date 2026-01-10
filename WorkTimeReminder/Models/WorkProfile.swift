import Foundation

// MARK: - Work Profile
struct WorkProfile: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var nameVI: String
    var intervalMinutes: Int
    var breakDurationMinutes: Int
    var icon: String
    var isBuiltIn: Bool
    
    var displayName: String {
        LocalizationManager.shared.currentLanguage == .vietnamese ? nameVI : name
    }
    
    init(id: UUID = UUID(), name: String, nameVI: String, intervalMinutes: Int, breakDurationMinutes: Int, icon: String, isBuiltIn: Bool = false) {
        self.id = id
        self.name = name
        self.nameVI = nameVI
        self.intervalMinutes = intervalMinutes
        self.breakDurationMinutes = breakDurationMinutes
        self.icon = icon
        self.isBuiltIn = isBuiltIn
    }
    
    static func == (lhs: WorkProfile, rhs: WorkProfile) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Profile Manager
class ProfileManager: ObservableObject {
    static let shared = ProfileManager()
    
    // Built-in profiles
    static let builtInProfiles: [WorkProfile] = [
        WorkProfile(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
            name: "Pomodoro",
            nameVI: "Pomodoro",
            intervalMinutes: 25,
            breakDurationMinutes: 5,
            icon: "timer",
            isBuiltIn: true
        ),
        WorkProfile(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
            name: "Deep Work",
            nameVI: "Tập trung sâu",
            intervalMinutes: 50,
            breakDurationMinutes: 10,
            icon: "brain.head.profile",
            isBuiltIn: true
        ),
        WorkProfile(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,
            name: "Light Work",
            nameVI: "Làm việc nhẹ",
            intervalMinutes: 15,
            breakDurationMinutes: 3,
            icon: "leaf",
            isBuiltIn: true
        ),
        WorkProfile(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000004")!,
            name: "Long Session",
            nameVI: "Phiên dài",
            intervalMinutes: 90,
            breakDurationMinutes: 15,
            icon: "hourglass",
            isBuiltIn: true
        )
    ]
    
    @Published var profiles: [WorkProfile] = []
    @Published var currentProfileId: UUID? {
        didSet {
            if let id = currentProfileId {
                UserDefaults.standard.set(id.uuidString, forKey: "currentProfileId")
            } else {
                UserDefaults.standard.removeObject(forKey: "currentProfileId")
            }
        }
    }
    
    var currentProfile: WorkProfile? {
        guard let id = currentProfileId else { return nil }
        return profiles.first { $0.id == id }
    }
    
    private init() {
        loadProfiles()
        loadCurrentProfile()
    }
    
    // MARK: - Profile Management
    
    func selectProfile(_ profile: WorkProfile) {
        currentProfileId = profile.id
        
        // Apply profile settings
        let reminderManager = ReminderManager.shared
        reminderManager.intervalMinutes = profile.intervalMinutes
        reminderManager.breakDurationMinutes = profile.breakDurationMinutes
        
        NotificationCenter.default.post(name: .profileChanged, object: profile)
    }
    
    func clearProfile() {
        currentProfileId = nil
        NotificationCenter.default.post(name: .profileChanged, object: nil)
    }
    
    func addCustomProfile(_ profile: WorkProfile) {
        var newProfile = profile
        newProfile.isBuiltIn = false
        profiles.append(newProfile)
        saveCustomProfiles()
    }
    
    func deleteProfile(_ profile: WorkProfile) {
        guard !profile.isBuiltIn else { return }
        profiles.removeAll { $0.id == profile.id }
        if currentProfileId == profile.id {
            currentProfileId = nil
        }
        saveCustomProfiles()
    }
    
    // MARK: - Persistence
    
    private func loadProfiles() {
        profiles = Self.builtInProfiles
        
        // Load custom profiles
        if let data = UserDefaults.standard.data(forKey: "customProfiles"),
           let custom = try? JSONDecoder().decode([WorkProfile].self, from: data) {
            profiles.append(contentsOf: custom)
        }
    }
    
    private func loadCurrentProfile() {
        if let idString = UserDefaults.standard.string(forKey: "currentProfileId"),
           let id = UUID(uuidString: idString) {
            currentProfileId = id
        }
    }
    
    private func saveCustomProfiles() {
        let custom = profiles.filter { !$0.isBuiltIn }
        if let data = try? JSONEncoder().encode(custom) {
            UserDefaults.standard.set(data, forKey: "customProfiles")
        }
    }
}

// MARK: - Notifications
extension Notification.Name {
    static let profileChanged = Notification.Name("profileChanged")
}

