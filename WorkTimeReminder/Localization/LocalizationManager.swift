import Foundation
import SwiftUI

// MARK: - Language
enum Language: String, CaseIterable {
    case vietnamese = "vi"
    case english = "en"
    
    var displayName: String {
        switch self {
        case .vietnamese: return "🇻🇳 Tiếng Việt"
        case .english: return "🇺🇸 English"
        }
    }
    
    var shortName: String {
        switch self {
        case .vietnamese: return "VI"
        case .english: return "EN"
        }
    }
}

// MARK: - Localization Manager
class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @Published var currentLanguage: Language {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: "appLanguage")
        }
    }
    
    private init() {
        let savedLanguage = UserDefaults.standard.string(forKey: "appLanguage") ?? "vi"
        self.currentLanguage = Language(rawValue: savedLanguage) ?? .vietnamese
    }
    
    func toggleLanguage() {
        currentLanguage = currentLanguage == .vietnamese ? .english : .vietnamese
    }
}

// MARK: - Localized Strings
struct L10n {
    static var shared: L10n { L10n() }
    
    private var lang: Language {
        LocalizationManager.shared.currentLanguage
    }
    
    // MARK: - App
    var appTitle: String {
        "Work Time Reminder"
    }
    
    var appSubtitle: String {
        lang == .vietnamese ? "Nhắc nhở nghỉ ngơi" : "Break Reminder"
    }
    
    // MARK: - Status
    var statusActive: String {
        lang == .vietnamese ? "Đang hoạt động" : "Active"
    }
    
    var statusInactive: String {
        lang == .vietnamese ? "Đã tắt" : "Disabled"
    }
    
    var nextReminder: String {
        lang == .vietnamese ? "Nhắc nhở tiếp theo" : "Next reminder"
    }
    
    // MARK: - Interval
    var workInterval: String {
        lang == .vietnamese ? "Khoảng thời gian làm việc" : "Work interval"
    }
    
    var minutes: String {
        lang == .vietnamese ? "phút" : "min"
    }
    
    var customPlaceholder: String {
        lang == .vietnamese ? "Tùy chỉnh (phút)" : "Custom (minutes)"
    }
    
    var setButton: String {
        lang == .vietnamese ? "Đặt" : "Set"
    }
    
    // MARK: - Settings
    var settings: String {
        lang == .vietnamese ? "Cài đặt" : "Settings"
    }
    
    var screenSaverTitle: String {
        lang == .vietnamese ? "Bật Screen Saver" : "Enable Screen Saver"
    }
    
    var screenSaverSubtitle: String {
        lang == .vietnamese ? "Tự động bật khi đến giờ nghỉ" : "Auto activate on break time"
    }
    
    var testNotification: String {
        lang == .vietnamese ? "Kiểm tra thông báo" : "Test notification"
    }
    
    var language: String {
        lang == .vietnamese ? "Ngôn ngữ" : "Language"
    }
    
    // MARK: - Footer
    var quit: String {
        lang == .vietnamese ? "Thoát" : "Quit"
    }
    
    // MARK: - Navigation
    var back: String {
        lang == .vietnamese ? "Quay lại" : "Back"
    }
    
    // MARK: - About
    var notifications: String {
        lang == .vietnamese ? "Thông báo" : "Notifications"
    }
    
    var about: String {
        lang == .vietnamese ? "Thông tin" : "About"
    }
    
    var developer: String {
        lang == .vietnamese ? "Nhà phát triển" : "Developer"
    }
    
    // MARK: - Sound
    var sound: String {
        lang == .vietnamese ? "Âm thanh" : "Sound"
    }
    
    var enableSound: String {
        lang == .vietnamese ? "Bật âm thanh" : "Enable sound"
    }
    
    var soundWhenNotify: String {
        lang == .vietnamese ? "Phát âm thanh khi thông báo" : "Play sound on notification"
    }
    
    var selectSound: String {
        lang == .vietnamese ? "Chọn âm thanh" : "Select sound"
    }
    
    var previewSound: String {
        lang == .vietnamese ? "Nghe thử" : "Preview"
    }
    
    // MARK: - Overlay
    var overlay: String {
        lang == .vietnamese ? "Màn hình lớn" : "Full Screen Alert"
    }
    
    var enableOverlay: String {
        lang == .vietnamese ? "Hiển thị màn hình lớn" : "Show full screen alert"
    }
    
    var overlaySubtitle: String {
        lang == .vietnamese ? "Hiện chữ to trên toàn màn hình" : "Display large text on screen"
    }
    
    var overlayDuration: String {
        lang == .vietnamese ? "Thời gian hiển thị" : "Display duration"
    }
    
    var overlayColorLabel: String {
        lang == .vietnamese ? "Màu sắc" : "Color"
    }
    
    var customDuration: String {
        lang == .vietnamese ? "Tùy chỉnh:" : "Custom:"
    }
    
    var seconds: String {
        lang == .vietnamese ? "giây" : "sec"
    }
    
    // MARK: - Break Overlay
    var breakTimeTitle: String {
        lang == .vietnamese ? "NGHỈ NGƠI THÔI!" : "TAKE A BREAK!"
    }
    
    var breakTimeSubtitle: String {
        lang == .vietnamese ? "Hãy đứng dậy, thư giãn và nghỉ ngơi đôi mắt" : "Stand up, stretch and rest your eyes"
    }
    
    var dismissButton: String {
        lang == .vietnamese ? "Đóng" : "Dismiss"
    }
    
    var closingIn: String {
        lang == .vietnamese ? "Tự động đóng sau" : "Closing in"
    }
    
    var pressEscToClose: String {
        lang == .vietnamese ? "Nhấn ESC để đóng" : "Press ESC to close"
    }
    
    // MARK: - Auto Reset
    var autoReset: String {
        lang == .vietnamese ? "Tự động reset" : "Auto Reset"
    }
    
    var autoResetTitle: String {
        lang == .vietnamese ? "Tự động reset khi nghỉ" : "Auto reset after break"
    }
    
    var autoResetSubtitle: String {
        lang == .vietnamese ? "Reset timer khi khoá màn hình đủ thời gian nghỉ" : "Reset timer when screen locked for break duration"
    }
    
    var breakDuration: String {
        lang == .vietnamese ? "Thời gian nghỉ" : "Break duration"
    }
    
    // MARK: - Keep Awake
    var keepAwakeTitle: String {
        lang == .vietnamese ? "Giữ màn hình sáng" : "Keep screen awake"
    }
    
    var keepAwakeSubtitle: String {
        lang == .vietnamese ? "Ngăn màn hình tự tắt khi đang làm việc" : "Prevent screen from sleeping while working"
    }
    
    // MARK: - Notifications
    var notificationTitle: String {
        lang == .vietnamese ? "⏰ Nghỉ ngơi thôi!" : "⏰ Time for a break!"
    }
    
    func notificationBody(minutes: Int) -> String {
        if lang == .vietnamese {
            return "Bạn đã làm việc \(minutes) phút. Hãy nghỉ ngơi và thư giãn đôi mắt!"
        } else {
            return "You've been working for \(minutes) minutes. Take a break and rest your eyes!"
        }
    }
    
    // MARK: - Snooze
    func snoozeButton(minutes: Int) -> String {
        lang == .vietnamese ? "Hoãn \(minutes) phút" : "Snooze \(minutes)m"
    }
    
    var snoozeDuration: String {
        lang == .vietnamese ? "Thời gian hoãn" : "Snooze duration"
    }
    
    // MARK: - Statistics
    var statistics: String {
        lang == .vietnamese ? "Thống kê" : "Statistics"
    }
    
    var todayStats: String {
        lang == .vietnamese ? "Hôm nay" : "Today"
    }
    
    var weekStats: String {
        lang == .vietnamese ? "Tuần này" : "This Week"
    }
    
    var sessions: String {
        lang == .vietnamese ? "Phiên" : "Sessions"
    }
    
    var workTime: String {
        lang == .vietnamese ? "Thời gian làm việc" : "Work time"
    }
    
    var breaksCompleted: String {
        lang == .vietnamese ? "Lần nghỉ" : "Breaks"
    }
    
    var avgSession: String {
        lang == .vietnamese ? "TB mỗi phiên" : "Avg session"
    }
    
    var longestStreak: String {
        lang == .vietnamese ? "Chuỗi dài nhất" : "Longest streak"
    }
    
    var days: String {
        lang == .vietnamese ? "ngày" : "days"
    }
    
    var hours: String {
        lang == .vietnamese ? "giờ" : "h"
    }
    
    var resetStats: String {
        lang == .vietnamese ? "Xóa thống kê" : "Reset statistics"
    }
    
    // MARK: - Work Schedule
    var schedule: String {
        lang == .vietnamese ? "Lịch làm việc" : "Work Schedule"
    }
    
    var scheduleTitle: String {
        lang == .vietnamese ? "Lịch làm việc" : "Work Schedule"
    }
    
    var scheduleSubtitle: String {
        lang == .vietnamese ? "Chỉ nhắc nhở trong giờ làm việc" : "Only remind during work hours"
    }
    
    var workHours: String {
        lang == .vietnamese ? "Giờ làm việc" : "Work hours"
    }
    
    var workDays: String {
        lang == .vietnamese ? "Ngày làm việc" : "Work days"
    }
    
    var to: String {
        lang == .vietnamese ? "đến" : "to"
    }
    
    // MARK: - Profiles
    var profiles: String {
        lang == .vietnamese ? "Chế độ làm việc" : "Work Profiles"
    }
    
    var selectProfile: String {
        lang == .vietnamese ? "Chọn chế độ" : "Select profile"
    }
    
    var customProfile: String {
        lang == .vietnamese ? "Tùy chỉnh" : "Custom"
    }
    
    var currentProfile: String {
        lang == .vietnamese ? "Chế độ hiện tại" : "Current profile"
    }
    
    // MARK: - Keyboard Shortcuts
    var shortcuts: String {
        lang == .vietnamese ? "Phím tắt" : "Shortcuts"
    }
    
    var pauseResume: String {
        lang == .vietnamese ? "Tạm dừng/Tiếp tục" : "Pause/Resume"
    }
    
    var skipReminder: String {
        lang == .vietnamese ? "Bỏ qua nhắc nhở" : "Skip reminder"
    }
    
    var resetTimer: String {
        lang == .vietnamese ? "Reset timer" : "Reset timer"
    }
}

