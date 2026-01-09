import SwiftUI
import UserNotifications
import IOKit.pwr_mgt

// MARK: - App Delegate
class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    
    // MARK: - Properties
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    var timer: Timer?
    var displayTimer: Timer?
    var reminderManager = ReminderManager.shared
    var shouldTerminate = false
    var screenLockTime: Date?
    var powerAssertionID: IOPMAssertionID = 0
    var isPowerAssertionActive = false
    
    // MARK: - App Lifecycle
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
    
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        if shouldTerminate {
            return .terminateNow
        }
        return .terminateCancel
    }
    
    func quitApp() {
        shouldTerminate = true
        NSApp.terminate(nil)
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBar()
        setupNotifications()
        setupTimers()
        setupScreenLockMonitoring()
        setupKeepAwakeObserver()
        updatePowerAssertion()
    }
    
    // MARK: - Setup Methods
    
    private func setupNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            if granted {
                print("Notification permission granted")
            }
        }
        UNUserNotificationCenter.current().delegate = self
    }
    
    private func setupTimers() {
        if reminderManager.isEnabled {
            startTimer()
        }
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
    
    // MARK: - Timer Management
    
    func startTimer() {
        stopTimer()
        let interval = TimeInterval(reminderManager.intervalMinutes * 60)
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.triggerReminder()
        }
        reminderManager.nextReminderDate = Date().addingTimeInterval(interval)
        updatePowerAssertion()
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        reminderManager.nextReminderDate = nil
        updateStatusBarDisplay()
        updatePowerAssertion()
    }
    
    func startDisplayTimer() {
        displayTimer?.invalidate()
        displayTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.updateStatusBarDisplay()
        }
    }
    
    // MARK: - Reminder Actions
    
    func triggerReminder() {
        sendNotification()
        
        if reminderManager.enableOverlay {
            BreakOverlayController.shared.showOverlay()
        }
        
        if reminderManager.enableScreenSaver {
            activateScreenSaver()
        }
        
        let interval = TimeInterval(reminderManager.intervalMinutes * 60)
        reminderManager.nextReminderDate = Date().addingTimeInterval(interval)
    }
    
    func showOverlay() {
        BreakOverlayController.shared.showOverlay()
    }
    
    func sendNotification() {
        let l10n = L10n.shared
        let content = UNMutableNotificationContent()
        content.title = l10n.notificationTitle
        content.body = l10n.notificationBody(minutes: reminderManager.intervalMinutes)
        
        if reminderManager.enableSound {
            content.sound = reminderManager.notificationSound.unSound
        }
        
        content.categoryIdentifier = "BREAK_REMINDER"
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
        
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
    
    // MARK: - Popover
    
    @objc func togglePopover() {
        if let button = statusItem?.button {
            if popover?.isShown == true {
                popover?.performClose(nil)
            } else {
                popover?.contentViewController = NSHostingController(rootView: ContentView(appDelegate: self))
                popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                popover?.contentViewController?.view.window?.makeKey()
            }
        }
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}

// MARK: - Status Bar Icon
extension AppDelegate {
    
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
            
            let bgPath = NSBezierPath(ovalIn: NSRect(
                x: center.x - radius,
                y: center.y - radius,
                width: radius * 2,
                height: radius * 2
            ))
            
            switch state {
            case .paused:
                self.drawPausedIcon(bgPath: bgPath, center: center, lineWidth: lineWidth)
                
            case .warning:
                self.drawWarningIcon(bgPath: bgPath, center: center, radius: radius, lineWidth: lineWidth, progress: progress)
                
            case .urgent:
                self.drawUrgentIcon(bgPath: bgPath, center: center, lineWidth: lineWidth)
                
            case .normal:
                self.drawNormalIcon(bgPath: bgPath, center: center, radius: radius, lineWidth: lineWidth, progress: progress)
            }
            
            return true
        }
        
        image.isTemplate = false
        return image
    }
    
    private func drawPausedIcon(bgPath: NSBezierPath, center: NSPoint, lineWidth: CGFloat) {
        NSColor.systemGray.withAlphaComponent(0.3).setFill()
        bgPath.fill()
        NSColor.systemGray.setStroke()
        bgPath.lineWidth = lineWidth
        bgPath.stroke()
        
        let pauseWidth: CGFloat = 2
        let pauseHeight: CGFloat = 6
        let pauseGap: CGFloat = 2.5
        
        NSColor.systemGray.setFill()
        NSRect(x: center.x - pauseGap - pauseWidth/2, y: center.y - pauseHeight/2, width: pauseWidth, height: pauseHeight).fill()
        NSRect(x: center.x + pauseGap - pauseWidth/2, y: center.y - pauseHeight/2, width: pauseWidth, height: pauseHeight).fill()
    }
    
    private func drawWarningIcon(bgPath: NSBezierPath, center: NSPoint, radius: CGFloat, lineWidth: CGFloat, progress: CGFloat) {
        NSColor.systemOrange.withAlphaComponent(0.2).setFill()
        bgPath.fill()
        NSColor.systemOrange.setStroke()
        bgPath.lineWidth = lineWidth
        bgPath.stroke()
        
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
        
        drawClockHands(at: center, radius: radius - 2, color: NSColor.systemOrange)
    }
    
    private func drawUrgentIcon(bgPath: NSBezierPath, center: NSPoint, lineWidth: CGFloat) {
        NSColor.systemRed.withAlphaComponent(0.3).setFill()
        bgPath.fill()
        NSColor.systemRed.setStroke()
        bgPath.lineWidth = lineWidth
        bgPath.stroke()
        
        let exclamationPath = NSBezierPath()
        exclamationPath.move(to: NSPoint(x: center.x, y: center.y + 4))
        exclamationPath.line(to: NSPoint(x: center.x, y: center.y - 1))
        NSColor.systemRed.setStroke()
        exclamationPath.lineWidth = 2
        exclamationPath.lineCapStyle = .round
        exclamationPath.stroke()
        
        let dotPath = NSBezierPath(ovalIn: NSRect(x: center.x - 1.2, y: center.y - 5, width: 2.4, height: 2.4))
        NSColor.systemRed.setFill()
        dotPath.fill()
    }
    
    private func drawNormalIcon(bgPath: NSBezierPath, center: NSPoint, radius: CGFloat, lineWidth: CGFloat, progress: CGFloat) {
        NSColor.systemTeal.withAlphaComponent(0.15).setFill()
        bgPath.fill()
        NSColor.systemTeal.setStroke()
        bgPath.lineWidth = lineWidth
        bgPath.stroke()
        
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
        
        drawClockHands(at: center, radius: radius - 2, color: NSColor.systemTeal)
    }
    
    private func drawClockHands(at center: NSPoint, radius: CGFloat, color: NSColor) {
        let hourPath = NSBezierPath()
        hourPath.move(to: center)
        hourPath.line(to: NSPoint(x: center.x, y: center.y + radius * 0.5))
        color.setStroke()
        hourPath.lineWidth = 1.5
        hourPath.lineCapStyle = .round
        hourPath.stroke()
        
        let minutePath = NSBezierPath()
        minutePath.move(to: center)
        minutePath.line(to: NSPoint(x: center.x + radius * 0.6, y: center.y))
        color.setStroke()
        minutePath.lineWidth = 1.2
        minutePath.lineCapStyle = .round
        minutePath.stroke()
        
        let dotPath = NSBezierPath(ovalIn: NSRect(x: center.x - 1.5, y: center.y - 1.5, width: 3, height: 3))
        color.setFill()
        dotPath.fill()
    }
    
    func updateStatusBarDisplay() {
        guard let button = statusItem?.button else { return }
        
        if !reminderManager.isEnabled {
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
            
            if minutes < 1 {
                button.image = createStatusBarIcon(state: .urgent, progress: progress)
            } else if minutes < 5 {
                button.image = createStatusBarIcon(state: .warning, progress: progress)
            } else {
                button.image = createStatusBarIcon(state: .normal, progress: progress)
            }
            button.contentTintColor = nil
            
            if minutes >= 60 {
                let hours = minutes / 60
                let mins = minutes % 60
                button.title = String(format: " %d:%02d:%02d", hours, mins, seconds)
            } else {
                button.title = String(format: " %02d:%02d", minutes, seconds)
            }
            
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
}

// MARK: - Screen Lock Monitoring
extension AppDelegate {
    
    func setupScreenLockMonitoring() {
        let workspace = NSWorkspace.shared
        let notificationCenter = workspace.notificationCenter
        
        notificationCenter.addObserver(
            self,
            selector: #selector(handleScreenSleep),
            name: NSWorkspace.screensDidSleepNotification,
            object: nil
        )
        
        notificationCenter.addObserver(
            self,
            selector: #selector(handleScreenWake),
            name: NSWorkspace.screensDidWakeNotification,
            object: nil
        )
        
        notificationCenter.addObserver(
            self,
            selector: #selector(handleScreenSleep),
            name: NSWorkspace.sessionDidResignActiveNotification,
            object: nil
        )
        
        notificationCenter.addObserver(
            self,
            selector: #selector(handleScreenWake),
            name: NSWorkspace.sessionDidBecomeActiveNotification,
            object: nil
        )
        
        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(handleScreenSleep),
            name: NSNotification.Name("com.apple.screensaver.didstart"),
            object: nil
        )
        
        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(handleScreenWake),
            name: NSNotification.Name("com.apple.screensaver.didstop"),
            object: nil
        )
    }
    
    @objc func handleScreenSleep() {
        if screenLockTime == nil {
            screenLockTime = Date()
            print("Screen locked/sleep at: \(screenLockTime!)")
        }
    }
    
    @objc func handleScreenWake() {
        guard let lockTime = screenLockTime else { return }
        
        let awayDuration = Date().timeIntervalSince(lockTime)
        let breakDurationSeconds = TimeInterval(reminderManager.breakDurationMinutes * 60)
        
        print("Screen wake. Away for: \(Int(awayDuration)) seconds, break duration: \(Int(breakDurationSeconds)) seconds")
        
        screenLockTime = nil
        
        if reminderManager.autoResetOnScreenLock &&
           reminderManager.isEnabled &&
           awayDuration >= breakDurationSeconds {
            
            print("Auto resetting timer - user took a break of \(Int(awayDuration/60)) minutes")
            
            DispatchQueue.main.async { [weak self] in
                self?.startTimer()
            }
        }
    }
}

// MARK: - Power Management (Keep Awake)
extension AppDelegate {
    
    func setupKeepAwakeObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeepAwakeChanged),
            name: .keepAwakeChanged,
            object: nil
        )
    }
    
    @objc func handleKeepAwakeChanged() {
        updatePowerAssertion()
    }
    
    func updatePowerAssertion() {
        let shouldKeepAwake = reminderManager.keepAwake && reminderManager.isEnabled
        
        if shouldKeepAwake && !isPowerAssertionActive {
            let reasonForActivity = "Work Time Reminder - Keeping display awake during work session" as CFString
            let result = IOPMAssertionCreateWithName(
                kIOPMAssertionTypePreventUserIdleDisplaySleep as CFString,
                IOPMAssertionLevel(kIOPMAssertionLevelOn),
                reasonForActivity,
                &powerAssertionID
            )
            
            if result == kIOReturnSuccess {
                isPowerAssertionActive = true
                print("Power assertion created - display will stay awake")
            } else {
                print("Failed to create power assertion")
            }
        } else if !shouldKeepAwake && isPowerAssertionActive {
            let result = IOPMAssertionRelease(powerAssertionID)
            if result == kIOReturnSuccess {
                isPowerAssertionActive = false
                powerAssertionID = 0
                print("Power assertion released - display can sleep normally")
            }
        }
    }
}

