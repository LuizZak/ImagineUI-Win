import Foundation
import WinSDK
import SwiftCOM
import ImagineUI
import MinWin32

public class ImagineUIApp: MinWin32App {
    var settings: ImagineUIAppStartupSettings

    public init(
        settings: ImagineUIAppStartupSettings,
        delegate: any MinWin32AppDelegate
    ) {
        self.settings = settings

        super.init(delegate: delegate)
    }

    /// Opens a window to show a given content.
    public func show(
        content: ImagineUIContentType,
        position: Win32Window.InitialPosition = .default
    ) {
        let settings = Win32Window.CreationSettings(
            title: "ImagineUI-Win Sample Window",
            size: content.size.asSize
        )
        let window = Blend2DWindow(settings: settings, content: content)

        window.show(position: position)
    }

    /// Initializes the main run loop of the application.
    public override func run() throws -> Int32 {
        try UISettings.initialize(
            .init(
                fontManager: settings.fontManager,
                defaultFontPath: settings.defaultFontPath,
                timeInSecondsFunction: { Stopwatch.global.timeIntervalSinceStart() }
            )
        )

        return try super.run()
    }
}
