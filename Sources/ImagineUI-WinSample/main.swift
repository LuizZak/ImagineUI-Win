import WinSDK
import Foundation
import ImagineUI_Win

var app: ImagineUIApp!

@_silgen_name("wWinMain")
func wWinMain(_ hInstance: HINSTANCE,
              _ hPrevInstance: HINSTANCE,
              _ pCmdLine: PWSTR,
              _ nCmdShow: CInt) -> CInt {

    try? setupLogging()

    let delegate = SampleDelegate()
    let fontPath = Bundle.module.path(forResource: "NotoSans-Regular", ofType: "ttf")!

    if !FileManager.default.fileExists(atPath: fontPath) {
        WinLogger.error("Failed to find default font face at path \(fontPath)")
        fatalError()
    }

    let settings = ImagineUIAppStartupSettings(defaultFontPath: fontPath)

    app = ImagineUIApp(delegate: delegate)
    return try! app.run(settings: settings)
}

func setupLogging() throws {
    let appDataPath = try SystemPaths.localAppData()

    let logFolder =
    appDataPath
        .appendingPathComponent("ImagineUI-Win")
        .appendingPathComponent("Sample")

    try FileManager.default.createDirectory(at: logFolder, withIntermediateDirectories: true)

    let logPath =
    logFolder
        .appendingPathComponent("log.txt")

    try WinLogger.setup(logFileUrl: logPath, label: "com.imagineui-win.sample.log")
}
