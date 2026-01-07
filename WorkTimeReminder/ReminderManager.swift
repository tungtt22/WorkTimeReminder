import Foundation
import Combine

class ReminderManager: ObservableObject {
    static let shared = ReminderManager()
    
    @Published var intervalMinutes: Int {
        didSet {
            UserDefaults.standard.set(intervalMinutes, forKey: "intervalMinutes")
        }
    }
    
    @Published var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: "isEnabled")
        }
    }
    
    @Published var enableScreenSaver: Bool {
        didSet {
            UserDefaults.standard.set(enableScreenSaver, forKey: "enableScreenSaver")
        }
    }
    
    @Published var nextReminderDate: Date?
    
    @Published var breakDurationMinutes: Int {
        didSet {
            UserDefaults.standard.set(breakDurationMinutes, forKey: "breakDurationMinutes")
        }
    }
    
    // Preset intervals in minutes
    static let presetIntervals = [15, 20, 25, 30, 45, 60, 90, 120]
    
    private init() {
        // Load saved settings or use defaults
        self.intervalMinutes = UserDefaults.standard.object(forKey: "intervalMinutes") as? Int ?? 25
        self.isEnabled = UserDefaults.standard.object(forKey: "isEnabled") as? Bool ?? true
        self.enableScreenSaver = UserDefaults.standard.object(forKey: "enableScreenSaver") as? Bool ?? false
        self.breakDurationMinutes = UserDefaults.standard.object(forKey: "breakDurationMinutes") as? Int ?? 5
    }
}

