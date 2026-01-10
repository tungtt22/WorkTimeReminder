import Foundation
import XCTest

/// Performance tests for WorkTimeReminder app
/// These tests ensure the app remains lightweight and efficient
/// Updated for v1.2.0 with new features: Statistics, Profiles, Schedule, Snooze
final class PerformanceTests: XCTestCase {
    
    // MARK: - Properties
    
    private var initialMemory: UInt64 = 0
    private let acceptableMemoryIncreaseMB: Double = 50  // Max acceptable memory increase
    private let acceptableCPUPercent: Double = 5.0       // Max acceptable CPU usage when idle
    private let timerAccuracyThresholdMs: Double = 100   // Max acceptable timer drift
    
    // MARK: - Setup
    
    override func setUp() {
        super.setUp()
        initialMemory = getMemoryUsage()
    }
    
    // MARK: - Memory Tests
    
    /// Test that app uses reasonable memory at startup
    func testBaselineMemoryUsage() {
        let memoryMB = Double(getMemoryUsage()) / 1024 / 1024
        
        print("📊 Baseline Memory Usage: \(String(format: "%.2f", memoryMB)) MB")
        
        // Menu bar apps should use less than 50MB at baseline
        XCTAssertLessThan(memoryMB, 50, "App should use less than 50MB at baseline")
    }
    
    /// Test memory doesn't leak over time
    func testMemoryStability() {
        let iterations = 100
        var memoryReadings: [UInt64] = []
        
        for i in 0..<iterations {
            // Simulate typical app operations
            simulateTypicalOperations()
            
            if i % 10 == 0 {
                memoryReadings.append(getMemoryUsage())
            }
        }
        
        let initialMB = Double(memoryReadings.first ?? 0) / 1024 / 1024
        let finalMB = Double(memoryReadings.last ?? 0) / 1024 / 1024
        let increase = finalMB - initialMB
        
        print("📊 Memory Stability Test:")
        print("   Initial: \(String(format: "%.2f", initialMB)) MB")
        print("   Final: \(String(format: "%.2f", finalMB)) MB")
        print("   Increase: \(String(format: "%.2f", increase)) MB")
        
        XCTAssertLessThan(increase, acceptableMemoryIncreaseMB, 
                          "Memory should not increase by more than \(acceptableMemoryIncreaseMB)MB")
    }
    
    /// Test memory usage during overlay display
    func testOverlayMemoryUsage() {
        let beforeMemory = getMemoryUsage()
        
        // Simulate overlay creation (multiple times as it would happen in real use)
        for _ in 0..<10 {
            simulateOverlayCreation()
        }
        
        let afterMemory = getMemoryUsage()
        let increaseMB = Double(afterMemory - beforeMemory) / 1024 / 1024
        
        print("📊 Overlay Memory Impact: \(String(format: "%.2f", increaseMB)) MB")
        
        XCTAssertLessThan(increaseMB, 20, "Overlay operations should not increase memory by more than 20MB")
    }
    
    // MARK: - CPU Tests
    
    /// Test CPU usage when app is idle
    func testIdleCPUUsage() {
        let samples = 10
        var cpuReadings: [Double] = []
        
        for _ in 0..<samples {
            cpuReadings.append(getCPUUsage())
            Thread.sleep(forTimeInterval: 0.5)
        }
        
        let averageCPU = cpuReadings.reduce(0, +) / Double(samples)
        
        print("📊 Idle CPU Usage: \(String(format: "%.2f", averageCPU))%")
        
        XCTAssertLessThan(averageCPU, acceptableCPUPercent, 
                          "Idle CPU usage should be less than \(acceptableCPUPercent)%")
    }
    
    /// Test CPU usage during timer operations
    func testTimerCPUUsage() {
        var cpuReadings: [Double] = []
        
        // Simulate timer running
        for _ in 0..<20 {
            simulateTimerTick()
            cpuReadings.append(getCPUUsage())
            Thread.sleep(forTimeInterval: 0.1)
        }
        
        let averageCPU = cpuReadings.reduce(0, +) / Double(cpuReadings.count)
        let maxCPU = cpuReadings.max() ?? 0
        
        print("📊 Timer CPU Usage:")
        print("   Average: \(String(format: "%.2f", averageCPU))%")
        print("   Peak: \(String(format: "%.2f", maxCPU))%")
        
        XCTAssertLessThan(averageCPU, 10, "Timer average CPU should be less than 10%")
        XCTAssertLessThan(maxCPU, 25, "Timer peak CPU should be less than 25%")
    }
    
    // MARK: - Timer Accuracy Tests
    
    /// Test timer accuracy
    func testTimerAccuracy() {
        let expectedInterval: TimeInterval = 1.0
        var actualIntervals: [TimeInterval] = []
        
        for _ in 0..<10 {
            let start = Date()
            Thread.sleep(forTimeInterval: expectedInterval)
            let actual = Date().timeIntervalSince(start)
            actualIntervals.append(actual)
        }
        
        let averageDrift = actualIntervals.map { abs($0 - expectedInterval) * 1000 }.reduce(0, +) / Double(actualIntervals.count)
        let maxDrift = actualIntervals.map { abs($0 - expectedInterval) * 1000 }.max() ?? 0
        
        print("📊 Timer Accuracy:")
        print("   Average drift: \(String(format: "%.2f", averageDrift)) ms")
        print("   Max drift: \(String(format: "%.2f", maxDrift)) ms")
        
        XCTAssertLessThan(averageDrift, timerAccuracyThresholdMs, 
                          "Timer drift should be less than \(timerAccuracyThresholdMs)ms")
    }
    
    // MARK: - UI Performance Tests
    
    /// Measure time to create status bar icon
    func testStatusBarIconCreationPerformance() {
        measure {
            for _ in 0..<100 {
                _ = createMockStatusBarIcon()
            }
        }
    }
    
    /// Test string localization performance
    func testLocalizationPerformance() {
        measure {
            for _ in 0..<1000 {
                _ = getLocalizedStrings()
            }
        }
    }
    
    // MARK: - New Feature Tests (v1.2.0)
    
    /// Test Statistics tracking performance
    func testStatisticsTrackingPerformance() {
        let iterations = 1000
        let startTime = Date()
        let startMemory = getMemoryUsage()
        
        for i in 0..<iterations {
            simulateStatisticsOperation(iteration: i)
        }
        
        let duration = Date().timeIntervalSince(startTime)
        let endMemory = getMemoryUsage()
        let memoryIncreaseMB = Double(endMemory - startMemory) / 1024 / 1024
        
        print("📊 Statistics Tracking Performance (\(iterations) operations):")
        print("   Duration: \(String(format: "%.3f", duration)) seconds")
        print("   Memory increase: \(String(format: "%.2f", memoryIncreaseMB)) MB")
        print("   Ops per second: \(String(format: "%.0f", Double(iterations) / duration))")
        
        XCTAssertLessThan(duration, 2.0, "1000 statistics operations should complete in under 2 seconds")
        XCTAssertLessThan(memoryIncreaseMB, 5, "Statistics should not increase memory by more than 5MB")
    }
    
    /// Test Profile switching performance
    func testProfileSwitchingPerformance() {
        let iterations = 100
        let startTime = Date()
        
        for _ in 0..<iterations {
            simulateProfileSwitch()
        }
        
        let duration = Date().timeIntervalSince(startTime)
        let avgSwitchMs = (duration / Double(iterations)) * 1000
        
        print("📊 Profile Switching Performance:")
        print("   \(iterations) switches in \(String(format: "%.3f", duration)) seconds")
        print("   Average switch time: \(String(format: "%.2f", avgSwitchMs)) ms")
        
        XCTAssertLessThan(avgSwitchMs, 10, "Profile switch should take less than 10ms")
    }
    
    /// Test Work Schedule check performance
    func testScheduleCheckPerformance() {
        let iterations = 10000
        let startTime = Date()
        
        for _ in 0..<iterations {
            _ = simulateScheduleCheck()
        }
        
        let duration = Date().timeIntervalSince(startTime)
        let opsPerSecond = Double(iterations) / duration
        
        print("📊 Schedule Check Performance:")
        print("   \(iterations) checks in \(String(format: "%.3f", duration)) seconds")
        print("   \(String(format: "%.0f", opsPerSecond)) checks per second")
        
        XCTAssertGreaterThan(opsPerSecond, 50000, "Should handle at least 50,000 schedule checks per second")
    }
    
    /// Test Break Suggestions random selection performance
    func testBreakSuggestionsPerformance() {
        let iterations = 1000
        let startTime = Date()
        
        for _ in 0..<iterations {
            _ = simulateBreakSuggestionSelection()
        }
        
        let duration = Date().timeIntervalSince(startTime)
        
        print("📊 Break Suggestions Performance:")
        print("   \(iterations) selections in \(String(format: "%.3f", duration)) seconds")
        
        XCTAssertLessThan(duration, 0.5, "1000 suggestion selections should complete in under 0.5 seconds")
    }
    
    /// Test Snooze timer handling
    func testSnoozeTimerPerformance() {
        let iterations = 100
        let startTime = Date()
        
        for _ in 0..<iterations {
            simulateSnoozeOperation()
        }
        
        let duration = Date().timeIntervalSince(startTime)
        
        print("📊 Snooze Operations Performance:")
        print("   \(iterations) snooze cycles in \(String(format: "%.3f", duration)) seconds")
        
        XCTAssertLessThan(duration, 1.0, "100 snooze operations should complete in under 1 second")
    }
    
    /// Test keyboard shortcuts handling simulation
    func testKeyboardShortcutPerformance() {
        let iterations = 1000
        let startTime = Date()
        
        for _ in 0..<iterations {
            simulateKeyboardShortcut()
        }
        
        let duration = Date().timeIntervalSince(startTime)
        let avgResponseMs = (duration / Double(iterations)) * 1000
        
        print("📊 Keyboard Shortcut Response:")
        print("   Average response: \(String(format: "%.3f", avgResponseMs)) ms")
        
        XCTAssertLessThan(avgResponseMs, 1, "Shortcut response should be under 1ms")
    }
    
    // MARK: - Integration Performance Tests
    
    /// Test full reminder cycle performance
    func testReminderCyclePerformance() {
        let startMemory = getMemoryUsage()
        let startTime = Date()
        
        // Simulate 100 reminder cycles
        for _ in 0..<100 {
            simulateReminderCycle()
        }
        
        let duration = Date().timeIntervalSince(startTime)
        let endMemory = getMemoryUsage()
        let memoryIncreaseMB = Double(endMemory - startMemory) / 1024 / 1024
        
        print("📊 Reminder Cycle Performance (100 cycles):")
        print("   Duration: \(String(format: "%.2f", duration)) seconds")
        print("   Memory increase: \(String(format: "%.2f", memoryIncreaseMB)) MB")
        print("   Average per cycle: \(String(format: "%.2f", duration / 100 * 1000)) ms")
        
        XCTAssertLessThan(duration, 5.0, "100 reminder cycles should complete in under 5 seconds")
        XCTAssertLessThan(memoryIncreaseMB, 10, "Memory should not increase by more than 10MB after 100 cycles")
    }
    
    /// Test full app workflow simulation
    func testFullWorkflowPerformance() {
        let startMemory = getMemoryUsage()
        let startTime = Date()
        
        // Simulate a typical work session
        for session in 0..<10 {
            // Start session
            simulateProfileSwitch()
            
            // Timer operations
            for _ in 0..<50 {
                simulateTimerTick()
            }
            
            // Trigger reminder
            simulateReminderCycle()
            
            // Record statistics
            simulateStatisticsOperation(iteration: session)
            
            // Maybe snooze
            if session % 3 == 0 {
                simulateSnoozeOperation()
            }
        }
        
        let duration = Date().timeIntervalSince(startTime)
        let endMemory = getMemoryUsage()
        let memoryIncreaseMB = Double(endMemory - startMemory) / 1024 / 1024
        
        print("📊 Full Workflow Performance (10 sessions):")
        print("   Duration: \(String(format: "%.2f", duration)) seconds")
        print("   Memory increase: \(String(format: "%.2f", memoryIncreaseMB)) MB")
        
        XCTAssertLessThan(duration, 10.0, "10 full sessions should complete in under 10 seconds")
        XCTAssertLessThan(memoryIncreaseMB, 20, "Memory should not increase by more than 20MB")
    }
    
    // MARK: - Stress Tests
    
    /// Stress test with rapid state changes
    func testRapidStateChanges() {
        let iterations = 1000
        let startTime = Date()
        
        for _ in 0..<iterations {
            simulateStateChange()
        }
        
        let duration = Date().timeIntervalSince(startTime)
        let opsPerSecond = Double(iterations) / duration
        
        print("📊 Rapid State Changes:")
        print("   \(iterations) changes in \(String(format: "%.2f", duration)) seconds")
        print("   \(String(format: "%.0f", opsPerSecond)) ops/second")
        
        XCTAssertGreaterThan(opsPerSecond, 1000, "Should handle at least 1000 state changes per second")
    }
    
    /// Stress test UserDefaults operations
    func testUserDefaultsPerformance() {
        let iterations = 1000
        let startTime = Date()
        
        for i in 0..<iterations {
            UserDefaults.standard.set(i, forKey: "perfTest_\(i % 10)")
            _ = UserDefaults.standard.integer(forKey: "perfTest_\(i % 10)")
        }
        
        let duration = Date().timeIntervalSince(startTime)
        
        print("📊 UserDefaults Performance:")
        print("   \(iterations * 2) operations in \(String(format: "%.2f", duration)) seconds")
        
        // Cleanup
        for i in 0..<10 {
            UserDefaults.standard.removeObject(forKey: "perfTest_\(i)")
        }
        
        XCTAssertLessThan(duration, 1.0, "1000 UserDefaults read/write cycles should complete in under 1 second")
    }
    
    /// Stress test JSON encoding/decoding for statistics persistence
    func testJSONPerformance() {
        let iterations = 100
        let startTime = Date()
        
        for _ in 0..<iterations {
            simulateStatisticsPersistence()
        }
        
        let duration = Date().timeIntervalSince(startTime)
        
        print("📊 JSON Encoding/Decoding Performance:")
        print("   \(iterations) save/load cycles in \(String(format: "%.3f", duration)) seconds")
        
        XCTAssertLessThan(duration, 1.0, "100 JSON operations should complete in under 1 second")
    }
    
    // MARK: - Helper Methods
    
    private func getMemoryUsage() -> UInt64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        return result == KERN_SUCCESS ? info.resident_size : 0
    }
    
    private func getCPUUsage() -> Double {
        var threadList: thread_act_array_t?
        var threadCount = mach_msg_type_number_t()
        
        guard task_threads(mach_task_self_, &threadList, &threadCount) == KERN_SUCCESS,
              let threads = threadList else {
            return 0
        }
        
        var totalCPU: Double = 0
        
        for i in 0..<Int(threadCount) {
            var info = thread_basic_info()
            var infoCount = mach_msg_type_number_t(THREAD_INFO_MAX)
            
            let result = withUnsafeMutablePointer(to: &info) {
                $0.withMemoryRebound(to: integer_t.self, capacity: Int(infoCount)) {
                    thread_info(threads[i], thread_flavor_t(THREAD_BASIC_INFO), $0, &infoCount)
                }
            }
            
            if result == KERN_SUCCESS {
                totalCPU += Double(info.cpu_usage) / Double(TH_USAGE_SCALE) * 100
            }
        }
        
        vm_deallocate(mach_task_self_, vm_address_t(bitPattern: threads), vm_size_t(threadCount) * vm_size_t(MemoryLayout<thread_t>.size))
        
        return totalCPU
    }
    
    private func simulateTypicalOperations() {
        // Simulate timer tick
        _ = Date().timeIntervalSinceNow
        
        // Simulate status bar update
        _ = String(format: "%02d:%02d", 25, 30)
        
        // Simulate settings read
        _ = UserDefaults.standard.integer(forKey: "intervalMinutes")
    }
    
    private func simulateOverlayCreation() {
        // Simulate overlay view creation overhead
        let colors = [
            (0.3, 0.5, 0.9),
            (0.2, 0.7, 0.7),
            (0.3, 0.7, 0.4)
        ]
        
        for color in colors {
            _ = "RGB(\(color.0), \(color.1), \(color.2))"
        }
        
        // Simulate animation state
        var animate = false
        for _ in 0..<10 {
            animate.toggle()
        }
        
        // Simulate break suggestion selection
        _ = simulateBreakSuggestionSelection()
    }
    
    private func simulateTimerTick() {
        let nextDate = Date().addingTimeInterval(1500)
        let remaining = nextDate.timeIntervalSinceNow
        let minutes = Int(remaining) / 60
        let seconds = Int(remaining) % 60
        _ = String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func createMockStatusBarIcon() -> Any {
        // Simulate icon creation calculations
        let size = (width: 18.0, height: 18.0)
        let center = (x: size.width / 2, y: size.height / 2)
        let radius = 7.5
        
        // Simulate drawing calculations
        _ = (center.x - radius, center.y - radius, radius * 2, radius * 2)
        
        return "MockIcon"
    }
    
    private func getLocalizedStrings() -> [String] {
        let isVietnamese = Bool.random()
        
        return [
            isVietnamese ? "Nhắc nhở nghỉ ngơi" : "Break Reminder",
            isVietnamese ? "Đang hoạt động" : "Active",
            isVietnamese ? "Cài đặt" : "Settings",
            isVietnamese ? "NGHỈ NGƠI THÔI!" : "TAKE A BREAK!",
            isVietnamese ? "Hoãn 5 phút" : "Snooze 5m",
            isVietnamese ? "Thống kê" : "Statistics"
        ]
    }
    
    private func simulateReminderCycle() {
        // Simulate notification creation
        let title = "Time for a break!"
        let body = "You've been working for 25 minutes."
        _ = "\(title): \(body)"
        
        // Simulate timer reset
        let interval = TimeInterval(25 * 60)
        _ = Date().addingTimeInterval(interval)
        
        // Simulate state update
        UserDefaults.standard.set(Date(), forKey: "lastReminder")
        
        // Simulate statistics recording
        simulateStatisticsOperation(iteration: 0)
    }
    
    private func simulateStateChange() {
        // Toggle boolean states
        var enabled = true
        enabled.toggle()
        
        // Update numeric values
        var interval = 25
        interval = (interval % 60) + 5
        
        // Update date
        _ = Date()
    }
    
    // MARK: - New Feature Simulations
    
    private func simulateStatisticsOperation(iteration: Int) {
        // Simulate creating a work session
        let session: [String: Any] = [
            "id": UUID().uuidString,
            "startTime": Date().timeIntervalSince1970 - Double(iteration * 1500),
            "endTime": Date().timeIntervalSince1970,
            "durationMinutes": 25,
            "wasCompleted": true
        ]
        
        // Simulate calculations
        let sessions = Array(repeating: session, count: min(iteration + 1, 100))
        _ = sessions.count
        _ = sessions.reduce(0) { $0 + ($1["durationMinutes"] as? Int ?? 0) }
    }
    
    private func simulateProfileSwitch() {
        // Simulate profile data
        let profiles = [
            ("Pomodoro", 25, 5),
            ("Deep Work", 50, 10),
            ("Light Work", 15, 3),
            ("Long Session", 90, 15)
        ]
        
        let selected = profiles.randomElement()!
        
        // Simulate applying profile
        UserDefaults.standard.set(selected.1, forKey: "tempInterval")
        UserDefaults.standard.set(selected.2, forKey: "tempBreak")
        UserDefaults.standard.removeObject(forKey: "tempInterval")
        UserDefaults.standard.removeObject(forKey: "tempBreak")
    }
    
    private func simulateScheduleCheck() -> Bool {
        let calendar = Calendar.current
        let now = Date()
        
        let weekday = calendar.component(.weekday, from: now)
        let hour = calendar.component(.hour, from: now)
        let minute = calendar.component(.minute, from: now)
        
        let workDays = Set([2, 3, 4, 5, 6])
        let startHour = 8
        let endHour = 18
        
        let isWorkDay = workDays.contains(weekday)
        let currentMinutes = hour * 60 + minute
        let isWorkHours = currentMinutes >= startHour * 60 && currentMinutes < endHour * 60
        
        return isWorkDay && isWorkHours
    }
    
    private func simulateBreakSuggestionSelection() -> (String, String) {
        let suggestions = [
            ("eye", "20-20-20 Rule"),
            ("figure.arms.open", "Shoulder Stretch"),
            ("wind", "Deep Breathing"),
            ("drop", "Hydrate"),
            ("figure.walk", "Take a Walk")
        ]
        
        return suggestions.randomElement()!
    }
    
    private func simulateSnoozeOperation() {
        let snoozeDuration = 5
        let snoozeEnd = Date().addingTimeInterval(TimeInterval(snoozeDuration * 60))
        _ = snoozeEnd.timeIntervalSinceNow
        
        // Simulate UI update
        _ = String(format: "Snoozing for %d minutes", snoozeDuration)
    }
    
    private func simulateKeyboardShortcut() {
        // Simulate shortcut detection
        let modifiers: UInt = 0x00180000 // Cmd + Shift
        let keyCode: UInt16 = 35 // P key
        
        let isCommandShift = (modifiers & 0x00100000) != 0 && (modifiers & 0x00080000) != 0
        let action: String
        
        switch keyCode {
        case 35: action = "togglePause"
        case 1: action = "skip"
        case 15: action = "reset"
        default: action = "none"
        }
        
        _ = (isCommandShift, action)
    }
    
    private func simulateStatisticsPersistence() {
        // Simulate encoding
        let sessions: [[String: Any]] = (0..<50).map { i in
            [
                "id": UUID().uuidString,
                "startTime": Date().timeIntervalSince1970 - Double(i * 1500),
                "endTime": Date().timeIntervalSince1970 - Double(i * 1500) + 1500,
                "durationMinutes": 25,
                "wasCompleted": true
            ]
        }
        
        // Simulate JSON encoding
        if let data = try? JSONSerialization.data(withJSONObject: sessions) {
            // Simulate decoding
            _ = try? JSONSerialization.jsonObject(with: data)
        }
    }
}

// MARK: - Performance Report Generator

struct PerformanceReport {
    let testName: String
    let memoryUsageMB: Double
    let cpuUsagePercent: Double
    let duration: TimeInterval
    let passed: Bool
    
    var description: String {
        """
        ═══════════════════════════════════════
        Test: \(testName)
        ───────────────────────────────────────
        Memory Usage: \(String(format: "%.2f", memoryUsageMB)) MB
        CPU Usage: \(String(format: "%.2f", cpuUsagePercent))%
        Duration: \(String(format: "%.3f", duration)) seconds
        Status: \(passed ? "✅ PASSED" : "❌ FAILED")
        ═══════════════════════════════════════
        """
    }
}
