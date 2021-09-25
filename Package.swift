// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "ImagineUI-Win",
    products: [
        .library(
            name: "ImagineUI-Win",
            targets: ["ImagineUI-Win"]),
    ],
    dependencies: [
        .package(url: "https://github.com/LuizZak/ImagineUI.git", .branch("master")),
        .package(url: "https://github.com/apple/swift-log.git", .branch("main")),
        .package(url: "https://github.com/compnerd/swift-com.git", .branch("main")),
    ],
    targets: [
        .target(
            name: "ImagineUI-Win",
            dependencies: [
                "ImagineUI",
                .product(name: "SwiftCOM", package: "swift-com"),
                .product(name: "Logging", package: "swift-log")
            ]),
        .executableTarget(
            name: "ImagineUI-WinSample",
            dependencies: [
                "ImagineUI-Win"
            ],
            exclude: [
                "ImagineUI-WinSample.exe.manifest"
            ],
            resources: [
                .process("Resources/NotoSans-Regular.ttf")
            ],
            swiftSettings: [
                .unsafeFlags([
                    "-parse-as-library"
                ])
            ],
            linkerSettings: [
                .linkedLibrary("User32"),
                .linkedLibrary("ComCtl32"),
                .unsafeFlags([
                    "-Xlinker", 
                    "/SUBSYSTEM:WINDOWS"
                ])
            ]),
        .testTarget(
            name: "ImagineUI-WinTests",
            dependencies: ["ImagineUI-Win"]),
    ]
)
