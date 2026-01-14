import Foundation
import ServiceManagement

// MARK: - Launch at Login Manager
/// Manages the app's ability to launch at system login
class LaunchAtLoginManager: ObservableObject {
    
    static let shared = LaunchAtLoginManager()
    
    @Published var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: "launchAtLogin")
            updateLoginItem()
        }
    }
    
    private init() {
        self.isEnabled = UserDefaults.standard.bool(forKey: "launchAtLogin")
        
        // Sync with system state on init
        if #available(macOS 13.0, *) {
            syncWithSystemState()
        }
    }
    
    // MARK: - Public Methods
    
    func toggle() {
        isEnabled.toggle()
    }
    
    // MARK: - Private Methods
    
    private func updateLoginItem() {
        if #available(macOS 13.0, *) {
            updateLoginItemModern()
        } else {
            updateLoginItemLegacy()
        }
    }
    
    @available(macOS 13.0, *)
    private func updateLoginItemModern() {
        let service = SMAppService.mainApp
        
        do {
            if isEnabled {
                if service.status == .notRegistered || service.status == .notFound {
                    try service.register()
                }
            } else {
                if service.status == .enabled {
                    try service.unregister()
                }
            }
        } catch {
            print("Failed to update login item: \(error.localizedDescription)")
            // Revert the state if failed
            DispatchQueue.main.async {
                self.isEnabled = !self.isEnabled
            }
        }
    }
    
    @available(macOS 13.0, *)
    private func syncWithSystemState() {
        let service = SMAppService.mainApp
        let systemEnabled = service.status == .enabled
        
        if systemEnabled != isEnabled {
            // Update our state to match system
            DispatchQueue.main.async {
                self.isEnabled = systemEnabled
                UserDefaults.standard.set(systemEnabled, forKey: "launchAtLogin")
            }
        }
    }
    
    // Legacy method for macOS 12
    private func updateLoginItemLegacy() {
        guard let bundleIdentifier = Bundle.main.bundleIdentifier else { return }
        
        // Use SMLoginItemSetEnabled for older systems
        // Note: This requires a helper app bundle, which is complex
        // For simplicity, we'll just store the preference and show a message
        
        // Alternative: Use AppleScript or LaunchAgent
        if isEnabled {
            createLaunchAgent(bundleIdentifier: bundleIdentifier)
        } else {
            removeLaunchAgent(bundleIdentifier: bundleIdentifier)
        }
    }
    
    private func createLaunchAgent(bundleIdentifier: String) {
        guard let appPath = Bundle.main.bundlePath as String? else { return }
        
        let launchAgentDir = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/LaunchAgents")
        
        let plistPath = launchAgentDir.appendingPathComponent("\(bundleIdentifier).plist")
        
        let plistContent: [String: Any] = [
            "Label": bundleIdentifier,
            "ProgramArguments": [appPath + "/Contents/MacOS/WorkTimeReminder"],
            "RunAtLoad": true,
            "KeepAlive": false
        ]
        
        do {
            // Create directory if needed
            try FileManager.default.createDirectory(at: launchAgentDir, withIntermediateDirectories: true)
            
            // Write plist
            let data = try PropertyListSerialization.data(fromPropertyList: plistContent, format: .xml, options: 0)
            try data.write(to: plistPath)
        } catch {
            print("Failed to create launch agent: \(error.localizedDescription)")
        }
    }
    
    private func removeLaunchAgent(bundleIdentifier: String) {
        let plistPath = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/LaunchAgents/\(bundleIdentifier).plist")
        
        try? FileManager.default.removeItem(at: plistPath)
    }
    
    // MARK: - Status Check
    
    var statusDescription: String {
        if #available(macOS 13.0, *) {
            let service = SMAppService.mainApp
            switch service.status {
            case .enabled:
                return "Enabled"
            case .notRegistered:
                return "Not registered"
            case .requiresApproval:
                return "Requires approval in System Settings"
            case .notFound:
                return "Not found"
            @unknown default:
                return "Unknown"
            }
        } else {
            return isEnabled ? "Enabled (Legacy)" : "Disabled"
        }
    }
}
