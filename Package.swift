// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WorkoutTracker",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "WorkoutTracker",
            targets: ["WorkoutTracker"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ntobekosikithi/Utilities.git", branch: "main"),
        .package(url: "https://github.com/ntobekosikithi/GoalManager.git", branch: "main")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "WorkoutTracker",
            dependencies: ["Utilities", "GoalManager"]),
        .testTarget(
            name: "WorkoutTrackerTests",
            dependencies: ["WorkoutTracker"]
        ),
    ]
)
