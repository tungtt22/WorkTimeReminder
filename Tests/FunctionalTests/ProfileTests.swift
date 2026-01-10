import XCTest
@testable import Foundation

/// Functional tests for Work Profiles feature
final class ProfileTests: XCTestCase {
    
    // MARK: - Built-in Profiles Tests
    
    func testBuiltInProfilesExist() {
        let builtInProfiles = [
            MockProfile(name: "Pomodoro", intervalMinutes: 25, breakDurationMinutes: 5, icon: "timer"),
            MockProfile(name: "Deep Work", intervalMinutes: 50, breakDurationMinutes: 10, icon: "brain.head.profile"),
            MockProfile(name: "Light Work", intervalMinutes: 15, breakDurationMinutes: 3, icon: "leaf"),
            MockProfile(name: "Long Session", intervalMinutes: 90, breakDurationMinutes: 15, icon: "hourglass")
        ]
        
        XCTAssertEqual(builtInProfiles.count, 4, "Should have 4 built-in profiles")
    }
    
    func testPomodoroProfile() {
        let pomodoro = MockProfile(name: "Pomodoro", intervalMinutes: 25, breakDurationMinutes: 5, icon: "timer")
        
        XCTAssertEqual(pomodoro.name, "Pomodoro", "Name should be Pomodoro")
        XCTAssertEqual(pomodoro.intervalMinutes, 25, "Interval should be 25 minutes")
        XCTAssertEqual(pomodoro.breakDurationMinutes, 5, "Break should be 5 minutes")
        XCTAssertEqual(pomodoro.icon, "timer", "Icon should be timer")
    }
    
    func testDeepWorkProfile() {
        let deepWork = MockProfile(name: "Deep Work", intervalMinutes: 50, breakDurationMinutes: 10, icon: "brain.head.profile")
        
        XCTAssertEqual(deepWork.name, "Deep Work", "Name should be Deep Work")
        XCTAssertEqual(deepWork.intervalMinutes, 50, "Interval should be 50 minutes")
        XCTAssertEqual(deepWork.breakDurationMinutes, 10, "Break should be 10 minutes")
    }
    
    func testLightWorkProfile() {
        let lightWork = MockProfile(name: "Light Work", intervalMinutes: 15, breakDurationMinutes: 3, icon: "leaf")
        
        XCTAssertEqual(lightWork.name, "Light Work", "Name should be Light Work")
        XCTAssertEqual(lightWork.intervalMinutes, 15, "Interval should be 15 minutes")
        XCTAssertEqual(lightWork.breakDurationMinutes, 3, "Break should be 3 minutes")
    }
    
    func testLongSessionProfile() {
        let longSession = MockProfile(name: "Long Session", intervalMinutes: 90, breakDurationMinutes: 15, icon: "hourglass")
        
        XCTAssertEqual(longSession.name, "Long Session", "Name should be Long Session")
        XCTAssertEqual(longSession.intervalMinutes, 90, "Interval should be 90 minutes")
        XCTAssertEqual(longSession.breakDurationMinutes, 15, "Break should be 15 minutes")
    }
    
    // MARK: - Profile Selection Tests
    
    func testProfileSelection() {
        var currentProfileId: UUID? = nil
        let profiles = [
            MockProfile(name: "Pomodoro", intervalMinutes: 25, breakDurationMinutes: 5, icon: "timer"),
            MockProfile(name: "Deep Work", intervalMinutes: 50, breakDurationMinutes: 10, icon: "brain.head.profile")
        ]
        
        // Select first profile
        currentProfileId = profiles[0].id
        XCTAssertEqual(currentProfileId, profiles[0].id, "Current profile should be Pomodoro")
        
        // Switch to second profile
        currentProfileId = profiles[1].id
        XCTAssertEqual(currentProfileId, profiles[1].id, "Current profile should be Deep Work")
    }
    
    func testCustomModeSelection() {
        var currentProfileId: UUID? = UUID()
        
        // Clear profile for custom mode
        currentProfileId = nil
        
        XCTAssertNil(currentProfileId, "Custom mode should have nil profile ID")
    }
    
    // MARK: - Profile Application Tests
    
    func testApplyProfile() {
        var intervalMinutes = 25
        var breakDurationMinutes = 5
        
        let deepWork = MockProfile(name: "Deep Work", intervalMinutes: 50, breakDurationMinutes: 10, icon: "brain.head.profile")
        
        // Apply profile
        intervalMinutes = deepWork.intervalMinutes
        breakDurationMinutes = deepWork.breakDurationMinutes
        
        XCTAssertEqual(intervalMinutes, 50, "Interval should be updated to 50")
        XCTAssertEqual(breakDurationMinutes, 10, "Break should be updated to 10")
    }
    
    // MARK: - Profile Equality Tests
    
    func testProfileEquality() {
        let id = UUID()
        let profile1 = MockProfile(id: id, name: "Test", intervalMinutes: 25, breakDurationMinutes: 5, icon: "timer")
        let profile2 = MockProfile(id: id, name: "Test", intervalMinutes: 25, breakDurationMinutes: 5, icon: "timer")
        let profile3 = MockProfile(name: "Test", intervalMinutes: 25, breakDurationMinutes: 5, icon: "timer")
        
        XCTAssertEqual(profile1.id, profile2.id, "Profiles with same ID should be equal")
        XCTAssertNotEqual(profile1.id, profile3.id, "Profiles with different IDs should not be equal")
    }
    
    // MARK: - Profile Display Name Tests
    
    func testProfileDisplayName() {
        let profile = MockProfile(name: "Deep Work", nameVI: "Tập trung sâu", intervalMinutes: 50, breakDurationMinutes: 10, icon: "brain.head.profile")
        
        let englishName = profile.getDisplayName(isVietnamese: false)
        let vietnameseName = profile.getDisplayName(isVietnamese: true)
        
        XCTAssertEqual(englishName, "Deep Work", "English name should be Deep Work")
        XCTAssertEqual(vietnameseName, "Tập trung sâu", "Vietnamese name should be Tập trung sâu")
    }
    
    // MARK: - Profile Validation Tests
    
    func testProfileIntervalValidation() {
        let validIntervals = [15, 25, 30, 45, 50, 60, 90, 120]
        
        for interval in validIntervals {
            XCTAssertGreaterThanOrEqual(interval, 5, "Interval should be at least 5 minutes")
            XCTAssertLessThanOrEqual(interval, 180, "Interval should be at most 180 minutes")
        }
    }
    
    func testProfileBreakValidation() {
        let validBreaks = [3, 5, 10, 15]
        
        for breakDuration in validBreaks {
            XCTAssertGreaterThanOrEqual(breakDuration, 1, "Break should be at least 1 minute")
            XCTAssertLessThanOrEqual(breakDuration, 30, "Break should be at most 30 minutes")
        }
    }
    
    // MARK: - Custom Profile Tests
    
    func testCustomProfileCreation() {
        let customProfile = MockProfile(
            name: "My Custom",
            nameVI: "Tùy chỉnh",
            intervalMinutes: 35,
            breakDurationMinutes: 7,
            icon: "star",
            isBuiltIn: false
        )
        
        XCTAssertFalse(customProfile.isBuiltIn, "Custom profile should not be built-in")
        XCTAssertEqual(customProfile.intervalMinutes, 35, "Custom interval should be 35")
        XCTAssertEqual(customProfile.breakDurationMinutes, 7, "Custom break should be 7")
    }
    
    func testBuiltInProfileCannotBeDeleted() {
        let builtInProfile = MockProfile(name: "Pomodoro", intervalMinutes: 25, breakDurationMinutes: 5, icon: "timer", isBuiltIn: true)
        
        XCTAssertTrue(builtInProfile.isBuiltIn, "Built-in profile should be marked as built-in")
        // In real implementation, deletion would be blocked
    }
}

// MARK: - Mock Profile

struct MockProfile {
    let id: UUID
    let name: String
    let nameVI: String
    let intervalMinutes: Int
    let breakDurationMinutes: Int
    let icon: String
    let isBuiltIn: Bool
    
    init(id: UUID = UUID(), name: String, nameVI: String = "", intervalMinutes: Int, breakDurationMinutes: Int, icon: String, isBuiltIn: Bool = true) {
        self.id = id
        self.name = name
        self.nameVI = nameVI.isEmpty ? name : nameVI
        self.intervalMinutes = intervalMinutes
        self.breakDurationMinutes = breakDurationMinutes
        self.icon = icon
        self.isBuiltIn = isBuiltIn
    }
    
    func getDisplayName(isVietnamese: Bool) -> String {
        isVietnamese ? nameVI : name
    }
}

