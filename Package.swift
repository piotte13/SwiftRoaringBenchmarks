// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftRoaringBenchmarks",
    products: [
        .library(name: "Utils", targets: ["Utils"]),
        .library(name: "ccode", targets: ["ccode"]),
        .executable(name: "CRoaringBenchmarks", targets: ["CRoaringBenchmarks"]),
        .executable(name: "SwiftRoaringBenchmarks", targets: ["SwiftRoaringBenchmarks"]),
        .executable(name: "SwiftSetBenchmarks", targets: ["SwiftSetBenchmarks"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/piotte13/SwiftRoaring.git", from: "1.0.3"),
        .package(url: "https://github.com/lemire/SwiftBitset.git", from: "0.3.3")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "Utils",
            dependencies: []),
        .target(
            name: "ccode",
            dependencies: ["SwiftRoaring"],
            path: "./Sources/CCode"),
        .target(
            name: "SwiftRoaringBenchmarks",
            dependencies: ["SwiftRoaring", "Utils"]),
        .target(
            name: "CRoaringBenchmarks",
            dependencies: ["SwiftRoaring", "ccode", "Utils"]),
        .target(
            name: "SwiftSetBenchmarks",
            dependencies: ["Utils"]),
        .target(
            name: "SwiftBitsetBenchmarks",
            dependencies: ["Bitset", "Utils"]),
    ]
)
