import Foundation
import Combine
import UserNotifications
import AppKit
import SwiftUI

// MARK: - Overlay Color Options
enum OverlayColor: String, CaseIterable {
    case blue = "blue"
    case teal = "teal"
    case green = "green"
    case orange = "orange"
    case pink = "pink"
    case purple = "purple"
    case red = "red"
    case gray = "gray"
    
    var displayName: String {
        switch self {
        case .blue: return "Blue"
        case .teal: return "Teal"
        case .green: return "Green"
        case .orange: return "Orange"
        case .pink: return "Pink"
        case .purple: return "Purple"
        case .red: return "Red"
        case .gray: return "Gray"
        }
    }
    
    var primaryColor: Color {
        switch self {
        case .blue: return Color(red: 0.3, green: 0.5, blue: 0.9)
        case .teal: return Color(red: 0.2, green: 0.7, blue: 0.7)
        case .green: return Color(red: 0.3, green: 0.7, blue: 0.4)
        case .orange: return Color(red: 0.95, green: 0.5, blue: 0.2)
        case .pink: return Color(red: 0.9, green: 0.4, blue: 0.6)
        case .purple: return Color(red: 0.6, green: 0.4, blue: 0.9)
        case .red: return Color(red: 0.9, green: 0.3, blue: 0.3)
        case .gray: return Color(red: 0.5, green: 0.5, blue: 0.55)
        }
    }
    
    var secondaryColor: Color {
        switch self {
        case .blue: return Color(red: 0.2, green: 0.3, blue: 0.7)
        case .teal: return Color(red: 0.1, green: 0.5, blue: 0.6)
        case .green: return Color(red: 0.2, green: 0.5, blue: 0.3)
        case .orange: return Color(red: 0.8, green: 0.3, blue: 0.1)
        case .pink: return Color(red: 0.7, green: 0.2, blue: 0.5)
        case .purple: return Color(red: 0.4, green: 0.2, blue: 0.7)
        case .red: return Color(red: 0.7, green: 0.15, blue: 0.2)
        case .gray: return Color(red: 0.35, green: 0.35, blue: 0.4)
        }
    }
}

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
    
    @Published var autoResetOnScreenLock: Bool {
        didSet {
            UserDefaults.standard.set(autoResetOnScreenLock, forKey: "autoResetOnScreenLock")
        }
    }
    
    // Preset intervals in minutes
    static let presetIntervals = [15, 20, 25, 30, 45, 60, 90, 120]
    
    // Preset overlay durations in seconds
    static let presetOverlayDurations = [5, 10, 15, 20, 30, 60]
    
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
        
        let soundRaw = UserDefaults.standard.string(forKey: "notificationSound") ?? "default"
        self.notificationSound = NotificationSound(rawValue: soundRaw) ?? .default
        
        let colorRaw = UserDefaults.standard.string(forKey: "overlayColor") ?? "blue"
        self.overlayColor = OverlayColor(rawValue: colorRaw) ?? .blue
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

