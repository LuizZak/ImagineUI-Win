import Foundation
import WinSDK
import SwiftCOM
import ImagineUI
import MinWin32

public class ImagineUIApp: MinWin32App {
    var settings: ImagineUIAppStartupSettings
    var mainThreadId: DWORD

    public init(
        settings: ImagineUIAppStartupSettings,
        delegate: any MinWin32AppDelegate
    ) {
        self.settings = settings
        self.mainThreadId = GetCurrentThreadId()

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

        RunLoop.main.perform {
            let window = Blend2DWindow(settings: settings, content: content)

            window.show(position: position)
        }
    }

    public override func requestQuit() {
        WinLogger.info("Application requested termination.")

        PostThreadMessageW(mainThreadId, UINT(WM_QUIT), 0, 0)
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

        // Register custom messages
        for custom in CustomMessages.allMessages {
            custom.messageHandle = try custom.registerOnce()
        }

        // Initialize COM
        do {
            try CoInitializeEx(COINIT_MULTITHREADED)
        } catch {
            WinLogger.error("CoInitializeEx: \(error)")
            return EXIT_FAILURE
        }

        // Enable Per Monitor DPI Awareness
        if !SetProcessDpiAwarenessContext(DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2) {
            WinLogger.error("SetProcessDpiAwarenessContext: \(Win32Error(win32: GetLastError()))")
        }

        let dwICC: DWORD =
            DWORD(ICC_BAR_CLASSES) |
            DWORD(ICC_DATE_CLASSES) |
            DWORD(ICC_LISTVIEW_CLASSES) |
            DWORD(ICC_NATIVEFNTCTL_CLASS) |
            DWORD(ICC_PROGRESS_CLASS) |
            DWORD(ICC_STANDARD_CLASSES)

        var ICCE: INITCOMMONCONTROLSEX =
            INITCOMMONCONTROLSEX(
                dwSize: DWORD(MemoryLayout<INITCOMMONCONTROLSEX>.size),
                dwICC: dwICC
            )

        if !InitCommonControlsEx(&ICCE) {
            WinLogger.error("InitCommonControlsEx: \(Win32Error(win32: GetLastError()))")
        }

        var pAppRegistration: PAPPSTATE_REGISTRATION?
        let ulStatus =
            RegisterAppStateChangeNotification(
                pApplicationStateChangeRoutine,
                unsafeBitCast(self as AnyObject, to: PVOID.self),
                &pAppRegistration
            )

        if ulStatus != ERROR_SUCCESS {
            WinLogger.error("RegisterAppStateChangeNotification: \(Win32Error(win32: GetLastError()))")
        }

        ImagineActorExecutor.initialize()

        try delegate.appDidLaunch()

        var msg: MSG = MSG()
        var nExitCode: Int32 = EXIT_SUCCESS

        // Update main thread ID before proceeding
        self.mainThreadId = GetCurrentThreadId()

        mainLoop: while true {
            // Process all messages in thread's message queue; for GUI applications
            // UI events must have high priority.
            while PeekMessageW(&msg, nil, 0, 0, UINT(PM_REMOVE)) {
                if msg.message == UINT(WM_QUIT) {
                    nExitCode = Int32(msg.wParam)
                    break mainLoop
                }

                TranslateMessage(&msg)
                DispatchMessageW(&msg)
            }

            var time: Date? = nil
            repeat {
                // Execute Foundation.RunLoop once and determine the next time the timer
                // fires.  At this point handle all Foundation.RunLoop timers, sources and
                // Dispatch.DispatchQueue.main tasks
                time = RunLoop.main.limitDate(forMode: .default)

                // If Foundation.RunLoop doesn't contain any timers or the timers should
                // not be running right now, we interrupt the current loop or otherwise
                // continue to the next iteration.
            } while (time?.timeIntervalSinceNow ?? -1) <= 0

            // Yield control to the system until the earlier of a requisite timer
            // expiration or a message is posted to the runloop.
            _ = MsgWaitForMultipleObjects(
                0, nil, false,
                DWORD(exactly: time?.timeIntervalSinceNow ?? -1)
                    ?? 1,
                QS_ALLINPUT | DWORD(QS_KEY) | QS_MOUSE | DWORD(QS_RAWINPUT)
            )
        }

        return nExitCode
    }

    internal func didMoveToForeground() {
        delegate.appDidMoveToForeground()
    }

    internal func didMoveToBackground() {
        delegate.appDidMoveToBackground()
    }
}

private let pApplicationStateChangeRoutine: PAPPSTATE_CHANGE_ROUTINE = { (quiesced: UInt8, context: PVOID?) in
    guard let app = unsafeBitCast(context, to: AnyObject.self) as? ImagineUIApp else {
        return
    }

    let foregrounding: Bool = quiesced == 0
    if foregrounding {
        app.didMoveToForeground()
    } else {
        app.didMoveToBackground()
    }
}
