import Foundation

// MARK: - Work Session
struct WorkSession: Codable, Identifiable {
    let id: UUID
    let startTime: Date
    let endTime: Date
    let durationMinutes: Int
    let wasCompleted: Bool  // true if timer ran full duration, false if skipped
    
    init(startTime: Date, endTime: Date, wasCompleted: Bool) {
        self.id = UUID()
        self.startTime = startTime
        self.endTime = endTime
        self.durationMinutes = Int(endTime.timeIntervalSince(startTime) / 60)
        self.wasCompleted = wasCompleted
    }
}

// MARK: - Statistics Manager
class StatisticsManager: ObservableObject {
    static let shared = StatisticsManager()
    
    @Published var sessions: [WorkSession] = []
    @Published var totalBreaksTaken: Int = 0
    @Published var currentSessionStart: Date?
    
    private let sessionsKey = "workSessions"
    private let breaksKey = "totalBreaksTaken"
    private let maxStoredSessions = 500  // Limit storage
    
    private init() {
        loadData()
    }
    
    // MARK: - Session Tracking
    
    func startSession() {
        currentSessionStart = Date()
    }
    
    func endSession(wasCompleted: Bool) {
        guard let startTime = currentSessionStart else { return }
        
        let session = WorkSession(
            startTime: startTime,
            endTime: Date(),
            wasCompleted: wasCompleted
        )
        
        sessions.append(session)
        
        // Trim old sessions if needed
        if sessions.count > maxStoredSessions {
            sessions = Array(sessions.suffix(maxStoredSessions))
        }
        
        if wasCompleted {
            totalBreaksTaken += 1
        }
        
        currentSessionStart = nil
        saveData()
    }
    
    func recordBreak() {
        totalBreaksTaken += 1
        saveData()
    }
    
    // MARK: - Computed Statistics
    
    var todaySessions: [WorkSession] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return sessions.filter { calendar.isDate($0.startTime, inSameDayAs: today) }
    }
    
    var thisWeekSessions: [WorkSession] {
        let calendar = Calendar.current
        guard let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) else {
            return []
        }
        return sessions.filter { $0.startTime >= weekStart }
    }
    
    var todayWorkMinutes: Int {
        todaySessions.reduce(0) { $0 + $1.durationMinutes }
    }
    
    var thisWeekWorkMinutes: Int {
        thisWeekSessions.reduce(0) { $0 + $1.durationMinutes }
    }
    
    var todayCompletedSessions: Int {
        todaySessions.filter { $0.wasCompleted }.count
    }
    
    var thisWeekCompletedSessions: Int {
        thisWeekSessions.filter { $0.wasCompleted }.count
    }
    
    var averageSessionMinutes: Int {
        guard !sessions.isEmpty else { return 0 }
        let total = sessions.reduce(0) { $0 + $1.durationMinutes }
        return total / sessions.count
    }
    
    var longestStreak: Int {
        // Calculate longest consecutive days with completed sessions
        let calendar = Calendar.current
        var streak = 0
        var maxStreak = 0
        var lastDate: Date?
        
        let completedSessions = sessions.filter { $0.wasCompleted }
            .sorted { $0.startTime < $1.startTime }
        
        for session in completedSessions {
            let sessionDay = calendar.startOfDay(for: session.startTime)
            
            if let last = lastDate {
                let lastDay = calendar.startOfDay(for: last)
                if let daysDiff = calendar.dateComponents([.day], from: lastDay, to: sessionDay).day {
                    if daysDiff == 1 {
                        streak += 1
                    } else if daysDiff > 1 {
                        streak = 1
                    }
                    // daysDiff == 0 means same day, keep streak
                }
            } else {
                streak = 1
            }
            
            lastDate = session.startTime
            maxStreak = max(maxStreak, streak)
        }
        
        return maxStreak
    }
    
    // MARK: - Persistence
    
    private func saveData() {
        if let encoded = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(encoded, forKey: sessionsKey)
        }
        UserDefaults.standard.set(totalBreaksTaken, forKey: breaksKey)
    }
    
    private func loadData() {
        if let data = UserDefaults.standard.data(forKey: sessionsKey),
           let decoded = try? JSONDecoder().decode([WorkSession].self, from: data) {
            sessions = decoded
        }
        totalBreaksTaken = UserDefaults.standard.integer(forKey: breaksKey)
    }
    
    func resetStatistics() {
        sessions.removeAll()
        totalBreaksTaken = 0
        currentSessionStart = nil
        saveData()
    }
}

