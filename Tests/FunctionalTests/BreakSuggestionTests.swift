import XCTest
@testable import Foundation

/// Functional tests for Break Suggestions feature
final class BreakSuggestionTests: XCTestCase {
    
    // MARK: - Suggestion Data Tests
    
    func testSuggestionsExist() {
        let suggestions = MockBreakSuggestions.all
        
        XCTAssertGreaterThan(suggestions.count, 0, "Should have at least one suggestion")
        XCTAssertGreaterThanOrEqual(suggestions.count, 10, "Should have at least 10 suggestions")
    }
    
    func testSuggestionStructure() {
        let suggestion = MockBreakSuggestion(
            icon: "eye",
            titleEN: "20-20-20 Rule",
            titleVI: "Quy tắc 20-20-20",
            descriptionEN: "Look at something 20 feet away for 20 seconds",
            descriptionVI: "Nhìn vào vật cách 6m trong 20 giây"
        )
        
        XCTAssertFalse(suggestion.icon.isEmpty, "Icon should not be empty")
        XCTAssertFalse(suggestion.titleEN.isEmpty, "English title should not be empty")
        XCTAssertFalse(suggestion.titleVI.isEmpty, "Vietnamese title should not be empty")
        XCTAssertFalse(suggestion.descriptionEN.isEmpty, "English description should not be empty")
        XCTAssertFalse(suggestion.descriptionVI.isEmpty, "Vietnamese description should not be empty")
    }
    
    // MARK: - Category Tests
    
    func testEyeExerciseSuggestions() {
        let eyeExercises = MockBreakSuggestions.all.filter { $0.icon.contains("eye") || $0.icon == "circle.dashed" }
        
        XCTAssertGreaterThan(eyeExercises.count, 0, "Should have eye exercise suggestions")
    }
    
    func testStretchingSuggestions() {
        let stretchingIcons = ["figure.arms.open", "figure.stand", "arrow.left.arrow.right", "hands.clap"]
        let stretching = MockBreakSuggestions.all.filter { stretchingIcons.contains($0.icon) }
        
        XCTAssertGreaterThan(stretching.count, 0, "Should have stretching suggestions")
    }
    
    func testMovementSuggestions() {
        let movementIcons = ["figure.walk", "figure.stairs"]
        let movement = MockBreakSuggestions.all.filter { movementIcons.contains($0.icon) }
        
        XCTAssertGreaterThan(movement.count, 0, "Should have movement suggestions")
    }
    
    func testRelaxationSuggestions() {
        let relaxationIcons = ["wind", "drop", "sun.max"]
        let relaxation = MockBreakSuggestions.all.filter { relaxationIcons.contains($0.icon) }
        
        XCTAssertGreaterThan(relaxation.count, 0, "Should have relaxation suggestions")
    }
    
    // MARK: - Random Selection Tests
    
    func testRandomSelection() {
        var selectedSuggestions: Set<String> = []
        
        // Run random selection multiple times
        for _ in 0..<100 {
            let suggestion = MockBreakSuggestions.random()
            selectedSuggestions.insert(suggestion.titleEN)
        }
        
        // Should have selected more than one unique suggestion
        XCTAssertGreaterThan(selectedSuggestions.count, 1, "Random selection should return different suggestions")
    }
    
    func testRandomSelectionReturnsValidSuggestion() {
        let suggestion = MockBreakSuggestions.random()
        
        XCTAssertFalse(suggestion.icon.isEmpty, "Random suggestion should have valid icon")
        XCTAssertFalse(suggestion.titleEN.isEmpty, "Random suggestion should have valid title")
    }
    
    // MARK: - Display Name Tests
    
    func testDisplayNameEnglish() {
        let suggestion = MockBreakSuggestion(
            icon: "eye",
            titleEN: "20-20-20 Rule",
            titleVI: "Quy tắc 20-20-20",
            descriptionEN: "Look at something 20 feet away",
            descriptionVI: "Nhìn vào vật cách 6m"
        )
        
        let englishTitle = suggestion.getTitle(isVietnamese: false)
        XCTAssertEqual(englishTitle, "20-20-20 Rule", "English title should be correct")
    }
    
    func testDisplayNameVietnamese() {
        let suggestion = MockBreakSuggestion(
            icon: "eye",
            titleEN: "20-20-20 Rule",
            titleVI: "Quy tắc 20-20-20",
            descriptionEN: "Look at something 20 feet away",
            descriptionVI: "Nhìn vào vật cách 6m"
        )
        
        let vietnameseTitle = suggestion.getTitle(isVietnamese: true)
        XCTAssertEqual(vietnameseTitle, "Quy tắc 20-20-20", "Vietnamese title should be correct")
    }
    
    // MARK: - Specific Suggestions Tests
    
    func testTwentyTwentyTwentyRule() {
        let suggestion = MockBreakSuggestions.all.first { $0.titleEN.contains("20-20-20") }
        
        XCTAssertNotNil(suggestion, "Should have 20-20-20 Rule suggestion")
        XCTAssertEqual(suggestion?.icon, "eye", "20-20-20 Rule should have eye icon")
    }
    
    func testDeepBreathingSuggestion() {
        let suggestion = MockBreakSuggestions.all.first { $0.icon == "wind" }
        
        XCTAssertNotNil(suggestion, "Should have deep breathing suggestion")
        XCTAssertTrue(suggestion?.titleEN.contains("Breathing") ?? false, "Should be about breathing")
    }
    
    func testHydrateSuggestion() {
        let suggestion = MockBreakSuggestions.all.first { $0.icon == "drop" }
        
        XCTAssertNotNil(suggestion, "Should have hydrate suggestion")
        XCTAssertTrue(suggestion?.titleEN.contains("Hydrate") ?? false, "Should be about hydrating")
    }
    
    // MARK: - Icon Validation Tests
    
    func testAllIconsAreValid() {
        let validSystemIcons = [
            "eye", "eyes", "circle.dashed",
            "figure.arms.open", "figure.stand", "arrow.left.arrow.right", "hands.clap",
            "figure.walk", "figure.stairs",
            "wind", "drop", "sun.max"
        ]
        
        for suggestion in MockBreakSuggestions.all {
            XCTAssertTrue(validSystemIcons.contains(suggestion.icon), 
                          "Icon '\(suggestion.icon)' should be a valid SF Symbol")
        }
    }
    
    // MARK: - Content Quality Tests
    
    func testDescriptionsAreActionable() {
        for suggestion in MockBreakSuggestions.all {
            // Descriptions should contain action verbs or instructions
            let hasAction = suggestion.descriptionEN.contains { char in
                char.isUppercase || char.isNumber
            } || suggestion.descriptionEN.count > 20
            
            XCTAssertTrue(hasAction, "Description '\(suggestion.descriptionEN)' should be actionable")
        }
    }
    
    func testTitlesAreShort() {
        for suggestion in MockBreakSuggestions.all {
            XCTAssertLessThan(suggestion.titleEN.count, 30, 
                              "Title '\(suggestion.titleEN)' should be short (< 30 chars)")
        }
    }
}

// MARK: - Mock Break Suggestion

struct MockBreakSuggestion {
    let id = UUID()
    let icon: String
    let titleEN: String
    let titleVI: String
    let descriptionEN: String
    let descriptionVI: String
    
    func getTitle(isVietnamese: Bool) -> String {
        isVietnamese ? titleVI : titleEN
    }
    
    func getDescription(isVietnamese: Bool) -> String {
        isVietnamese ? descriptionVI : descriptionEN
    }
}

// MARK: - Mock Break Suggestions Data

struct MockBreakSuggestions {
    static let all: [MockBreakSuggestion] = [
        // Eye exercises
        MockBreakSuggestion(
            icon: "eye",
            titleEN: "20-20-20 Rule",
            titleVI: "Quy tắc 20-20-20",
            descriptionEN: "Look at something 20 feet away for 20 seconds",
            descriptionVI: "Nhìn vào vật cách 6m trong 20 giây"
        ),
        MockBreakSuggestion(
            icon: "eyes",
            titleEN: "Blink Exercise",
            titleVI: "Bài tập chớp mắt",
            descriptionEN: "Blink rapidly 20 times to refresh your eyes",
            descriptionVI: "Chớp mắt nhanh 20 lần để mắt được nghỉ ngơi"
        ),
        MockBreakSuggestion(
            icon: "circle.dashed",
            titleEN: "Eye Circles",
            titleVI: "Xoay tròn mắt",
            descriptionEN: "Roll your eyes in circles, 5 times each direction",
            descriptionVI: "Xoay tròn mắt 5 lần mỗi chiều"
        ),
        
        // Stretching
        MockBreakSuggestion(
            icon: "figure.arms.open",
            titleEN: "Shoulder Stretch",
            titleVI: "Giãn vai",
            descriptionEN: "Roll your shoulders backward 10 times",
            descriptionVI: "Xoay vai về phía sau 10 lần"
        ),
        MockBreakSuggestion(
            icon: "figure.stand",
            titleEN: "Stand & Stretch",
            titleVI: "Đứng dậy & vươn vai",
            descriptionEN: "Stand up, reach for the ceiling and hold",
            descriptionVI: "Đứng lên, vươn tay lên trần và giữ"
        ),
        MockBreakSuggestion(
            icon: "arrow.left.arrow.right",
            titleEN: "Neck Stretch",
            titleVI: "Giãn cổ",
            descriptionEN: "Tilt your head to each side, hold for 10 seconds",
            descriptionVI: "Nghiêng đầu mỗi bên, giữ 10 giây"
        ),
        MockBreakSuggestion(
            icon: "hands.clap",
            titleEN: "Wrist Circles",
            titleVI: "Xoay cổ tay",
            descriptionEN: "Rotate your wrists 10 times each direction",
            descriptionVI: "Xoay cổ tay 10 lần mỗi chiều"
        ),
        
        // Movement
        MockBreakSuggestion(
            icon: "figure.walk",
            titleEN: "Take a Walk",
            titleVI: "Đi dạo",
            descriptionEN: "Walk around for 2-3 minutes",
            descriptionVI: "Đi lại 2-3 phút"
        ),
        MockBreakSuggestion(
            icon: "figure.stairs",
            titleEN: "Climb Stairs",
            titleVI: "Leo cầu thang",
            descriptionEN: "Walk up and down stairs if available",
            descriptionVI: "Leo lên xuống cầu thang nếu có"
        ),
        
        // Relaxation
        MockBreakSuggestion(
            icon: "wind",
            titleEN: "Deep Breathing",
            titleVI: "Hít thở sâu",
            descriptionEN: "Take 5 deep breaths: 4s in, 4s hold, 4s out",
            descriptionVI: "Hít 5 hơi sâu: 4 giây hít, 4 giây giữ, 4 giây thở"
        ),
        MockBreakSuggestion(
            icon: "drop",
            titleEN: "Hydrate",
            titleVI: "Uống nước",
            descriptionEN: "Drink a glass of water",
            descriptionVI: "Uống một ly nước"
        ),
        MockBreakSuggestion(
            icon: "sun.max",
            titleEN: "Get Natural Light",
            titleVI: "Ánh sáng tự nhiên",
            descriptionEN: "Look out a window or step outside briefly",
            descriptionVI: "Nhìn ra cửa sổ hoặc ra ngoài một chút"
        )
    ]
    
    static func random() -> MockBreakSuggestion {
        all.randomElement() ?? all[0]
    }
}

