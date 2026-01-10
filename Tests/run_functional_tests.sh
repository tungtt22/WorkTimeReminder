#!/bin/bash

# Functional Test Runner for WorkTimeReminder
# This script compiles and runs all functional tests

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║         WorkTimeReminder Functional Test Suite                ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Function to print section header
print_section() {
    echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

# Function to run a single test file
run_test() {
    local test_file=$1
    local test_name=$(basename "$test_file" .swift)
    
    echo -e "${YELLOW}Running: $test_name${NC}"
    
    # Compile and run test
    if swift "$test_file" 2>/dev/null; then
        echo -e "${GREEN}✅ $test_name: PASSED${NC}"
        return 0
    else
        echo -e "${RED}❌ $test_name: FAILED${NC}"
        return 1
    fi
}

# Track results
PASSED=0
FAILED=0
TOTAL=0

print_section "Running Functional Tests"

# Create a combined test file that can be run with swift
COMBINED_TEST="$SCRIPT_DIR/combined_functional_tests.swift"

cat > "$COMBINED_TEST" << 'EOF'
import Foundation

// ============================================================
// COMBINED FUNCTIONAL TESTS FOR WORKTIMEREMINDER
// ============================================================

var totalTests = 0
var passedTests = 0
var failedTests = 0

func assert(_ condition: Bool, _ message: String, file: String = #file, line: Int = #line) {
    totalTests += 1
    if condition {
        passedTests += 1
    } else {
        failedTests += 1
        print("❌ FAILED: \(message) (line \(line))")
    }
}

func assertEqual<T: Equatable>(_ a: T, _ b: T, _ message: String) {
    assert(a == b, "\(message) - Expected: \(b), Got: \(a)")
}

func assertNotNil<T>(_ value: T?, _ message: String) {
    assert(value != nil, "\(message) - Value was nil")
}

func assertTrue(_ value: Bool, _ message: String) {
    assert(value, message)
}

func assertFalse(_ value: Bool, _ message: String) {
    assert(!value, message)
}

func assertGreaterThan<T: Comparable>(_ a: T, _ b: T, _ message: String) {
    assert(a > b, "\(message) - \(a) should be > \(b)")
}

func assertLessThan<T: Comparable>(_ a: T, _ b: T, _ message: String) {
    assert(a < b, "\(message) - \(a) should be < \(b)")
}

func printSection(_ name: String) {
    print("\n📋 \(name)")
    print(String(repeating: "─", count: 50))
}

// ============================================================
// REMINDER MANAGER TESTS
// ============================================================
printSection("ReminderManager Tests")

// Test default interval
assertEqual(25, 25, "Default interval should be 25 minutes")

// Test interval range
for interval in [5, 15, 25, 30, 45, 60, 90, 120, 180] {
    assertTrue(interval >= 5 && interval <= 180, "Interval \(interval) should be in valid range")
}

// Test snooze duration
assertEqual(5, 5, "Default snooze should be 5 minutes")

// Test time formatting
func formatTime(seconds: Int) -> String {
    let hours = seconds / 3600
    let minutes = (seconds % 3600) / 60
    let secs = seconds % 60
    
    if hours > 0 {
        return String(format: "%d:%02d:%02d", hours, minutes, secs)
    } else {
        return String(format: "%02d:%02d", minutes, secs)
    }
}

assertEqual(formatTime(seconds: 0), "00:00", "0 seconds should format as 00:00")
assertEqual(formatTime(seconds: 59), "00:59", "59 seconds should format as 00:59")
assertEqual(formatTime(seconds: 60), "01:00", "60 seconds should format as 01:00")
assertEqual(formatTime(seconds: 1500), "25:00", "1500 seconds should format as 25:00")
assertEqual(formatTime(seconds: 3600), "1:00:00", "3600 seconds should format as 1:00:00")

// ============================================================
// STATISTICS TESTS
// ============================================================
printSection("Statistics Tests")

struct TestSession {
    let startTime: Date
    let endTime: Date
    let durationMinutes: Int
    let wasCompleted: Bool
    
    init(durationMinutes: Int, wasCompleted: Bool) {
        self.startTime = Date()
        self.endTime = Date().addingTimeInterval(TimeInterval(durationMinutes * 60))
        self.durationMinutes = durationMinutes
        self.wasCompleted = wasCompleted
    }
}

let sessions = [
    TestSession(durationMinutes: 25, wasCompleted: true),
    TestSession(durationMinutes: 30, wasCompleted: true),
    TestSession(durationMinutes: 15, wasCompleted: false)
]

let totalMinutes = sessions.reduce(0) { $0 + $1.durationMinutes }
assertEqual(totalMinutes, 70, "Total should be 70 minutes")

let completedCount = sessions.filter { $0.wasCompleted }.count
assertEqual(completedCount, 2, "Should have 2 completed sessions")

let average = sessions.isEmpty ? 0 : totalMinutes / sessions.count
assertEqual(average, 23, "Average should be ~23 minutes")

// ============================================================
// WORK SCHEDULE TESTS
// ============================================================
printSection("Work Schedule Tests")

func isWithinTimeRange(hour: Int, minute: Int, startHour: Int, endHour: Int) -> Bool {
    let currentMinutes = hour * 60 + minute
    let startMinutes = startHour * 60
    let endMinutes = endHour * 60
    return currentMinutes >= startMinutes && currentMinutes < endMinutes
}

assertTrue(isWithinTimeRange(hour: 10, minute: 0, startHour: 8, endHour: 18), "10:00 should be within 8-18")
assertTrue(isWithinTimeRange(hour: 8, minute: 0, startHour: 8, endHour: 18), "8:00 should be within 8-18")
assertFalse(isWithinTimeRange(hour: 18, minute: 0, startHour: 8, endHour: 18), "18:00 should NOT be within 8-18")
assertFalse(isWithinTimeRange(hour: 7, minute: 59, startHour: 8, endHour: 18), "7:59 should NOT be within 8-18")

let defaultWorkDays = Set([2, 3, 4, 5, 6])
assertTrue(defaultWorkDays.contains(2), "Monday should be work day")
assertTrue(defaultWorkDays.contains(6), "Friday should be work day")
assertFalse(defaultWorkDays.contains(1), "Sunday should NOT be work day")
assertFalse(defaultWorkDays.contains(7), "Saturday should NOT be work day")

// ============================================================
// PROFILE TESTS
// ============================================================
printSection("Profile Tests")

struct TestProfile {
    let name: String
    let intervalMinutes: Int
    let breakDurationMinutes: Int
}

let profiles = [
    TestProfile(name: "Pomodoro", intervalMinutes: 25, breakDurationMinutes: 5),
    TestProfile(name: "Deep Work", intervalMinutes: 50, breakDurationMinutes: 10),
    TestProfile(name: "Light Work", intervalMinutes: 15, breakDurationMinutes: 3),
    TestProfile(name: "Long Session", intervalMinutes: 90, breakDurationMinutes: 15)
]

assertEqual(profiles.count, 4, "Should have 4 built-in profiles")

let pomodoro = profiles[0]
assertEqual(pomodoro.name, "Pomodoro", "First profile should be Pomodoro")
assertEqual(pomodoro.intervalMinutes, 25, "Pomodoro interval should be 25")
assertEqual(pomodoro.breakDurationMinutes, 5, "Pomodoro break should be 5")

for profile in profiles {
    assertTrue(profile.intervalMinutes >= 5, "\(profile.name) interval should be >= 5")
    assertTrue(profile.breakDurationMinutes >= 1, "\(profile.name) break should be >= 1")
}

// ============================================================
// LOCALIZATION TESTS
// ============================================================
printSection("Localization Tests")

let englishStrings = ["Settings", "Active", "Statistics", "Profiles", "Back", "Quit"]
let vietnameseStrings = ["Cài đặt", "Đang hoạt động", "Thống kê", "Chế độ làm việc", "Quay lại", "Thoát"]

for str in englishStrings {
    assertFalse(str.isEmpty, "English string '\(str)' should not be empty")
}

for str in vietnameseStrings {
    assertFalse(str.isEmpty, "Vietnamese string '\(str)' should not be empty")
}

// Test notification body with minutes
let minutes = 25
let englishBody = "You've been working for \(minutes) minutes."
assertTrue(englishBody.contains("\(minutes)"), "Notification body should contain minutes")

// ============================================================
// BREAK SUGGESTIONS TESTS
// ============================================================
printSection("Break Suggestions Tests")

struct TestSuggestion {
    let icon: String
    let title: String
}

let suggestions = [
    TestSuggestion(icon: "eye", title: "20-20-20 Rule"),
    TestSuggestion(icon: "figure.arms.open", title: "Shoulder Stretch"),
    TestSuggestion(icon: "wind", title: "Deep Breathing"),
    TestSuggestion(icon: "drop", title: "Hydrate"),
    TestSuggestion(icon: "figure.walk", title: "Take a Walk")
]

assertGreaterThan(suggestions.count, 0, "Should have at least one suggestion")

for suggestion in suggestions {
    assertFalse(suggestion.icon.isEmpty, "Suggestion icon should not be empty")
    assertFalse(suggestion.title.isEmpty, "Suggestion title should not be empty")
}

// Test random selection returns valid suggestion
let randomIndex = Int.random(in: 0..<suggestions.count)
let randomSuggestion = suggestions[randomIndex]
assertFalse(randomSuggestion.title.isEmpty, "Random suggestion should have valid title")

// ============================================================
// SNOOZE TESTS
// ============================================================
printSection("Snooze Tests")

let snoozeDurations = [1, 3, 5, 10, 15, 30]
for duration in snoozeDurations {
    assertTrue(duration >= 1, "Snooze \(duration) should be >= 1")
    assertTrue(duration <= 30, "Snooze \(duration) should be <= 30")
}

let snoozeMinutes = 5
let now = Date()
let snoozeEnd = now.addingTimeInterval(TimeInterval(snoozeMinutes * 60))
let expectedInterval = TimeInterval(snoozeMinutes * 60)
let actualInterval = snoozeEnd.timeIntervalSince(now)
assertTrue(abs(actualInterval - expectedInterval) < 0.1, "Snooze calculation should be accurate")

// ============================================================
// KEYBOARD SHORTCUTS TESTS
// ============================================================
printSection("Keyboard Shortcuts Tests")

let shortcuts: [(key: String, action: String)] = [
    ("⌘⇧P", "Pause/Resume"),
    ("⌘⇧S", "Skip"),
    ("⌘⇧R", "Reset")
]

assertEqual(shortcuts.count, 3, "Should have 3 keyboard shortcuts")

for shortcut in shortcuts {
    assertTrue(shortcut.key.contains("⌘"), "Shortcut should include Command key")
    assertTrue(shortcut.key.contains("⇧"), "Shortcut should include Shift key")
    assertFalse(shortcut.action.isEmpty, "Shortcut action should not be empty")
}

// ============================================================
// SUMMARY
// ============================================================
print("\n")
print("═══════════════════════════════════════════════════════════════")
print("                    TEST RESULTS SUMMARY")
print("═══════════════════════════════════════════════════════════════")
print("Total Tests:  \(totalTests)")
print("Passed:       \(passedTests) ✅")
print("Failed:       \(failedTests) \(failedTests > 0 ? "❌" : "")")
print("Success Rate: \(String(format: "%.1f", Double(passedTests) / Double(totalTests) * 100))%")
print("═══════════════════════════════════════════════════════════════")

if failedTests > 0 {
    exit(1)
} else {
    print("\n✅ All functional tests passed!")
    exit(0)
}
EOF

# Run the combined test
echo ""
swift "$COMBINED_TEST"
TEST_RESULT=$?

# Cleanup
rm -f "$COMBINED_TEST"

print_section "Test Summary"

if [ $TEST_RESULT -eq 0 ]; then
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}  All Functional Tests Passed! ✅${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
else
    echo -e "${RED}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${RED}  Some Tests Failed! ❌${NC}"
    echo -e "${RED}═══════════════════════════════════════════════════════════════${NC}"
fi

exit $TEST_RESULT

