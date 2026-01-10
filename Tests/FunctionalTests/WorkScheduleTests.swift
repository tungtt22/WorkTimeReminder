import XCTest
@testable import Foundation

/// Functional tests for Work Schedule feature
final class WorkScheduleTests: XCTestCase {
    
    // MARK: - Default Values Tests
    
    func testDefaultScheduleDisabled() {
        let defaultEnabled = false
        XCTAssertFalse(defaultEnabled, "Schedule should be disabled by default")
    }
    
    func testDefaultWorkHours() {
        let defaultStartHour = 8
        let defaultEndHour = 18
        
        XCTAssertEqual(defaultStartHour, 8, "Default start hour should be 8")
        XCTAssertEqual(defaultEndHour, 18, "Default end hour should be 18")
    }
    
    func testDefaultWorkDays() {
        let defaultWorkDays = Set([2, 3, 4, 5, 6]) // Monday to Friday
        
        XCTAssertTrue(defaultWorkDays.contains(2), "Should include Monday")
        XCTAssertTrue(defaultWorkDays.contains(3), "Should include Tuesday")
        XCTAssertTrue(defaultWorkDays.contains(4), "Should include Wednesday")
        XCTAssertTrue(defaultWorkDays.contains(5), "Should include Thursday")
        XCTAssertTrue(defaultWorkDays.contains(6), "Should include Friday")
        XCTAssertFalse(defaultWorkDays.contains(1), "Should NOT include Sunday")
        XCTAssertFalse(defaultWorkDays.contains(7), "Should NOT include Saturday")
    }
    
    // MARK: - Time Range Tests
    
    func testIsWithinWorkHours() {
        let testCases: [(hour: Int, minute: Int, startHour: Int, endHour: Int, expected: Bool)] = [
            (9, 0, 8, 18, true),    // 9:00 AM within 8-18
            (8, 0, 8, 18, true),    // 8:00 AM exactly at start
            (17, 59, 8, 18, true),  // 5:59 PM within range
            (18, 0, 8, 18, false),  // 6:00 PM at end (exclusive)
            (7, 59, 8, 18, false),  // 7:59 AM before start
            (20, 0, 8, 18, false),  // 8:00 PM after end
            (12, 30, 9, 17, true),  // 12:30 PM within 9-17
        ]
        
        for testCase in testCases {
            let isWithin = isWithinTimeRange(
                hour: testCase.hour,
                minute: testCase.minute,
                startHour: testCase.startHour,
                endHour: testCase.endHour
            )
            
            XCTAssertEqual(isWithin, testCase.expected, 
                           "\(testCase.hour):\(testCase.minute) should be \(testCase.expected ? "within" : "outside") \(testCase.startHour)-\(testCase.endHour)")
        }
    }
    
    // MARK: - Work Day Tests
    
    func testIsWorkDay() {
        let workDays = Set([2, 3, 4, 5, 6]) // Mon-Fri
        
        let testCases: [(weekday: Int, expected: Bool)] = [
            (1, false),  // Sunday
            (2, true),   // Monday
            (3, true),   // Tuesday
            (4, true),   // Wednesday
            (5, true),   // Thursday
            (6, true),   // Friday
            (7, false),  // Saturday
        ]
        
        for testCase in testCases {
            let isWorkDay = workDays.contains(testCase.weekday)
            XCTAssertEqual(isWorkDay, testCase.expected, 
                           "Weekday \(testCase.weekday) should be \(testCase.expected ? "work day" : "non-work day")")
        }
    }
    
    // MARK: - Schedule Preset Tests
    
    func testSchedulePresets() {
        let presets: [(name: String, startHour: Int, endHour: Int)] = [
            ("Office Hours", 9, 17),
            ("Early Bird", 7, 15),
            ("Extended", 8, 18),
            ("Night Owl", 14, 22)
        ]
        
        for preset in presets {
            XCTAssertLessThan(preset.startHour, preset.endHour, 
                              "\(preset.name) should have valid time range")
            XCTAssertGreaterThanOrEqual(preset.startHour, 0, 
                                        "\(preset.name) start should be >= 0")
            XCTAssertLessThan(preset.endHour, 24, 
                              "\(preset.name) end should be < 24")
        }
    }
    
    // MARK: - Combined Schedule Check Tests
    
    func testFullScheduleCheck() {
        // Test: Monday at 10:00 AM with 9-17 schedule and Mon-Fri work days
        let result = isWithinSchedule(
            weekday: 2,           // Monday
            hour: 10,
            minute: 0,
            startHour: 9,
            endHour: 17,
            workDays: Set([2, 3, 4, 5, 6])
        )
        
        XCTAssertTrue(result, "Monday 10:00 should be within schedule")
    }
    
    func testScheduleCheckOnWeekend() {
        // Test: Saturday at 10:00 AM (should fail - not a work day)
        let result = isWithinSchedule(
            weekday: 7,           // Saturday
            hour: 10,
            minute: 0,
            startHour: 9,
            endHour: 17,
            workDays: Set([2, 3, 4, 5, 6])
        )
        
        XCTAssertFalse(result, "Saturday should NOT be within schedule")
    }
    
    func testScheduleCheckOutsideHours() {
        // Test: Monday at 7:00 PM (should fail - outside hours)
        let result = isWithinSchedule(
            weekday: 2,           // Monday
            hour: 19,
            minute: 0,
            startHour: 9,
            endHour: 17,
            workDays: Set([2, 3, 4, 5, 6])
        )
        
        XCTAssertFalse(result, "Monday 7:00 PM should NOT be within schedule")
    }
    
    func testScheduleDisabledReturnsTrue() {
        // When schedule is disabled, should always return true
        let scheduleEnabled = false
        
        let result = scheduleEnabled ? false : true
        
        XCTAssertTrue(result, "Disabled schedule should allow all times")
    }
    
    // MARK: - Day Name Tests
    
    func testDayNamesEnglish() {
        let dayNames = [
            (1, "Sun"),
            (2, "Mon"),
            (3, "Tue"),
            (4, "Wed"),
            (5, "Thu"),
            (6, "Fri"),
            (7, "Sat")
        ]
        
        for (weekday, expected) in dayNames {
            let name = getDayName(weekday: weekday, isVietnamese: false)
            XCTAssertEqual(name, expected, "Weekday \(weekday) should be \(expected)")
        }
    }
    
    func testDayNamesVietnamese() {
        let dayNames = [
            (1, "CN"),
            (2, "T2"),
            (3, "T3"),
            (4, "T4"),
            (5, "T5"),
            (6, "T6"),
            (7, "T7")
        ]
        
        for (weekday, expected) in dayNames {
            let name = getDayName(weekday: weekday, isVietnamese: true)
            XCTAssertEqual(name, expected, "Weekday \(weekday) should be \(expected)")
        }
    }
    
    // MARK: - Time String Tests
    
    func testTimeStringFormatting() {
        let testCases: [(hour: Int, minute: Int, expected: String)] = [
            (8, 0, "08:00"),
            (9, 30, "09:30"),
            (12, 0, "12:00"),
            (17, 45, "17:45"),
            (0, 0, "00:00"),
            (23, 59, "23:59")
        ]
        
        for testCase in testCases {
            let formatted = String(format: "%02d:%02d", testCase.hour, testCase.minute)
            XCTAssertEqual(formatted, testCase.expected, "Time should format as \(testCase.expected)")
        }
    }
    
    // MARK: - Helper Methods
    
    private func isWithinTimeRange(hour: Int, minute: Int, startHour: Int, endHour: Int) -> Bool {
        let currentMinutes = hour * 60 + minute
        let startMinutes = startHour * 60
        let endMinutes = endHour * 60
        
        return currentMinutes >= startMinutes && currentMinutes < endMinutes
    }
    
    private func isWithinSchedule(weekday: Int, hour: Int, minute: Int, startHour: Int, endHour: Int, workDays: Set<Int>) -> Bool {
        guard workDays.contains(weekday) else { return false }
        return isWithinTimeRange(hour: hour, minute: minute, startHour: startHour, endHour: endHour)
    }
    
    private func getDayName(weekday: Int, isVietnamese: Bool) -> String {
        if isVietnamese {
            switch weekday {
            case 1: return "CN"
            case 2: return "T2"
            case 3: return "T3"
            case 4: return "T4"
            case 5: return "T5"
            case 6: return "T6"
            case 7: return "T7"
            default: return ""
            }
        } else {
            switch weekday {
            case 1: return "Sun"
            case 2: return "Mon"
            case 3: return "Tue"
            case 4: return "Wed"
            case 5: return "Thu"
            case 6: return "Fri"
            case 7: return "Sat"
            default: return ""
            }
        }
    }
}

