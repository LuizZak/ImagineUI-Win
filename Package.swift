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
        .unsafeFlags([
            "-Xlinker",
            "/DEBUG",
        ], .when(configuration: .debug))
    ]
)

// Append settings required to run the executable on Windows
#if true

executableTarget.swiftSettings?.append(contentsOf: [
    .unsafeFlags([
        "-parse-as-library",
    ])
])
executableTarget.linkerSettings?.append(contentsOf: [
    .unsafeFlags([
        "-Xlinker",
        "/SUBSYSTEM:WINDOWS",
    ])
])

#endif

let package = Package(
    name: "ImagineUI-Win",
    products: [
        .library(
            name: "ImagineUI-Win",
            targets: [
                "ImagineUI-Win",
            ]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/LuizZak/ImagineUI.git", .branch("master")),
        .package(url: "https://github.com/LuizZak/MinWin32.git", .branch("main")),
        .package(url: "https://github.com/apple/swift-log.git", .branch("main")),
    ],
    targets: [
        executableTarget,
        .target(
            name: "ImagineUI-Win",
            dependencies: [
                "ImagineUI",
                .product(name: "MinWin32", package: "MinWin32"),
                .product(name: "Blend2DRenderer", package: "ImagineUI"),
                .product(name: "Logging", package: "swift-log"),
            ]
        ),
        .testTarget(
            name: "ImagineUI-WinTests",
            dependencies: [
                "ImagineUI-Win",
            ]
        ),
    ]
)
