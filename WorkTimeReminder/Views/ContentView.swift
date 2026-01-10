import SwiftUI

// MARK: - Navigation State
enum AppScreen {
    case main
    case settings
    case statistics
    case schedule
    case profiles
}

// MARK: - Main Content View
struct ContentView: View {
    @ObservedObject var reminderManager = ReminderManager.shared
    @ObservedObject var localization = LocalizationManager.shared
    weak var appDelegate: AppDelegate?
    @State private var currentScreen: AppScreen = .main
    @State private var previousScreen: AppScreen = .main
    
    var body: some View {
        ZStack {
            // Main Screen
            MainScreenView(
                appDelegate: appDelegate,
                onSettingsTapped: { navigateTo(.settings) },
                onStatsTapped: { navigateTo(.statistics) },
                onProfilesTapped: { navigateTo(.profiles) }
            )
            .offset(x: offsetFor(.main))
            .opacity(currentScreen == .main ? 1 : 0)
            
            // Settings Screen
            SettingsScreenView(
                appDelegate: appDelegate,
                onBackTapped: { navigateTo(.main) },
                onScheduleTapped: { navigateTo(.schedule) }
            )
            .offset(x: offsetFor(.settings))
            .opacity(currentScreen == .settings ? 1 : 0)
            
            // Statistics Screen
            StatisticsView(onBack: { navigateTo(.main) })
                .offset(x: offsetFor(.statistics))
                .opacity(currentScreen == .statistics ? 1 : 0)
            
            // Schedule Screen
            ScheduleSettingsView(onBack: { navigateTo(.settings) })
                .offset(x: offsetFor(.schedule))
                .opacity(currentScreen == .schedule ? 1 : 0)
            
            // Profiles Screen
            ProfilesView(appDelegate: appDelegate, onBack: { navigateTo(.main) })
                .offset(x: offsetFor(.profiles))
                .opacity(currentScreen == .profiles ? 1 : 0)
        }
        .frame(width: 320, height: 420)
        .background(Color(NSColor.windowBackgroundColor))
        .clipped()
    }
    
    private func navigateTo(_ screen: AppScreen) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            previousScreen = currentScreen
            currentScreen = screen
        }
    }
    
    private func offsetFor(_ screen: AppScreen) -> CGFloat {
        if currentScreen == screen {
            return 0
        }
        
        // Determine direction based on screen hierarchy
        let hierarchy: [AppScreen] = [.main, .settings, .schedule, .statistics, .profiles]
        let currentIndex = hierarchy.firstIndex(of: currentScreen) ?? 0
        let screenIndex = hierarchy.firstIndex(of: screen) ?? 0
        
        return screenIndex < currentIndex ? -320 : 320
    }
}

#Preview {
    ContentView(appDelegate: nil)
}

