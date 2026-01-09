import Foundation
import UserNotifications

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

