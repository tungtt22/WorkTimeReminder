import Foundation
import Combine
import AppKit

// MARK: - Reminder Manager
/// Manages all app settings and state
class ReminderManager: ObservableObject {
    
    // MARK: - Singleton
    static let shared = ReminderManager()
    
    // MARK: - Timer Settings
    
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
    
    @Published var nextReminderDate: Date?
    
    // MARK: - Break Settings
    
    @Published var breakDurationMinutes: Int {
        didSet {
            UserDefaults.standard.set(breakDurationMinutes, forKey: "breakDurationMinutes")
        }
    }
    
    @Published var autoResetOnScreenLock: Bool {
        didSet {
            UserDefaults.standard.set(autoResetOnScreenLock, forKey: "autoResetOnScreenLock")
        }
    }
    
    @Published var snoozeDurationMinutes: Int {
        didSet {
            UserDefaults.standard.set(snoozeDurationMinutes, forKey: "snoozeDurationMinutes")
        }
    }
    
    // MARK: - Screen Settings
    
    @Published var enableScreenSaver: Bool {
        didSet {
            UserDefaults.standard.set(enableScreenSaver, forKey: "enableScreenSaver")
        }
    }
    
    @Published var keepAwake: Bool {
        didSet {
            UserDefaults.standard.set(keepAwake, forKey: "keepAwake")
            NotificationCenter.default.post(name: .keepAwakeChanged, object: nil)
        }
    }
    
    // MARK: - Overlay Settings
    
    @Published var enableOverlay: Bool {
        didSet {
            UserDefaults.standard.set(enableOverlay, forKey: "enableOverlay")
        }
    }
    
    @Published var overlayDurationSeconds: Int {
        didSet {
            UserDefaults.standard.set(overlayDurationSeconds, forKey: "overlayDurationSeconds")
        }
    }
    
    @Published var overlayColor: OverlayColor {
        didSet {
            UserDefaults.standard.set(overlayColor.rawValue, forKey: "overlayColor")
        }
    }
    
    // MARK: - Sound Settings
    
    @Published var enableSound: Bool {
        didSet {
            UserDefaults.standard.set(enableSound, forKey: "enableSound")
        }
    }
    
    @Published var notificationSound: NotificationSound {
        didSet {
            UserDefaults.standard.set(notificationSound.rawValue, forKey: "notificationSound")
        }
    }
    
    // MARK: - Presets
    
    static let presetIntervals = [15, 20, 25, 30, 45, 60, 90, 120]
    static let presetOverlayDurations = [5, 10, 15, 20, 30, 60]
    
    // MARK: - Initialization
    
    private init() {
        // Load saved settings or use defaults
        self.intervalMinutes = UserDefaults.standard.object(forKey: "intervalMinutes") as? Int ?? 25
        self.isEnabled = UserDefaults.standard.object(forKey: "isEnabled") as? Bool ?? true
        self.enableScreenSaver = UserDefaults.standard.object(forKey: "enableScreenSaver") as? Bool ?? false
        self.breakDurationMinutes = UserDefaults.standard.object(forKey: "breakDurationMinutes") as? Int ?? 5
        self.enableSound = UserDefaults.standard.object(forKey: "enableSound") as? Bool ?? true
        self.enableOverlay = UserDefaults.standard.object(forKey: "enableOverlay") as? Bool ?? true
        self.overlayDurationSeconds = UserDefaults.standard.object(forKey: "overlayDurationSeconds") as? Int ?? 10
        self.autoResetOnScreenLock = UserDefaults.standard.object(forKey: "autoResetOnScreenLock") as? Bool ?? true
        self.keepAwake = UserDefaults.standard.object(forKey: "keepAwake") as? Bool ?? false
        self.snoozeDurationMinutes = UserDefaults.standard.object(forKey: "snoozeDurationMinutes") as? Int ?? 5
        
        let soundRaw = UserDefaults.standard.string(forKey: "notificationSound") ?? "default"
        self.notificationSound = NotificationSound(rawValue: soundRaw) ?? .default
        
        let colorRaw = UserDefaults.standard.string(forKey: "overlayColor") ?? "blue"
        self.overlayColor = OverlayColor(rawValue: colorRaw) ?? .blue
    }
    
    // MARK: - Methods
    
    func playSound(_ sound: NotificationSound) {
        if sound == .default {
            NSSound(named: "Glass")?.play()
        } else {
            NSSound(named: sound.rawValue)?.play()
        }
    }
}

