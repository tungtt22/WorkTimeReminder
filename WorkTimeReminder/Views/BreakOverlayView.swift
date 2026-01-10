import SwiftUI
import AppKit

// MARK: - Break Overlay Controller
class BreakOverlayController {
    static let shared = BreakOverlayController()
    
    private var overlayWindows: [OverlayPanel] = []
    private var dismissTimer: Timer?
    private var eventMonitor: Any?
    
    private init() {}
    
    func showOverlay() {
        DispatchQueue.main.async { [weak self] in
            self?.showOverlayOnMainThread()
        }
    }
    
    private func showOverlayOnMainThread() {
        hideOverlayImmediately()
        
        for screen in NSScreen.screens {
            let panel = createOverlayPanel(for: screen)
            overlayWindows.append(panel)
            panel.orderFrontRegardless()
        }
        
        setupKeyMonitor()
        
        let duration = TimeInterval(ReminderManager.shared.overlayDurationSeconds)
        dismissTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
            self?.hideOverlay()
        }
    }
    
    private func setupKeyMonitor() {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
        
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.keyCode == 53 { // ESC key
                self?.hideOverlay()
                return nil
            }
            return event
        }
    }
    
    func hideOverlay() {
        DispatchQueue.main.async { [weak self] in
            self?.hideOverlayOnMainThread()
        }
    }
    
    func snoozeReminder() {
        hideOverlay()
        NotificationCenter.default.post(name: .snoozeRequested, object: nil)
    }
    
    private func hideOverlayOnMainThread() {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
        
        dismissTimer?.invalidate()
        dismissTimer = nil
        
        let windowsToClose = overlayWindows
        overlayWindows.removeAll()
        
        for panel in windowsToClose {
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.3
                panel.animator().alphaValue = 0
            }, completionHandler: {
                panel.orderOut(nil)
            })
        }
    }
    
    private func hideOverlayImmediately() {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
        
        dismissTimer?.invalidate()
        dismissTimer = nil
        
        for panel in overlayWindows {
            panel.orderOut(nil)
        }
        overlayWindows.removeAll()
    }
    
    private func createOverlayPanel(for screen: NSScreen) -> OverlayPanel {
        let panel = OverlayPanel(
            contentRect: screen.frame,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        
        panel.level = .screenSaver
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = false
        panel.ignoresMouseEvents = false
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        panel.alphaValue = 0
        panel.isReleasedWhenClosed = false
        panel.hidesOnDeactivate = false
        panel.becomesKeyOnlyIfNeeded = true
        
        let overlayView = BreakOverlayView(
            onDismiss: { [weak self] in
                self?.hideOverlay()
            },
            onSnooze: { [weak self] in
                self?.snoozeReminder()
            }
        )
        
        panel.contentView = NSHostingView(rootView: overlayView)
        
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.5
            panel.animator().alphaValue = 1
        })
        
        return panel
    }
}

// MARK: - Custom Panel
class OverlayPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
    
    override func close() {
        self.orderOut(nil)
    }
    
    override func performClose(_ sender: Any?) {
        self.orderOut(nil)
    }
}

// MARK: - Break Overlay View
struct BreakOverlayView: View {
    @ObservedObject var localization = LocalizationManager.shared
    @ObservedObject var reminderManager = ReminderManager.shared
    var onDismiss: () -> Void
    var onSnooze: (() -> Void)?
    
    @State private var animate = false
    @State private var countdown: Int = ReminderManager.shared.overlayDurationSeconds
    @State private var breakSuggestion: BreakSuggestion = BreakSuggestions.random()
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    private var l10n: L10n { L10n.shared }
    private var primaryColor: Color { reminderManager.overlayColor.primaryColor }
    private var secondaryColor: Color { reminderManager.overlayColor.secondaryColor }
    
    var body: some View {
        ZStack {
            backgroundView
            gradientOverlay
            contentView
        }
        .onAppear {
            animate = true
            countdown = ReminderManager.shared.overlayDurationSeconds
            breakSuggestion = BreakSuggestions.random()
        }
        .onReceive(timer) { _ in
            if countdown > 0 {
                countdown -= 1
            }
        }
    }
    
    // MARK: - Background
    private var backgroundView: some View {
        Color.black.opacity(0.9)
            .ignoresSafeArea()
            .contentShape(Rectangle())
            .onTapGesture {
                onDismiss()
            }
    }
    
    private var gradientOverlay: some View {
        RadialGradient(
            gradient: Gradient(colors: [
                primaryColor.opacity(0.4),
                secondaryColor.opacity(0.2),
                Color.clear
            ]),
            center: .center,
            startRadius: animate ? 100 : 200,
            endRadius: animate ? 400 : 600
        )
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animate)
    }
    
    // MARK: - Content
    private var contentView: some View {
        VStack(spacing: 30) {
            iconView
            messageView
            suggestionView
            countdownView
            buttonsView
            keyboardHint
        }
        .allowsHitTesting(true)
    }
    
    private var iconView: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [primaryColor, secondaryColor],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 100, height: 100)
                .shadow(color: primaryColor.opacity(0.5), radius: animate ? 30 : 20)
            
            Image(systemName: "cup.and.saucer.fill")
                .font(.system(size: 40))
                .foregroundColor(.white)
                .scaleEffect(animate ? 1.1 : 1.0)
        }
        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: animate)
    }
    
    private var messageView: some View {
        VStack(spacing: 16) {
            Text(l10n.breakTimeTitle)
                .font(.system(size: 60, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 10)
            
            Text(l10n.breakTimeSubtitle)
                .font(.system(size: 24, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Break Suggestion
    private var suggestionView: some View {
        HStack(spacing: 16) {
            Image(systemName: breakSuggestion.icon)
                .font(.system(size: 28))
                .foregroundColor(primaryColor)
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.1))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(breakSuggestion.title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(breakSuggestion.description)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
        )
        .padding(.horizontal, 40)
    }
    
    private var countdownView: some View {
        VStack(spacing: 6) {
            Text(l10n.closingIn)
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.6))
            
            Text("\(countdown)")
                .font(.system(size: 40, weight: .bold, design: .monospaced))
                .foregroundColor(primaryColor)
        }
    }
    
    // MARK: - Buttons
    private var buttonsView: some View {
        HStack(spacing: 20) {
            // Snooze button
            if let onSnooze = onSnooze {
                Button(action: onSnooze) {
                    HStack(spacing: 8) {
                        Image(systemName: "clock.arrow.circlepath")
                        Text(l10n.snoozeButton(minutes: reminderManager.snoozeDurationMinutes))
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 14)
                    .background(
                        Capsule()
                            .fill(primaryColor.opacity(0.3))
                            .overlay(
                                Capsule()
                                    .stroke(primaryColor.opacity(0.5), lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(.plain)
            }
            
            // Dismiss button
            Button(action: onDismiss) {
                HStack(spacing: 8) {
                    Image(systemName: "xmark.circle.fill")
                    Text(l10n.dismissButton)
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 28)
                .padding(.vertical, 14)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.15))
                        .overlay(
                            Capsule()
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                )
            }
            .buttonStyle(.plain)
        }
    }
    
    private var keyboardHint: some View {
        Text(l10n.pressEscToClose)
            .font(.system(size: 13))
            .foregroundColor(.white.opacity(0.4))
    }
}

