// swift-tools-version: 6.2
import PackageDescription

let strict: [SwiftSetting] = [.treatAllWarnings(as: .error)]

let package = Package(
    name: "PracticalKit",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "KeyboardCore", targets: ["KeyboardCore"]),
    ],
    targets: [
        .target(name: "KeyboardCore", swiftSettings: strict),
        .testTarget(name: "KeyboardCoreTests", dependencies: ["KeyboardCore"], swiftSettings: strict),
    ],
    swiftLanguageModes: [.v6],
)
