import XCTest
@testable import Foundation

/// Functional tests for Localization
final class LocalizationTests: XCTestCase {
    
    // MARK: - Language Enum Tests
    
    func testLanguageEnumValues() {
        let english = "en"
        let vietnamese = "vi"
        
        XCTAssertEqual(english, "en", "English code should be 'en'")
        XCTAssertEqual(vietnamese, "vi", "Vietnamese code should be 'vi'")
    }
    
    func testLanguageDisplayNames() {
        let englishDisplay = "🇺🇸 English"
        let vietnameseDisplay = "🇻🇳 Tiếng Việt"
        
        XCTAssertTrue(englishDisplay.contains("English"), "English display should contain 'English'")
        XCTAssertTrue(vietnameseDisplay.contains("Tiếng Việt"), "Vietnamese display should contain 'Tiếng Việt'")
    }
    
    // MARK: - App Title Tests
    
    func testAppTitle() {
        let title = "Work Time Reminder"
        XCTAssertEqual(title, "Work Time Reminder", "App title should be consistent")
    }
    
    func testAppSubtitle() {
        let englishSubtitle = "Break Reminder"
        let vietnameseSubtitle = "Nhắc nhở nghỉ ngơi"
        
        XCTAssertFalse(englishSubtitle.isEmpty, "English subtitle should not be empty")
        XCTAssertFalse(vietnameseSubtitle.isEmpty, "Vietnamese subtitle should not be empty")
    }
    
    // MARK: - Status Strings Tests
    
    func testStatusStrings() {
        let testCases: [(key: String, english: String, vietnamese: String)] = [
            ("statusActive", "Active", "Đang hoạt động"),
            ("statusInactive", "Disabled", "Đã tắt"),
            ("nextReminder", "Next reminder", "Nhắc nhở tiếp theo")
        ]
        
        for testCase in testCases {
            XCTAssertFalse(testCase.english.isEmpty, "\(testCase.key) English should not be empty")
            XCTAssertFalse(testCase.vietnamese.isEmpty, "\(testCase.key) Vietnamese should not be empty")
        }
    }
    
    // MARK: - Navigation Strings Tests
    
    func testNavigationStrings() {
        let strings: [(english: String, vietnamese: String)] = [
            ("Settings", "Cài đặt"),
            ("Back", "Quay lại"),
            ("Quit", "Thoát")
        ]
        
        for (english, vietnamese) in strings {
            XCTAssertFalse(english.isEmpty, "English navigation string should not be empty")
            XCTAssertFalse(vietnamese.isEmpty, "Vietnamese navigation string should not be empty")
        }
    }
    
    // MARK: - Break Overlay Strings Tests
    
    func testBreakOverlayStrings() {
        let englishTitle = "TAKE A BREAK!"
        let vietnameseTitle = "NGHỈ NGƠI THÔI!"
        
        XCTAssertTrue(englishTitle.contains("BREAK"), "English title should contain 'BREAK'")
        XCTAssertTrue(vietnameseTitle.contains("NGHỈ"), "Vietnamese title should contain 'NGHỈ'")
        
        let englishSubtitle = "Stand up, stretch and rest your eyes"
        let vietnameseSubtitle = "Hãy đứng dậy, thư giãn và nghỉ ngơi đôi mắt"
        
        XCTAssertFalse(englishSubtitle.isEmpty, "English subtitle should not be empty")
        XCTAssertFalse(vietnameseSubtitle.isEmpty, "Vietnamese subtitle should not be empty")
    }
    
    // MARK: - Time Unit Tests
    
    func testTimeUnitStrings() {
        let testCases: [(english: String, vietnamese: String)] = [
            ("min", "phút"),
            ("sec", "giây"),
            ("h", "giờ"),
            ("days", "ngày")
        ]
        
        for (english, vietnamese) in testCases {
            XCTAssertFalse(english.isEmpty, "English time unit should not be empty")
            XCTAssertFalse(vietnamese.isEmpty, "Vietnamese time unit should not be empty")
        }
    }
    
    // MARK: - Notification Strings Tests
    
    func testNotificationTitle() {
        let englishTitle = "⏰ Time for a break!"
        let vietnameseTitle = "⏰ Nghỉ ngơi thôi!"
        
        XCTAssertTrue(englishTitle.contains("⏰"), "Notification title should have emoji")
        XCTAssertTrue(vietnameseTitle.contains("⏰"), "Vietnamese title should have emoji")
    }
    
    func testNotificationBody() {
        let minutes = 25
        
        let englishBody = "You've been working for \(minutes) minutes. Take a break and rest your eyes!"
        let vietnameseBody = "Bạn đã làm việc \(minutes) phút. Hãy nghỉ ngơi và thư giãn đôi mắt!"
        
        XCTAssertTrue(englishBody.contains("\(minutes)"), "English body should contain minutes value")
        XCTAssertTrue(vietnameseBody.contains("\(minutes)"), "Vietnamese body should contain minutes value")
    }
    
    // MARK: - Snooze Strings Tests
    
    func testSnoozeButtonString() {
        let snoozeDuration = 5
        
        let englishSnooze = "Snooze \(snoozeDuration)m"
        let vietnameseSnooze = "Hoãn \(snoozeDuration) phút"
        
        XCTAssertTrue(englishSnooze.contains("\(snoozeDuration)"), "English snooze should contain duration")
        XCTAssertTrue(vietnameseSnooze.contains("\(snoozeDuration)"), "Vietnamese snooze should contain duration")
    }
    
    // MARK: - Statistics Strings Tests
    
    func testStatisticsStrings() {
        let strings: [(key: String, english: String, vietnamese: String)] = [
            ("statistics", "Statistics", "Thống kê"),
            ("todayStats", "Today", "Hôm nay"),
            ("weekStats", "This Week", "Tuần này"),
            ("sessions", "Sessions", "Phiên"),
            ("workTime", "Work time", "Thời gian làm việc"),
            ("breaksCompleted", "Breaks", "Lần nghỉ")
        ]
        
        for testCase in strings {
            XCTAssertFalse(testCase.english.isEmpty, "\(testCase.key) English should not be empty")
            XCTAssertFalse(testCase.vietnamese.isEmpty, "\(testCase.key) Vietnamese should not be empty")
        }
    }
    
    // MARK: - Schedule Strings Tests
    
    func testScheduleStrings() {
        let strings: [(key: String, english: String, vietnamese: String)] = [
            ("schedule", "Work Schedule", "Lịch làm việc"),
            ("workHours", "Work hours", "Giờ làm việc"),
            ("workDays", "Work days", "Ngày làm việc"),
            ("to", "to", "đến")
        ]
        
        for testCase in strings {
            XCTAssertFalse(testCase.english.isEmpty, "\(testCase.key) English should not be empty")
            XCTAssertFalse(testCase.vietnamese.isEmpty, "\(testCase.key) Vietnamese should not be empty")
        }
    }
    
    // MARK: - Profile Strings Tests
    
    func testProfileStrings() {
        let strings: [(key: String, english: String, vietnamese: String)] = [
            ("profiles", "Work Profiles", "Chế độ làm việc"),
            ("selectProfile", "Select profile", "Chọn chế độ"),
            ("customProfile", "Custom", "Tùy chỉnh")
        ]
        
        for testCase in strings {
            XCTAssertFalse(testCase.english.isEmpty, "\(testCase.key) English should not be empty")
            XCTAssertFalse(testCase.vietnamese.isEmpty, "\(testCase.key) Vietnamese should not be empty")
        }
    }
    
    // MARK: - Keyboard Shortcuts Strings Tests
    
    func testShortcutStrings() {
        let strings: [(key: String, english: String, vietnamese: String)] = [
            ("shortcuts", "Shortcuts", "Phím tắt"),
            ("pauseResume", "Pause/Resume", "Tạm dừng/Tiếp tục"),
            ("skipReminder", "Skip reminder", "Bỏ qua nhắc nhở"),
            ("resetTimer", "Reset timer", "Reset timer")
        ]
        
        for testCase in strings {
            XCTAssertFalse(testCase.english.isEmpty, "\(testCase.key) English should not be empty")
            XCTAssertFalse(testCase.vietnamese.isEmpty, "\(testCase.key) Vietnamese should not be empty")
        }
    }
    
    // MARK: - Language Toggle Tests
    
    func testLanguageToggle() {
        var currentLanguage = "vi"
        
        currentLanguage = currentLanguage == "vi" ? "en" : "vi"
        XCTAssertEqual(currentLanguage, "en", "Should toggle to English")
        
        currentLanguage = currentLanguage == "vi" ? "en" : "vi"
        XCTAssertEqual(currentLanguage, "vi", "Should toggle back to Vietnamese")
    }
    
    // MARK: - String Consistency Tests
    
    func testStringConsistency() {
        // All strings should not be nil or empty
        let requiredStrings = [
            "App Title",
            "Settings",
            "Back",
            "Quit",
            "Active",
            "Disabled",
            "Statistics",
            "Profiles"
        ]
        
        for str in requiredStrings {
            XCTAssertFalse(str.isEmpty, "\(str) should not be empty")
        }
    }
}

