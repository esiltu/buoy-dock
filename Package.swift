// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "Buoy",
    platforms: [.macOS(.v26)],
    targets: [
        .executableTarget(
            name: "Buoy",
            path: "Sources/Buoy",
            swiftSettings: [.swiftLanguageMode(.v5)]
        )
    ]
)
