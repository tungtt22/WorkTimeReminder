#!/usr/bin/env swift

import Foundation

/// Real-time performance monitor for WorkTimeReminder app
/// Run this script while the app is running to monitor its resource usage

// MARK: - Performance Metrics

struct PerformanceMetrics {
    var memoryMB: Double = 0
    var cpuPercent: Double = 0
    var threads: Int = 0
    var timestamp: Date = Date()
    
    var description: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return """
        [\(formatter.string(from: timestamp))] Memory: \(String(format: "%6.2f", memoryMB)) MB | \
        CPU: \(String(format: "%5.2f", cpuPercent))% | \
        Threads: \(threads)
        """
    }
}

// MARK: - Performance Monitor

class PerformanceMonitor {
    
    private var metrics: [PerformanceMetrics] = []
    private let appName = "WorkTimeReminder"
    private var pid: Int32?
    
    // Thresholds
    let maxMemoryMB: Double = 100
    let maxCPUPercent: Double = 10
    let maxThreads: Int = 20
    
    func findAppPID() -> Int32? {
        let task = Process()
        task.launchPath = "/bin/ps"
        task.arguments = ["-ax", "-o", "pid,comm"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        
        do {
            try task.run()
            task.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                for line in output.split(separator: "\n") {
                    if line.contains(appName) {
                        let parts = line.split(separator: " ")
                        if let pidStr = parts.first, let pid = Int32(pidStr) {
                            return pid
                        }
                    }
                }
            }
        } catch {
            print("Error finding PID: \(error)")
        }
        
        return nil
    }
    
    func getProcessMetrics(pid: Int32) -> PerformanceMetrics? {
        var metrics = PerformanceMetrics()
        metrics.timestamp = Date()
        
        // Get memory and CPU using ps command
        let task = Process()
        task.launchPath = "/bin/ps"
        task.arguments = ["-p", "\(pid)", "-o", "rss,pcpu,nlwp"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        
        do {
            try task.run()
            task.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                let lines = output.split(separator: "\n")
                if lines.count >= 2 {
                    let values = lines[1].split(separator: " ").map { String($0) }
                    if values.count >= 2 {
                        // RSS is in KB, convert to MB
                        if let rss = Double(values[0]) {
                            metrics.memoryMB = rss / 1024
                        }
                        if let cpu = Double(values[1]) {
                            metrics.cpuPercent = cpu
                        }
                    }
                    if values.count >= 3, let threads = Int(values[2]) {
                        metrics.threads = threads
                    }
                }
            }
            
            return metrics
        } catch {
            return nil
        }
    }
    
    func monitor(duration: TimeInterval, interval: TimeInterval = 1.0) {
        print("""
        ╔═══════════════════════════════════════════════════════════════╗
        ║       WorkTimeReminder Performance Monitor                    ║
        ╠═══════════════════════════════════════════════════════════════╣
        ║  Thresholds:                                                  ║
        ║    Max Memory: \(String(format: "%6.0f", maxMemoryMB)) MB                                     ║
        ║    Max CPU:    \(String(format: "%6.1f", maxCPUPercent))%                                       ║
        ║    Max Threads:\(String(format: "%6d", maxThreads))                                        ║
        ╚═══════════════════════════════════════════════════════════════╝
        """)
        
        guard let pid = findAppPID() else {
            print("❌ Error: \(appName) is not running!")
            print("   Please start the app first: open /Applications/\(appName).app")
            return
        }
        
        self.pid = pid
        print("✅ Found \(appName) (PID: \(pid))")
        print("📊 Monitoring for \(Int(duration)) seconds...\n")
        print("─────────────────────────────────────────────────────────────────")
        
        let startTime = Date()
        var warningsCount = 0
        
        while Date().timeIntervalSince(startTime) < duration {
            if let currentMetrics = getProcessMetrics(pid: pid) {
                metrics.append(currentMetrics)
                
                var line = currentMetrics.description
                
                // Add warnings
                var warnings: [String] = []
                if currentMetrics.memoryMB > maxMemoryMB {
                    warnings.append("⚠️ HIGH MEM")
                    warningsCount += 1
                }
                if currentMetrics.cpuPercent > maxCPUPercent {
                    warnings.append("⚠️ HIGH CPU")
                    warningsCount += 1
                }
                if currentMetrics.threads > maxThreads {
                    warnings.append("⚠️ MANY THREADS")
                    warningsCount += 1
                }
                
                if !warnings.isEmpty {
                    line += " | " + warnings.joined(separator: " ")
                }
                
                print(line)
            } else {
                print("⚠️  Could not read metrics (app may have closed)")
                break
            }
            
            Thread.sleep(forTimeInterval: interval)
        }
        
        printSummary(warningsCount: warningsCount)
    }
    
    private func printSummary(warningsCount: Int) {
        guard !metrics.isEmpty else {
            print("\n❌ No metrics collected")
            return
        }
        
        let avgMemory = metrics.map { $0.memoryMB }.reduce(0, +) / Double(metrics.count)
        let maxMemory = metrics.map { $0.memoryMB }.max() ?? 0
        let minMemory = metrics.map { $0.memoryMB }.min() ?? 0
        
        let avgCPU = metrics.map { $0.cpuPercent }.reduce(0, +) / Double(metrics.count)
        let maxCPU = metrics.map { $0.cpuPercent }.max() ?? 0
        
        let avgThreads = Double(metrics.map { $0.threads }.reduce(0, +)) / Double(metrics.count)
        let maxThreads = metrics.map { $0.threads }.max() ?? 0
        
        let memoryPassed = maxMemory <= self.maxMemoryMB
        let cpuPassed = avgCPU <= maxCPUPercent
        let threadsPassed = maxThreads <= self.maxThreads
        let overallPassed = memoryPassed && cpuPassed && threadsPassed
        
        print("""
        
        ═══════════════════════════════════════════════════════════════════
                            PERFORMANCE SUMMARY
        ═══════════════════════════════════════════════════════════════════
        
        📊 Memory Usage:
           Average: \(String(format: "%.2f", avgMemory)) MB
           Min:     \(String(format: "%.2f", minMemory)) MB
           Max:     \(String(format: "%.2f", maxMemory)) MB
           Status:  \(memoryPassed ? "✅ PASS" : "❌ FAIL") (threshold: \(maxMemoryMB) MB)
        
        ⚡ CPU Usage:
           Average: \(String(format: "%.2f", avgCPU))%
           Peak:    \(String(format: "%.2f", maxCPU))%
           Status:  \(cpuPassed ? "✅ PASS" : "❌ FAIL") (threshold: \(maxCPUPercent)%)
        
        🧵 Threads:
           Average: \(String(format: "%.1f", avgThreads))
           Max:     \(maxThreads)
           Status:  \(threadsPassed ? "✅ PASS" : "❌ FAIL") (threshold: \(self.maxThreads))
        
        📈 Samples collected: \(metrics.count)
        ⚠️  Warnings triggered: \(warningsCount)
        
        ═══════════════════════════════════════════════════════════════════
                    OVERALL: \(overallPassed ? "✅ PASSED - App is lightweight!" : "❌ FAILED - Performance issues detected")
        ═══════════════════════════════════════════════════════════════════
        """)
        
        if overallPassed {
            print("""
            
            💡 Performance Assessment:
               • Memory footprint is minimal for a menu bar app
               • CPU usage is negligible when idle
               • Thread count is reasonable
               • App should not impact system performance
            """)
        } else {
            print("""
            
            ⚠️  Recommendations:
            """)
            if !memoryPassed {
                print("   • Memory usage is high - check for leaks or unnecessary caching")
            }
            if !cpuPassed {
                print("   • CPU usage is high - check timer implementations and reduce updates")
            }
            if !threadsPassed {
                print("   • Too many threads - consider consolidating background tasks")
            }
        }
    }
}

// MARK: - Main

let monitor = PerformanceMonitor()

// Parse command line arguments
var duration: TimeInterval = 30  // Default 30 seconds

if CommandLine.arguments.count > 1 {
    if let d = TimeInterval(CommandLine.arguments[1]) {
        duration = d
    }
}

print("🚀 Starting performance monitoring...")
print("   Duration: \(Int(duration)) seconds")
print("   Press Ctrl+C to stop early\n")

monitor.monitor(duration: duration)

