import SwiftUI
import UserNotifications

@main
struct WorkTimeReminderApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    var timer: Timer?
    var displayTimer: Timer?  // Timer to update status bar display
    var reminderManager = ReminderManager.shared
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Request notification permission
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted")
            }
        }
        UNUserNotificationCenter.current().delegate = self
        
        // Setup menu bar
        setupMenuBar()
        
        // Start timer if enabled
        if reminderManager.isEnabled {
            startTimer()
        }
        
        // Start display timer to update status bar
        startDisplayTimer()
    }
    
    func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.image = createStatusBarIcon(state: .normal)
            button.imagePosition = .imageLeading
            button.action = #selector(togglePopover)
        }
        
        updateStatusBarDisplay()
        
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 320, height: 420)
        popover?.behavior = .transient
        popover?.contentViewController = NSHostingController(rootView: ContentView(appDelegate: self))
    }
    
    // MARK: - Custom Status Bar Icon
    enum IconState {
        case normal
        case warning
        case paused
        case urgent
    }
    
    func createStatusBarIcon(state: IconState, progress: CGFloat = 1.0) -> NSImage {
        let size = NSSize(width: 18, height: 18)
        let image = NSImage(size: size, flipped: false) { rect in
            NSGraphicsContext.current?.cgContext.setShouldAntialias(true)
            
            let center = NSPoint(x: rect.midX, y: rect.midY)
            let radius: CGFloat = 7.5
            let lineWidth: CGFloat = 1.5
            
            // Background circle
            let bgPath = NSBezierPath(ovalIn: NSRect(
                x: center.x - radius,
                y: center.y - radius,
                width: radius * 2,
                height: radius * 2
            ))
            
            switch state {
            case .paused:
                NSColor.systemGray.withAlphaComponent(0.3).setFill()
                bgPath.fill()
                NSColor.systemGray.setStroke()
                bgPath.lineWidth = lineWidth
                bgPath.stroke()
                
                // Pause icon
                let pauseWidth: CGFloat = 2
                let pauseHeight: CGFloat = 6
                let pauseGap: CGFloat = 2.5
                
                NSColor.systemGray.setFill()
                NSRect(x: center.x - pauseGap - pauseWidth/2, y: center.y - pauseHeight/2, width: pauseWidth, height: pauseHeight).fill()
                NSRect(x: center.x + pauseGap - pauseWidth/2, y: center.y - pauseHeight/2, width: pauseWidth, height: pauseHeight).fill()
                
            case .warning:
                // Orange gradient background
                NSColor.systemOrange.withAlphaComponent(0.2).setFill()
                bgPath.fill()
                NSColor.systemOrange.setStroke()
                bgPath.lineWidth = lineWidth
                bgPath.stroke()
                
                // Progress arc
                let progressPath = NSBezierPath()
                progressPath.appendArc(
                    withCenter: center,
                    radius: radius - lineWidth/2,
                    startAngle: 90,
                    endAngle: 90 - (360 * progress),
                    clockwise: true
                )
                NSColor.systemOrange.setStroke()
                progressPath.lineWidth = lineWidth + 0.5
                progressPath.stroke()
                
                // Clock hands
                self.drawClockHands(at: center, radius: radius - 2, color: NSColor.systemOrange)
                
            case .urgent:
                // Red pulsing background
                NSColor.systemRed.withAlphaComponent(0.3).setFill()
                bgPath.fill()
                NSColor.systemRed.setStroke()
                bgPath.lineWidth = lineWidth
                bgPath.stroke()
                
                // Exclamation mark
                let exclamationPath = NSBezierPath()
                exclamationPath.move(to: NSPoint(x: center.x, y: center.y + 4))
                exclamationPath.line(to: NSPoint(x: center.x, y: center.y - 1))
                NSColor.systemRed.setStroke()
                exclamationPath.lineWidth = 2
                exclamationPath.lineCapStyle = .round
                exclamationPath.stroke()
                
                // Dot
                let dotPath = NSBezierPath(ovalIn: NSRect(x: center.x - 1.2, y: center.y - 5, width: 2.4, height: 2.4))
                NSColor.systemRed.setFill()
                dotPath.fill()
                
            case .normal:
                // Beautiful teal/cyan gradient
                NSColor.systemTeal.withAlphaComponent(0.15).setFill()
                bgPath.fill()
                NSColor.systemTeal.setStroke()
                bgPath.lineWidth = lineWidth
                bgPath.stroke()
                
                // Progress arc
                if progress < 1.0 {
                    let progressPath = NSBezierPath()
                    progressPath.appendArc(
                        withCenter: center,
                        radius: radius - lineWidth/2,
                        startAngle: 90,
                        endAngle: 90 - (360 * progress),
                        clockwise: true
                    )
                    NSColor.systemTeal.setStroke()
                    progressPath.lineWidth = lineWidth + 0.5
                    progressPath.stroke()
                }
                
                // Clock hands
                self.drawClockHands(at: center, radius: radius - 2, color: NSColor.systemTeal)
            }
            
            return true
        }
        
        image.isTemplate = false
        return image
    }
    
    private func drawClockHands(at center: NSPoint, radius: CGFloat, color: NSColor) {
        // Hour hand (shorter)
        let hourPath = NSBezierPath()
        hourPath.move(to: center)
        hourPath.line(to: NSPoint(x: center.x, y: center.y + radius * 0.5))
        color.setStroke()
        hourPath.lineWidth = 1.5
        hourPath.lineCapStyle = .round
        hourPath.stroke()
        
        // Minute hand (longer)
        let minutePath = NSBezierPath()
        minutePath.move(to: center)
        minutePath.line(to: NSPoint(x: center.x + radius * 0.6, y: center.y))
        color.setStroke()
        minutePath.lineWidth = 1.2
        minutePath.lineCapStyle = .round
        minutePath.stroke()
        
        // Center dot
        let dotPath = NSBezierPath(ovalIn: NSRect(x: center.x - 1.5, y: center.y - 1.5, width: 3, height: 3))
        color.setFill()
        dotPath.fill()
    }
    
    func startDisplayTimer() {
        displayTimer?.invalidate()
        displayTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.updateStatusBarDisplay()
        }
    }
    
    func updateStatusBarDisplay() {
        guard let button = statusItem?.button else { return }
        
        if !reminderManager.isEnabled {
            // Show paused state
            button.image = createStatusBarIcon(state: .paused)
            button.title = ""
            button.contentTintColor = nil
            return
        }
        
        guard let nextDate = reminderManager.nextReminderDate else {
            button.image = createStatusBarIcon(state: .normal)
            button.title = ""
            button.contentTintColor = nil
            return
        }
        
        let remaining = nextDate.timeIntervalSinceNow
        let totalInterval = TimeInterval(reminderManager.intervalMinutes * 60)
        let progress = CGFloat(max(0, min(1, remaining / totalInterval)))
        
        if remaining > 0 {
            let minutes = Int(remaining) / 60
            let seconds = Int(remaining) % 60
            
            // Show different icon based on time remaining
            if minutes < 1 {
                button.image = createStatusBarIcon(state: .urgent, progress: progress)
            } else if minutes < 5 {
                button.image = createStatusBarIcon(state: .warning, progress: progress)
            } else {
                button.image = createStatusBarIcon(state: .normal, progress: progress)
            }
            button.contentTintColor = nil
            
            // Display time remaining with nicer formatting
            if minutes >= 60 {
                let hours = minutes / 60
                let mins = minutes % 60
                button.title = String(format: " %d:%02d:%02d", hours, mins, seconds)
            } else {
                button.title = String(format: " %02d:%02d", minutes, seconds)
            }
            
            // Style the title
            let attributes: [NSAttributedString.Key: Any] = [
                .font: NSFont.monospacedDigitSystemFont(ofSize: 12, weight: .medium),
                .foregroundColor: minutes < 1 ? NSColor.systemRed : (minutes < 5 ? NSColor.systemOrange : NSColor.labelColor)
            ]
            button.attributedTitle = NSAttributedString(string: button.title, attributes: attributes)
            
        } else {
            button.image = createStatusBarIcon(state: .urgent)
            button.title = " 00:00"
            let attributes: [NSAttributedString.Key: Any] = [
                .font: NSFont.monospacedDigitSystemFont(ofSize: 12, weight: .medium),
                .foregroundColor: NSColor.systemRed
            ]
            button.attributedTitle = NSAttributedString(string: button.title, attributes: attributes)
        }
    }
    
    @objc func togglePopover() {
        if let button = statusItem?.button {
            if popover?.isShown == true {
                popover?.performClose(nil)
            } else {
                popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                popover?.contentViewController?.view.window?.makeKey()
            }
        }
    }
    
    func startTimer() {
        stopTimer()
        let interval = TimeInterval(reminderManager.intervalMinutes * 60)
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.triggerReminder()
        }
        reminderManager.nextReminderDate = Date().addingTimeInterval(interval)
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        reminderManager.nextReminderDate = nil
        updateStatusBarDisplay()
    }
    
    func triggerReminder() {
        sendNotification()
        
        if reminderManager.enableScreenSaver {
            activateScreenSaver()
        }
        
        // Schedule next reminder
        let interval = TimeInterval(reminderManager.intervalMinutes * 60)
        reminderManager.nextReminderDate = Date().addingTimeInterval(interval)
    }
    
    func sendNotification() {
        let l10n = L10n.shared
        let content = UNMutableNotificationContent()
        content.title = l10n.notificationTitle
        content.body = l10n.notificationBody(minutes: reminderManager.intervalMinutes)
        
        // Set notification sound based on user preference
        if reminderManager.enableSound {
            content.sound = reminderManager.notificationSound.unSound
        }
        
        // Add category for interactive notifications
        content.categoryIdentifier = "BREAK_REMINDER"
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
        
        // Also play system sound for better attention
        if reminderManager.enableSound {
            reminderManager.playSound(reminderManager.notificationSound)
        }
    }
    
    func activateScreenSaver() {
        let task = Process()
        task.launchPath = "/usr/bin/open"
        task.arguments = ["-a", "ScreenSaverEngine"]
        try? task.run()
    }
    
    // Handle notification when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}

