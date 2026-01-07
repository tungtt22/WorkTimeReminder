import Foundation
import Combine
import UserNotifications
import AppKit

// MARK: - Notification Sound Options
enum NotificationSound: String, CaseIterable {
    case `default` = "default"
    case glass = "Glass"
    case ping = "Ping"
    case pop = "Pop"
    case purr = "Purr"
    case submarine = "Submarine"
    case tink = "Tink"
    case blow = "Blow"
    case bottle = "Bottle"
    case frog = "Frog"
    case funk = "Funk"
    case hero = "Hero"
    case morse = "Morse"
    case sosumi = "Sosumi"
    
    var displayName: String {
        switch self {
        case .default: return "Default"
        case .glass: return "🔔 Glass"
        case .ping: return "🛎 Ping"
        case .pop: return "💥 Pop"
        case .purr: return "🐱 Purr"
        case .submarine: return "🚢 Submarine"
        case .tink: return "✨ Tink"
        case .blow: return "💨 Blow"
        case .bottle: return "🍾 Bottle"
        case .frog: return "🐸 Frog"
        case .funk: return "🎸 Funk"
        case .hero: return "🦸 Hero"
        case .morse: return "📡 Morse"
        case .sosumi: return "🎵 Sosumi"
        }
    }
    
    var unSound: UNNotificationSound {
        if self == .default {
            return .default
        }
        return UNNotificationSound(named: UNNotificationSoundName(rawValue: "/System/Library/Sounds/\(self.rawValue).aiff"))
    }
}

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
    
    @Published var notificationSound: NotificationSound {
        didSet {
            UserDefaults.standard.set(notificationSound.rawValue, forKey: "notificationSound")
        }
    }
    
    @Published var enableSound: Bool {
        didSet {
            UserDefaults.standard.set(enableSound, forKey: "enableSound")
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
        self.enableSound = UserDefaults.standard.object(forKey: "enableSound") as? Bool ?? true
        
        let soundRaw = UserDefaults.standard.string(forKey: "notificationSound") ?? "default"
        self.notificationSound = NotificationSound(rawValue: soundRaw) ?? .default
    }
    
    // Play sound preview
    func playSound(_ sound: NotificationSound) {
        if sound == .default {
            NSSound(named: "Glass")?.play()
        } else {
            NSSound(named: sound.rawValue)?.play()
        }
    }
}

