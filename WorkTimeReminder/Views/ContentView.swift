import SwiftUI

// MARK: - Navigation State
enum AppScreen {
    case main
    case settings
}

// MARK: - Main Content View
struct ContentView: View {
    @ObservedObject var reminderManager = ReminderManager.shared
    @ObservedObject var localization = LocalizationManager.shared
    weak var appDelegate: AppDelegate?
    @State private var currentScreen: AppScreen = .main
    
    var body: some View {
        ZStack {
            MainScreenView(
                appDelegate: appDelegate,
                onSettingsTapped: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        currentScreen = .settings
                    }
                }
            )
            .offset(x: currentScreen == .main ? 0 : -320)
            .opacity(currentScreen == .main ? 1 : 0)
            
            SettingsScreenView(
                appDelegate: appDelegate,
                onBackTapped: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        currentScreen = .main
                    }
                }
            )
            .offset(x: currentScreen == .settings ? 0 : 320)
            .opacity(currentScreen == .settings ? 1 : 0)
        }
        .frame(width: 320, height: 420)
        .background(Color(NSColor.windowBackgroundColor))
        .clipped()
    }
}

#Preview {
    ContentView(appDelegate: nil)
}

