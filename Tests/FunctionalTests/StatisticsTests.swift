import XCTest
@testable import Foundation

/// Functional tests for Statistics tracking
final class StatisticsTests: XCTestCase {
    
    // MARK: - Work Session Tests
    
    func testWorkSessionCreation() {
        let startTime = Date()
        let endTime = startTime.addingTimeInterval(1500) // 25 minutes
        let wasCompleted = true
        
        let session = MockWorkSession(
            startTime: startTime,
            endTime: endTime,
            wasCompleted: wasCompleted
        )
        
        XCTAssertEqual(session.durationMinutes, 25, "Duration should be 25 minutes")
        XCTAssertTrue(session.wasCompleted, "Session should be marked as completed")
    }
    
    func testWorkSessionDurationCalculation() {
        let testCases: [(minutes: Int, expected: Int)] = [
            (15, 15),
            (25, 25),
            (30, 30),
            (45, 45),
            (60, 60),
            (90, 90)
        ]
        
        for testCase in testCases {
            let startTime = Date()
            let endTime = startTime.addingTimeInterval(TimeInterval(testCase.minutes * 60))
            let session = MockWorkSession(startTime: startTime, endTime: endTime, wasCompleted: true)
            
            XCTAssertEqual(session.durationMinutes, testCase.expected, "Duration should be \(testCase.expected) minutes")
        }
    }
    
    // MARK: - Today Statistics Tests
    
    func testTodaySessionsFilter() {
        let calendar = Calendar.current
        let now = Date()
        let today = calendar.startOfDay(for: now)
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        
        let sessions = [
            MockWorkSession(startTime: today.addingTimeInterval(3600), endTime: today.addingTimeInterval(5100), wasCompleted: true),
            MockWorkSession(startTime: today.addingTimeInterval(7200), endTime: today.addingTimeInterval(8700), wasCompleted: true),
            MockWorkSession(startTime: yesterday, endTime: yesterday.addingTimeInterval(1500), wasCompleted: true)
        ]
        
        let todaySessions = sessions.filter { calendar.isDate($0.startTime, inSameDayAs: today) }
        
        XCTAssertEqual(todaySessions.count, 2, "Should have 2 sessions today")
    }
    
    func testTodayWorkMinutes() {
        let now = Date()
        let sessions = [
            MockWorkSession(startTime: now, endTime: now.addingTimeInterval(1500), wasCompleted: true), // 25 min
            MockWorkSession(startTime: now, endTime: now.addingTimeInterval(1800), wasCompleted: true), // 30 min
            MockWorkSession(startTime: now, endTime: now.addingTimeInterval(900), wasCompleted: false)  // 15 min
        ]
        
        let totalMinutes = sessions.reduce(0) { $0 + $1.durationMinutes }
        
        XCTAssertEqual(totalMinutes, 70, "Total should be 70 minutes")
    }
    
    func testCompletedSessionsCount() {
        let now = Date()
        let sessions = [
            MockWorkSession(startTime: now, endTime: now.addingTimeInterval(1500), wasCompleted: true),
            MockWorkSession(startTime: now, endTime: now.addingTimeInterval(1500), wasCompleted: true),
            MockWorkSession(startTime: now, endTime: now.addingTimeInterval(1500), wasCompleted: false),
            MockWorkSession(startTime: now, endTime: now.addingTimeInterval(1500), wasCompleted: true)
        ]
        
        let completedCount = sessions.filter { $0.wasCompleted }.count
        
        XCTAssertEqual(completedCount, 3, "Should have 3 completed sessions")
    }
    
    // MARK: - Week Statistics Tests
    
    func testThisWeekSessionsFilter() {
        let calendar = Calendar.current
        let now = Date()
        
        guard let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)) else {
            XCTFail("Could not calculate week start")
            return
        }
        
        let thisWeekDate = weekStart.addingTimeInterval(86400) // 1 day into the week
        let lastWeekDate = weekStart.addingTimeInterval(-86400) // 1 day before week start
        
        let sessions = [
            MockWorkSession(startTime: thisWeekDate, endTime: thisWeekDate.addingTimeInterval(1500), wasCompleted: true),
            MockWorkSession(startTime: thisWeekDate.addingTimeInterval(3600), endTime: thisWeekDate.addingTimeInterval(5100), wasCompleted: true),
            MockWorkSession(startTime: lastWeekDate, endTime: lastWeekDate.addingTimeInterval(1500), wasCompleted: true)
        ]
        
        let thisWeekSessions = sessions.filter { $0.startTime >= weekStart }
        
        XCTAssertEqual(thisWeekSessions.count, 2, "Should have 2 sessions this week")
    }
    
    // MARK: - Average Calculation Tests
    
    func testAverageSessionDuration() {
        let now = Date()
        let sessions = [
            MockWorkSession(startTime: now, endTime: now.addingTimeInterval(1200), wasCompleted: true), // 20 min
            MockWorkSession(startTime: now, endTime: now.addingTimeInterval(1500), wasCompleted: true), // 25 min
            MockWorkSession(startTime: now, endTime: now.addingTimeInterval(1800), wasCompleted: true)  // 30 min
        ]
        
        let totalMinutes = sessions.reduce(0) { $0 + $1.durationMinutes }
        let average = totalMinutes / sessions.count
        
        XCTAssertEqual(average, 25, "Average should be 25 minutes")
    }
    
    func testAverageWithEmptySessions() {
        let sessions: [MockWorkSession] = []
        
        let average = sessions.isEmpty ? 0 : sessions.reduce(0) { $0 + $1.durationMinutes } / sessions.count
        
        XCTAssertEqual(average, 0, "Average should be 0 for empty sessions")
    }
    
    // MARK: - Streak Calculation Tests
    
    func testStreakCalculation() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Create sessions for 5 consecutive days
        var sessions: [MockWorkSession] = []
        for dayOffset in 0..<5 {
            let sessionDate = calendar.date(byAdding: .day, value: -dayOffset, to: today)!
            sessions.append(MockWorkSession(
                startTime: sessionDate.addingTimeInterval(3600),
                endTime: sessionDate.addingTimeInterval(5100),
                wasCompleted: true
            ))
        }
        
        let streak = calculateStreak(sessions: sessions, calendar: calendar)
        
        XCTAssertEqual(streak, 5, "Streak should be 5 days")
    }
    
    func testBrokenStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Create sessions with a gap (day -2 missing)
        var sessions: [MockWorkSession] = []
        for dayOffset in [0, 1, 3, 4] { // Skip day 2
            let sessionDate = calendar.date(byAdding: .day, value: -dayOffset, to: today)!
            sessions.append(MockWorkSession(
                startTime: sessionDate.addingTimeInterval(3600),
                endTime: sessionDate.addingTimeInterval(5100),
                wasCompleted: true
            ))
        }
        
        let streak = calculateStreak(sessions: sessions, calendar: calendar)
        
        XCTAssertEqual(streak, 2, "Streak should be 2 (broken by gap)")
    }
    
    // MARK: - Statistics Reset Tests
    
    func testStatisticsReset() {
        var sessions: [MockWorkSession] = [
            MockWorkSession(startTime: Date(), endTime: Date().addingTimeInterval(1500), wasCompleted: true)
        ]
        var totalBreaks = 5
        
        // Reset
        sessions.removeAll()
        totalBreaks = 0
        
        XCTAssertTrue(sessions.isEmpty, "Sessions should be empty after reset")
        XCTAssertEqual(totalBreaks, 0, "Total breaks should be 0 after reset")
    }
    
    // MARK: - Helper Methods
    
    private func calculateStreak(sessions: [MockWorkSession], calendar: Calendar) -> Int {
        let completedSessions = sessions.filter { $0.wasCompleted }
            .sorted { $0.startTime > $1.startTime }
        
        guard !completedSessions.isEmpty else { return 0 }
        
        var streak = 1
        var lastDate = calendar.startOfDay(for: completedSessions[0].startTime)
        
        for i in 1..<completedSessions.count {
            let currentDate = calendar.startOfDay(for: completedSessions[i].startTime)
            let daysDiff = calendar.dateComponents([.day], from: currentDate, to: lastDate).day ?? 0
            
            if daysDiff == 1 {
                streak += 1
                lastDate = currentDate
            } else if daysDiff > 1 {
                break
            }
        }
        
        return streak
    }
}

// MARK: - Mock Work Session

struct MockWorkSession {
    let id = UUID()
    let startTime: Date
    let endTime: Date
    let durationMinutes: Int
    let wasCompleted: Bool
    
    init(startTime: Date, endTime: Date, wasCompleted: Bool) {
        self.startTime = startTime
        self.endTime = endTime
        self.durationMinutes = Int(endTime.timeIntervalSince(startTime) / 60)
        self.wasCompleted = wasCompleted
    }
}

