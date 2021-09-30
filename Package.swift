// swift-tools-version:5.5
import PackageDescription

var executableTarget: Target = .executableTarget(
    name: "ImagineUI-WinSample",
    dependencies: [
        "ImagineUI-Win",
        .product(name: "Logging", package: "swift-log"),
    ],
    exclude: [
        "ImagineUI-WinSample.exe.manifest",
    ],
    resources: [
        .process("Resources/NotoSans-Regular.ttf")
    ],
    swiftSettings: [],
    linkerSettings: [
        .linkedLibrary("User32"),
        .linkedLibrary("ComCtl32"),
    ]
)

#if true

// Append settings required to run the executable on Windows
executableTarget.swiftSettings?.append(
    .unsafeFlags([
        "-parse-as-library",
    ])
)
executableTarget.linkerSettings?.append(
    .unsafeFlags([
        "-Xlinker",
        "/SUBSYSTEM:WINDOWS",
    ])
)

#endif

let package = Package(
    name: "ImagineUI-Win",
    products: [
        .library(
            name: "ImagineUI-Win",
            targets: [
                "ImagineUI-Win",
            ]),
        .library(
            name: "MinWin32",
            targets: [
                "MinWin32",
            ]),
    ],
    dependencies: [
        .package(url: "https://github.com/LuizZak/ImagineUI.git", .branch("master")),
        .package(url: "https://github.com/apple/swift-log.git", .branch("main")),
        .package(url: "https://github.com/compnerd/swift-com.git", .branch("main")),
    ],
    targets: [
        executableTarget,
        .target(
            name: "MinWin32",
            dependencies: [
                .product(name: "SwiftCOM", package: "swift-com"),
                .product(name: "Logging", package: "swift-log"),
            ]),
        .target(
            name: "ImagineUI-Win",
            dependencies: [
                "ImagineUI",
                "MinWin32",
                .product(name: "Blend2DRenderer", package: "ImagineUI"),
                .product(name: "Logging", package: "swift-log"),
            ]),
        .testTarget(
            name: "ImagineUI-WinTests",
            dependencies: [
                "ImagineUI-Win",
            ]),
    ]
)
