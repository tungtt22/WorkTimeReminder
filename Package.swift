// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "WorkTimeReminder",
    platforms: [
        .macOS(.v12)
    ],
    targets: [
        .executableTarget(
            name: "WorkTimeReminder",
            path: "WorkTimeReminder",
            resources: [
                .process("Info.plist")
            ]
        )
    ]
)

