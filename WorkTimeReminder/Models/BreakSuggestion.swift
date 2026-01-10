import Foundation

// MARK: - Break Suggestion
struct BreakSuggestion: Identifiable {
    let id = UUID()
    let icon: String
    let titleEN: String
    let titleVI: String
    let descriptionEN: String
    let descriptionVI: String
    
    var title: String {
        LocalizationManager.shared.currentLanguage == .vietnamese ? titleVI : titleEN
    }
    
    var description: String {
        LocalizationManager.shared.currentLanguage == .vietnamese ? descriptionVI : descriptionEN
    }
}

// MARK: - Break Suggestions Data
struct BreakSuggestions {
    static let all: [BreakSuggestion] = [
        // Eye exercises
        BreakSuggestion(
            icon: "eye",
            titleEN: "20-20-20 Rule",
            titleVI: "Quy tắc 20-20-20",
            descriptionEN: "Look at something 20 feet away for 20 seconds",
            descriptionVI: "Nhìn vào vật cách 6m trong 20 giây"
        ),
        BreakSuggestion(
            icon: "eyes",
            titleEN: "Blink Exercise",
            titleVI: "Bài tập chớp mắt",
            descriptionEN: "Blink rapidly 20 times to refresh your eyes",
            descriptionVI: "Chớp mắt nhanh 20 lần để mắt được nghỉ ngơi"
        ),
        BreakSuggestion(
            icon: "circle.dashed",
            titleEN: "Eye Circles",
            titleVI: "Xoay tròn mắt",
            descriptionEN: "Roll your eyes in circles, 5 times each direction",
            descriptionVI: "Xoay tròn mắt 5 lần mỗi chiều"
        ),
        
        // Stretching
        BreakSuggestion(
            icon: "figure.arms.open",
            titleEN: "Shoulder Stretch",
            titleVI: "Giãn vai",
            descriptionEN: "Roll your shoulders backward 10 times",
            descriptionVI: "Xoay vai về phía sau 10 lần"
        ),
        BreakSuggestion(
            icon: "figure.stand",
            titleEN: "Stand & Stretch",
            titleVI: "Đứng dậy & vươn vai",
            descriptionEN: "Stand up, reach for the ceiling and hold",
            descriptionVI: "Đứng lên, vươn tay lên trần và giữ"
        ),
        BreakSuggestion(
            icon: "arrow.left.arrow.right",
            titleEN: "Neck Stretch",
            titleVI: "Giãn cổ",
            descriptionEN: "Tilt your head to each side, hold for 10 seconds",
            descriptionVI: "Nghiêng đầu mỗi bên, giữ 10 giây"
        ),
        BreakSuggestion(
            icon: "hands.clap",
            titleEN: "Wrist Circles",
            titleVI: "Xoay cổ tay",
            descriptionEN: "Rotate your wrists 10 times each direction",
            descriptionVI: "Xoay cổ tay 10 lần mỗi chiều"
        ),
        
        // Movement
        BreakSuggestion(
            icon: "figure.walk",
            titleEN: "Take a Walk",
            titleVI: "Đi dạo",
            descriptionEN: "Walk around for 2-3 minutes",
            descriptionVI: "Đi lại 2-3 phút"
        ),
        BreakSuggestion(
            icon: "figure.stairs",
            titleEN: "Climb Stairs",
            titleVI: "Leo cầu thang",
            descriptionEN: "Walk up and down stairs if available",
            descriptionVI: "Leo lên xuống cầu thang nếu có"
        ),
        
        // Relaxation
        BreakSuggestion(
            icon: "wind",
            titleEN: "Deep Breathing",
            titleVI: "Hít thở sâu",
            descriptionEN: "Take 5 deep breaths: 4s in, 4s hold, 4s out",
            descriptionVI: "Hít 5 hơi sâu: 4 giây hít, 4 giây giữ, 4 giây thở"
        ),
        BreakSuggestion(
            icon: "drop",
            titleEN: "Hydrate",
            titleVI: "Uống nước",
            descriptionEN: "Drink a glass of water",
            descriptionVI: "Uống một ly nước"
        ),
        BreakSuggestion(
            icon: "sun.max",
            titleEN: "Get Natural Light",
            titleVI: "Ánh sáng tự nhiên",
            descriptionEN: "Look out a window or step outside briefly",
            descriptionVI: "Nhìn ra cửa sổ hoặc ra ngoài một chút"
        )
    ]
    
    static func random() -> BreakSuggestion {
        all.randomElement() ?? all[0]
    }
}

