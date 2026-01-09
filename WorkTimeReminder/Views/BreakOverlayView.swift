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
        
        let overlayView = BreakOverlayView(onDismiss: { [weak self] in
            self?.hideOverlay()
        })
        
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
    
    @State private var animate = false
    @State private var countdown: Int = ReminderManager.shared.overlayDurationSeconds
    
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
        VStack(spacing: 40) {
            iconView
            messageView
            countdownView
            dismissButton
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
                .frame(width: 120, height: 120)
                .shadow(color: primaryColor.opacity(0.5), radius: animate ? 30 : 20)
            
            Image(systemName: "cup.and.saucer.fill")
                .font(.system(size: 50))
                .foregroundColor(.white)
                .scaleEffect(animate ? 1.1 : 1.0)
        }
        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: animate)
    }
    
    private var messageView: some View {
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
    }
    
    private var countdownView: some View {
        VStack(spacing: 8) {
            Text(l10n.closingIn)
                .font(.system(size: 18))
                .foregroundColor(.white.opacity(0.6))
            
            Text("\(countdown)")
                .font(.system(size: 48, weight: .bold, design: .monospaced))
                .foregroundColor(primaryColor)
        }
        .padding(.top, 20)
    }
    
    private var dismissButton: some View {
        Button(action: onDismiss) {
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
                    .fill(Color.white.opacity(0.15))
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .padding(.top, 20)
    }
    
    private var keyboardHint: some View {
        Text(l10n.pressEscToClose)
            .font(.system(size: 14))
            .foregroundColor(.white.opacity(0.4))
            .padding(.top, 10)
    }
}

