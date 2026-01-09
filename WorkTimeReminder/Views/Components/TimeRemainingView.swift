import SwiftUI

// MARK: - Time Remaining View
struct TimeRemainingView: View {
    let targetDate: Date
    @State private var timeRemaining: String = ""
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Text(timeRemaining)
            .font(.system(size: 18, weight: .bold, design: .monospaced))
            .foregroundColor(.primary)
            .onReceive(timer) { _ in
                updateTime()
            }
            .onAppear {
                updateTime()
            }
    }
    
    private func updateTime() {
        let remaining = targetDate.timeIntervalSinceNow
        if remaining > 0 {
            let minutes = Int(remaining) / 60
            let seconds = Int(remaining) % 60
            timeRemaining = String(format: "%02d:%02d", minutes, seconds)
        } else {
            timeRemaining = "00:00"
        }
    }
}

