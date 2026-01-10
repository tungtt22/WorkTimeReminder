import Foundation

// MARK: - Work Schedule
class WorkSchedule: ObservableObject {
    static let shared = WorkSchedule()
    
    @Published var isScheduleEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isScheduleEnabled, forKey: "workScheduleEnabled")
        }
    }
    
    @Published var startHour: Int {
        didSet {
            UserDefaults.standard.set(startHour, forKey: "workStartHour")
        }
    }
    
    @Published var startMinute: Int {
        didSet {
            UserDefaults.standard.set(startMinute, forKey: "workStartMinute")
        }
    }
    
    @Published var endHour: Int {
        didSet {
            UserDefaults.standard.set(endHour, forKey: "workEndHour")
        }
    }
    
    @Published var endMinute: Int {
        didSet {
            UserDefaults.standard.set(endMinute, forKey: "workEndMinute")
        }
    }
    
    @Published var workDays: Set<Int> {  // 1 = Sunday, 2 = Monday, ..., 7 = Saturday
        didSet {
            UserDefaults.standard.set(Array(workDays), forKey: "workDays")
        }
    }
    
    private init() {
        self.isScheduleEnabled = UserDefaults.standard.object(forKey: "workScheduleEnabled") as? Bool ?? false
        self.startHour = UserDefaults.standard.object(forKey: "workStartHour") as? Int ?? 8
        self.startMinute = UserDefaults.standard.object(forKey: "workStartMinute") as? Int ?? 0
        self.endHour = UserDefaults.standard.object(forKey: "workEndHour") as? Int ?? 18
        self.endMinute = UserDefaults.standard.object(forKey: "workEndMinute") as? Int ?? 0
        
        if let savedDays = UserDefaults.standard.array(forKey: "workDays") as? [Int] {
            self.workDays = Set(savedDays)
        } else {
            // Default: Monday to Friday (2-6)
            self.workDays = Set([2, 3, 4, 5, 6])
        }
    }
    
    // MARK: - Computed Properties
    
    var startTimeString: String {
        String(format: "%02d:%02d", startHour, startMinute)
    }
    
    var endTimeString: String {
        String(format: "%02d:%02d", endHour, endMinute)
    }
    
    // MARK: - Methods
    
    func isWithinWorkHours() -> Bool {
        guard isScheduleEnabled else { return true }  // If schedule disabled, always return true
        
        let calendar = Calendar.current
        let now = Date()
        
        // Check day of week
        let weekday = calendar.component(.weekday, from: now)
        guard workDays.contains(weekday) else { return false }
        
        // Check time
        let currentHour = calendar.component(.hour, from: now)
        let currentMinute = calendar.component(.minute, from: now)
        let currentTotalMinutes = currentHour * 60 + currentMinute
        
        let startTotalMinutes = startHour * 60 + startMinute
        let endTotalMinutes = endHour * 60 + endMinute
        
        return currentTotalMinutes >= startTotalMinutes && currentTotalMinutes < endTotalMinutes
    }
    
    func dayName(for weekday: Int) -> String {
        let isVietnamese = LocalizationManager.shared.currentLanguage == .vietnamese
        switch weekday {
        case 1: return isVietnamese ? "CN" : "Sun"
        case 2: return isVietnamese ? "T2" : "Mon"
        case 3: return isVietnamese ? "T3" : "Tue"
        case 4: return isVietnamese ? "T4" : "Wed"
        case 5: return isVietnamese ? "T5" : "Thu"
        case 6: return isVietnamese ? "T6" : "Fri"
        case 7: return isVietnamese ? "T7" : "Sat"
        default: return ""
        }
    }
}

