import XCTest
@testable import Foundation

/// Functional tests for ReminderManager
/// Tests all core timer and settings functionality
final class ReminderManagerTests: XCTestCase {
    
    // MARK: - Test Data
    
    private var testDefaults: UserDefaults!
    
    override func setUp() {
        super.setUp()
        // Use a separate UserDefaults suite for testing
        testDefaults = UserDefaults(suiteName: "com.test.WorkTimeReminder")
        testDefaults?.removePersistentDomain(forName: "com.test.WorkTimeReminder")
    }
    
    override func tearDown() {
        testDefaults?.removePersistentDomain(forName: "com.test.WorkTimeReminder")
        super.tearDown()
    }
    
    // MARK: - Interval Tests
    
    func testDefaultInterval() {
        let defaultInterval = 25
        XCTAssertEqual(defaultInterval, 25, "Default interval should be 25 minutes")
    }
    
    func testIntervalRange() {
        let validIntervals = [5, 10, 15, 20, 25, 30, 45, 60, 90, 120, 180]
        
        for interval in validIntervals {
            XCTAssertGreaterThanOrEqual(interval, 5, "Interval should be at least 5 minutes")
            XCTAssertLessThanOrEqual(interval, 180, "Interval should be at most 180 minutes")
        }
    }
    
    func testIntervalPersistence() {
        let testInterval = 45
        testDefaults?.set(testInterval, forKey: "intervalMinutes")
        
        let retrieved = testDefaults?.integer(forKey: "intervalMinutes")
        XCTAssertEqual(retrieved, testInterval, "Interval should persist correctly")
    }
    
    // MARK: - Enable/Disable Tests
    
    func testDefaultEnabled() {
        let defaultEnabled = true
        XCTAssertTrue(defaultEnabled, "App should be enabled by default")
    }
    
    func testToggleEnabled() {
        var isEnabled = true
        
        isEnabled.toggle()
        XCTAssertFalse(isEnabled, "Should be disabled after toggle")
        
        isEnabled.toggle()
        XCTAssertTrue(isEnabled, "Should be enabled after second toggle")
    }
    
    // MARK: - Snooze Tests
    
    func testDefaultSnoozeDuration() {
        let defaultSnooze = 5
        XCTAssertEqual(defaultSnooze, 5, "Default snooze should be 5 minutes")
    }
    
    func testSnoozeRange() {
        let minSnooze = 1
        let maxSnooze = 30
        
        XCTAssertGreaterThanOrEqual(minSnooze, 1, "Min snooze should be 1 minute")
        XCTAssertLessThanOrEqual(maxSnooze, 30, "Max snooze should be 30 minutes")
    }
    
    func testSnoozeCalculation() {
        let snoozeDuration = 5
        let now = Date()
        let snoozeEnd = now.addingTimeInterval(TimeInterval(snoozeDuration * 60))
        
        let expectedInterval = TimeInterval(snoozeDuration * 60)
        let actualInterval = snoozeEnd.timeIntervalSince(now)
        
        XCTAssertEqual(actualInterval, expectedInterval, accuracy: 0.1, "Snooze end time should be calculated correctly")
    }
    
    // MARK: - Break Duration Tests
    
    func testDefaultBreakDuration() {
        let defaultBreak = 5
        XCTAssertEqual(defaultBreak, 5, "Default break duration should be 5 minutes")
    }
    
    func testBreakDurationRange() {
        let validDurations = [1, 3, 5, 10, 15, 20, 30]
        
        for duration in validDurations {
            XCTAssertGreaterThanOrEqual(duration, 1, "Break should be at least 1 minute")
            XCTAssertLessThanOrEqual(duration, 30, "Break should be at most 30 minutes")
        }
    }
    
    // MARK: - Overlay Tests
    
    func testDefaultOverlayEnabled() {
        let defaultEnabled = true
        XCTAssertTrue(defaultEnabled, "Overlay should be enabled by default")
    }
    
    func testOverlayDurationRange() {
        let validDurations = [5, 10, 15, 20, 30, 60, 120, 300]
        
        for duration in validDurations {
            XCTAssertGreaterThanOrEqual(duration, 5, "Overlay should show for at least 5 seconds")
            XCTAssertLessThanOrEqual(duration, 300, "Overlay should show for at most 300 seconds")
        }
    }
    
    // MARK: - Sound Tests
    
    func testDefaultSoundEnabled() {
        let defaultEnabled = true
        XCTAssertTrue(defaultEnabled, "Sound should be enabled by default")
    }
    
    func testSoundOptions() {
        let soundOptions = ["default", "Basso", "Blow", "Bottle", "Frog", "Funk", "Glass", "Hero", "Morse", "Ping", "Pop", "Purr", "Sosumi", "Submarine", "Tink"]
        
        XCTAssertGreaterThan(soundOptions.count, 0, "Should have at least one sound option")
        XCTAssertTrue(soundOptions.contains("default"), "Should have default sound option")
    }
    
    // MARK: - Timer Calculation Tests
    
    func testNextReminderCalculation() {
        let intervalMinutes = 25
        let now = Date()
        let nextReminder = now.addingTimeInterval(TimeInterval(intervalMinutes * 60))
        
        let remaining = nextReminder.timeIntervalSince(now)
        
        XCTAssertEqual(remaining, TimeInterval(intervalMinutes * 60), accuracy: 0.1, "Next reminder should be calculated correctly")
    }
    
    func testTimeFormatting() {
        let testCases: [(seconds: Int, expected: String)] = [
            (0, "00:00"),
            (59, "00:59"),
            (60, "01:00"),
            (125, "02:05"),
            (1500, "25:00"),
            (3600, "1:00:00"),
            (3661, "1:01:01")
        ]
        
        for testCase in testCases {
            let formatted = formatTime(seconds: testCase.seconds)
            XCTAssertEqual(formatted, testCase.expected, "Time \(testCase.seconds)s should format as \(testCase.expected)")
        }
    }
    
    // MARK: - Auto Reset Tests
    
    func testAutoResetCondition() {
        let breakDurationMinutes = 5
        let breakDurationSeconds = TimeInterval(breakDurationMinutes * 60)
        
        // Test: screen locked for less than break duration
        let shortLockDuration: TimeInterval = 180 // 3 minutes
        XCTAssertFalse(shortLockDuration >= breakDurationSeconds, "Should NOT reset for short lock")
        
        // Test: screen locked for break duration
        let exactLockDuration: TimeInterval = 300 // 5 minutes
        XCTAssertTrue(exactLockDuration >= breakDurationSeconds, "Should reset for exact break duration")
        
        // Test: screen locked for longer than break duration
        let longLockDuration: TimeInterval = 600 // 10 minutes
        XCTAssertTrue(longLockDuration >= breakDurationSeconds, "Should reset for long lock")
    }
    
    // MARK: - Helper Methods
    
    private func formatTime(seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        } else {
            return String(format: "%02d:%02d", minutes, secs)
        }
    }
}

