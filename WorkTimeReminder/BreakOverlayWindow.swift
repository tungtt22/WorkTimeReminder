import SwiftUI
import AppKit

// MARK: - Break Overlay Window Controller
class BreakOverlayController {
    static let shared = BreakOverlayController()
    
    private var overlayWindows: [OverlayPanel] = []
    private var dismissTimer: Timer?
    private var eventMonitor: Any?
    
    private init() {}
    
    func showOverlay() {
        // Run on main thread
        DispatchQueue.main.async { [weak self] in
            self?.showOverlayOnMainThread()
        }
    }
    
    private func showOverlayOnMainThread() {
        // Close any existing overlays
        hideOverlayImmediately()
        
        // Create overlay on all screens
        for screen in NSScreen.screens {
            let panel = createOverlayPanel(for: screen)
            overlayWindows.append(panel)
            panel.orderFrontRegardless()
        }
        
        // Setup ESC key monitor
        setupKeyMonitor()
        
        // Auto dismiss after the configured duration
        let duration = TimeInterval(ReminderManager.shared.overlayDurationSeconds)
        dismissTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
            self?.hideOverlay()
        }
    }
    
    private func setupKeyMonitor() {
        // Remove existing monitor
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
        
        // Add new monitor for ESC key
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
    
    private func hideOverlayOnMainThread() {
        // Remove key monitor
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
        
        dismissTimer?.invalidate()
        dismissTimer = nil
        
        // Fade out windows
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
        // Remove key monitor
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
        
        let overlayView = BreakOverlayView(onDismiss: { [weak self] in
            self?.hideOverlay()
        })
        
        panel.contentView = NSHostingView(rootView: overlayView)
        
        // Fade in animation
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.5
            panel.animator().alphaValue = 1
        })
        
        return panel
    }
}

// MARK: - Custom Panel that doesn't affect app lifecycle
class OverlayPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
    
    // Never close, just hide
    override func close() {
        self.orderOut(nil)
    }
    
    // Don't let this panel cause app termination
    override func performClose(_ sender: Any?) {
        self.orderOut(nil)
    }
}

// MARK: - Break Overlay SwiftUI View
struct BreakOverlayView: View {
    @ObservedObject var localization = LocalizationManager.shared
    var onDismiss: () -> Void
    
    @State private var animate = false
    @State private var countdown: Int = ReminderManager.shared.overlayDurationSeconds
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    private var l10n: L10n { L10n.shared }
    
    var body: some View {
        ZStack {
            // Dark background - clicking dismisses
            Color.black.opacity(0.85)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    onDismiss()
                }
            
            // Animated gradient background
            RadialGradient(
                gradient: Gradient(colors: [
                    Color.orange.opacity(0.3),
                    Color.red.opacity(0.2),
                    Color.clear
                ]),
                center: .center,
                startRadius: animate ? 100 : 200,
                endRadius: animate ? 400 : 600
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)
            .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animate)
            
            VStack(spacing: 40) {
                // Animated icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.orange, Color.red],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .shadow(color: .orange.opacity(0.5), radius: animate ? 30 : 20)
                    
                    Image(systemName: "cup.and.saucer.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                        .scaleEffect(animate ? 1.1 : 1.0)
                }
                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: animate)
                
                // Main message
                VStack(spacing: 20) {
                    Text(l10n.breakTimeTitle)
                        .font(.system(size: 72, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 10)
                    
                    Text(l10n.breakTimeSubtitle)
                        .font(.system(size: 28, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                
                // Countdown
                VStack(spacing: 8) {
                    Text(l10n.closingIn)
                        .font(.system(size: 18))
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text("\(countdown)")
                        .font(.system(size: 48, weight: .bold, design: .monospaced))
                        .foregroundColor(.orange)
                }
                .padding(.top, 20)
                
                // Dismiss button
                Button(action: {
                    onDismiss()
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "xmark.circle.fill")
                        Text(l10n.dismissButton)
                    }
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 16)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.2))
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(.plain)
                .padding(.top, 20)
                
                // Keyboard hint
                Text(l10n.pressEscToClose)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.4))
                    .padding(.top, 10)
            }
            .allowsHitTesting(true)
        }
        .onAppear {
            animate = true
            countdown = ReminderManager.shared.overlayDurationSeconds
        }
        .onReceive(timer) { _ in
            if countdown > 0 {
                countdown -= 1
            }
        }
    }
}
