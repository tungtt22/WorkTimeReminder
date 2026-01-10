import Foundation

// MARK: - Custom Notification Names
extension Notification.Name {
    static let keepAwakeChanged = Notification.Name("keepAwakeChanged")
    static let snoozeRequested = Notification.Name("snoozeRequested")
    static let skipRequested = Notification.Name("skipRequested")
    static let toggleRequested = Notification.Name("toggleRequested")
    static let resetRequested = Notification.Name("resetRequested")
}

