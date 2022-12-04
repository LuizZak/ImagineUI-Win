import Foundation
import WinSDK
import WinSDK.User

/// A Win32 window.
open class Win32Window {
    /// Array with references to currently opened windows.
    /// Used to keep `Win32Window` instances alive for at least as long as the
    /// Win32 window.
    private static var openWindows: [Win32Window] = []

    private let minSize: Size = Size(width: 200, height: 150)

    /// Set to `true` when a `WM_DESTROY` message has been received.
    private var isDestroyed: Bool = false

    /// Default base window class definition for this window type.
    public static var defaultWindowClass: WindowClass = WindowClass(className: "Win32Window")

    /// The default screen DPI constant.
    /// Usually defined as 96 on Windows versions that support it.
    public static let defaultDPI = Int(USER_DEFAULT_SCREEN_DPI)

    public private(set) var size: Size
    public private(set) var needsDisplay: Bool = false
    public private(set) var needsLayout: Bool = false

    /// DPI, or dots-per-inch- value of the window.
    /// Initializes to `Win32Window.defaultDPI` by default.
    public var dpi: Int = Win32Window.defaultDPI {
        didSet {
            dpiScalingFactor = Double(dpi) / Double(Self.defaultDPI)
        }
    }

    /// Returns a value that represents the current DPI scaling factor, which is
    /// `self.dpi / Win32Window.defaultDPI`.
    ///
    /// Higher DPI settings lead to higher scaling factors which must be accounted
    /// for by window clients.
    ///
    /// Defaults to 1.0 at instantiation, and changes automatically in response
    /// to changes in `self.dpi`.
    public private(set) var dpiScalingFactor: Double = 1.0

    public let hwnd: HWND

    /// The window class definition for this `Win32Window` instance.
    public let windowClass: WindowClass

    public init(settings: CreationSettings) {
        self.size = settings.size
        self.windowClass = settings.windowClass

        // Create the window.
        self.hwnd = settings.windowClass.createWindow(title: settings.title, size: settings.size)

        windowClass.registerSubClass(hwnd: hwnd, thisPointer: self, procedure: windowProc)

        initialize()
    }

    private func onDestroy() {
        if let index = Win32Window.openWindows.firstIndex(where: { $0 === self }) {
            Win32Window.openWindows.remove(at: index)
        }
    }

    open func initialize() {

    }

    // MARK: Display

    /// Displays this window on the screen.
    ///
    /// Should not be called if the window has been closed.
    open func show() {
        if !Win32Window.openWindows.contains(where: { $0 === self }) {
            Win32Window.openWindows.append(self)
        }

        if isDestroyed {
            WinLogger.warning("Called show() on a \(Win32Window.self) after a WM_DESTROY (onClose()) message has been received. The window will not be shown.")
        }

        ShowWindow(hwnd, SW_RESTORE)
    }

    open func setNeedsLayout() {
        guard needsLayout == false else { return }
        needsLayout = true

        RunLoop.main.perform { [weak self] in
            guard let self = self else { return }

            while self.needsLayout {
                self.onLayout()
            }
        }
    }

    open func clearNeedsLayout() {
        needsLayout = false
    }

    open func clearNeedsDisplay() {
        needsDisplay = false
    }

    open func setNeedsDisplay() {
        setNeedsDisplay(Rect(origin: .zero, size: size))
    }

    open func setNeedsDisplay(_ rect: Rect) {
        var r = rect.asRECT
        InvalidateRect(hwnd, &r, false)

        needsDisplay = true
    }

    // MARK: Events

    /// Posts a private message to this window's message queue.
    public func postMessage(_ message: CustomMessage) {
        PostMessageW(hwnd, message.uMsg, message.wParam, message.lParam)
    }

    // MARK: Layout events

    /// Called when the window is updating its layout after a call to
    /// `setNeedsLayout()` has been made recently.
    open func onLayout() {
        clearNeedsLayout()
    }

    // MARK: Window events

    /// Called when the window has received a `WM_DESTROY` message.
    ///
    /// Win32 API reference: https://docs.microsoft.com/en-us/windows/win32/winmsg/wm-destroy
    open func onClose(_ message: WindowMessage) {
        isDestroyed = true
    }

    /// Called when the window has received a a `WM_PAINT` message.
    ///
    /// Classes that override this method should handle updating needsDisplay and
    /// should not call `super.onPaint()` if GDI draw calls where made.
    ///
    /// Win32 API reference: https://docs.microsoft.com/en-us/windows/win32/gdi/wm-paint
    open func onPaint(_ message: WindowMessage) {
        if !needsDisplay {
            return
        }

        var ps = PAINTSTRUCT()
        let hdc: HDC = BeginPaint(hwnd, &ps)
        defer {
            EndPaint(hwnd, &ps)
            needsDisplay = false
        }

        FillRect(hdc, &ps.rcPaint, GetSysColorBrush(COLOR_WINDOW))
    }

    /// Called when the window has received a `WM_SIZE` message.
    ///
    /// Win32 API reference: https://docs.microsoft.com/en-us/windows/win32/winmsg/wm-size
    open func onResize(_ message: WindowMessage) {
        let width = LOWORD(message.lParam)
        let height = HIWORD(message.lParam)

        size = Size(width: Int(width), height: Int(height))
    }

    /// Called when the DPI settings for the display the window is hosted on
    /// changes.
    ///
    /// Win32 API reference: https://docs.microsoft.com/en-us/windows/win32/hidpi/wm-dpichanged
    open func onDPIChanged(_ message: WindowMessage) {
        dpi = Int(HIWORD(message.wParam))

        let lpInfo: UnsafeMutablePointer<RECT> = .init(bitPattern: UInt(message.lParam))!
        SetWindowPos(hwnd,
            nil,
            lpInfo.pointee.left,
            lpInfo.pointee.top,
            lpInfo.pointee.right - lpInfo.pointee.left,
            lpInfo.pointee.bottom - lpInfo.pointee.top,
            UINT(SWP_NOZORDER) | UINT(SWP_NOACTIVATE)
        )
    }

    // MARK: Mouse events

    /// Called when the mouse moves within the client area of this window.
    ///
    /// Return a non-nil value to prevent the window from sending the message to
    /// `DefSubclassProc` or `DefWindowProc`.
    ///
    /// Win32 API reference: https://docs.microsoft.com/en-us/windows/win32/inputdev/wm-mousemove
    open func onMouseMove(_ message: WindowMessage) -> LRESULT? {
        return nil
    }

    /// Called when the mouse scrolls within the client area of this window.
    ///
    /// Return a non-nil value to prevent the window from sending the message to
    /// `DefSubclassProc` or `DefWindowProc`.
    ///
    /// Win32 API reference: https://docs.microsoft.com/en-us/windows/win32/inputdev/wm-mousewheel
    open func onMouseWheel(_ message: WindowMessage) -> LRESULT? {
        return nil
    }

    /// Called when the mouse scrolls in the horizontal direction within the
    /// client area of this window.
    ///
    /// Return a non-nil value to prevent the window from sending the message to
    /// `DefSubclassProc` or `DefWindowProc`.
    ///
    /// Win32 API reference: https://docs.microsoft.com/en-us/windows/win32/inputdev/wm-mousehwheel
    open func onMouseHWheel(_ message: WindowMessage) -> LRESULT? {
        return nil
    }

    /// Called when the user presses down the left mouse button within the client
    /// area of this window.
    ///
    /// Win32 API reference: https://docs.microsoft.com/en-us/windows/win32/inputdev/wm-lbuttondown
    open func onLeftMouseDown(_ message: WindowMessage) -> LRESULT? {
        return nil
    }

    /// Called when the user presses down the middle mouse button within the client
    /// area of this window.
    ///
    /// Return a non-nil value to prevent the window from sending the message to
    /// `DefSubclassProc` or `DefWindowProc`.
    ///
    /// Win32 API reference: https://docs.microsoft.com/en-us/windows/win32/inputdev/wm-mbuttondown
    open func onMiddleMouseDown(_ message: WindowMessage) -> LRESULT? {
        return nil
    }

    /// Called when the user presses down the right mouse button within the client
    /// area of this window.
    ///
    /// Return a non-nil value to prevent the window from sending the message to
    /// `DefSubclassProc` or `DefWindowProc`.
    ///
    /// Win32 API reference: https://docs.microsoft.com/en-us/windows/win32/inputdev/wm-rbuttondown
    open func onRightMouseDown(_ message: WindowMessage) -> LRESULT? {
        return nil
    }

    /// Called when the user releases the left mouse button within the client
    /// area of this window.
    ///
    /// Return a non-nil value to prevent the window from sending the message to
    /// `DefSubclassProc` or `DefWindowProc`.
    ///
    /// Win32 API reference: https://docs.microsoft.com/en-us/windows/win32/inputdev/wm-lbuttonup
    open func onLeftMouseUp(_ message: WindowMessage) -> LRESULT? {
        return nil
    }

    /// Called when the user releases the middle mouse button within the client
    /// area of this window.
    ///
    /// Return a non-nil value to prevent the window from sending the message to
    /// `DefSubclassProc` or `DefWindowProc`.
    ///
    /// Win32 API reference: https://docs.microsoft.com/en-us/windows/win32/inputdev/wm-mbuttonup
    open func onMiddleMouseUp(_ message: WindowMessage) -> LRESULT? {
        return nil
    }

    /// Called when the user releases the right mouse button within the client
    /// area of this window.
    ///
    /// Return a non-nil value to prevent the window from sending the message to
    /// `DefSubclassProc` or `DefWindowProc`.
    ///
    /// Win32 API reference: https://docs.microsoft.com/en-us/windows/win32/inputdev/wm-rbuttonup
    open func onRightMouseUp(_ message: WindowMessage) -> LRESULT? {
        return nil
    }

    // MARK: Keyboard events

    /// Called when the user presses a keyboard key while this window has focus.
    ///
    /// Return a non-nil value to prevent the window from sending the message to
    /// `DefSubclassProc` or `DefWindowProc`.
    ///
    /// Win32 API reference: https://docs.microsoft.com/en-us/windows/win32/inputdev/wm-keydown
    open func onKeyDown(_ message: WindowMessage) -> LRESULT? {
        return nil
    }

    /// Called when the user releases a keyboard key while this window has focus.
    ///
    /// Return a non-nil value to prevent the window from sending the message to
    /// `DefSubclassProc` or `DefWindowProc`.
    ///
    /// Win32 API reference: https://docs.microsoft.com/en-us/windows/win32/inputdev/wm-keyup
    open func onKeyUp(_ message: WindowMessage) -> LRESULT? {
        return nil
    }

    /// > Posted to the window with the keyboard focus when the user presses the
    /// > F10 key (which activates the menu bar) or holds down the ALT key and
    /// > then presses another key.
    ///
    /// > It also occurs when no window currently has
    /// > the keyboard focus; in this case, the WM_SYSKEYDOWN message is sent to
    /// > the active window. The window that receives the message can distinguish
    /// > between these two contexts by checking the context code in the lParam
    /// > parameter.
    ///
    /// Return a non-nil value to prevent the window from sending the message to
    /// `DefSubclassProc` or `DefWindowProc`.
    ///
    /// From Win32 API reference: https://docs.microsoft.com/en-us/windows/win32/inputdev/wm-syskeydown
    open func onSystemKeyDown(_ message: WindowMessage) -> LRESULT? {
        return nil
    }

    /// "Posted to the window with the keyboard focus when the user releases a
    /// key that was pressed while the ALT key was held down."
    ///
    /// "It also occurs when no window currently has the keyboard focus; in this
    /// case, the WM_SYSKEYUP message is sent to the active window. The window
    /// that receives the message can distinguish between these two contexts by
    /// checking the context code in the lParam parameter."
    ///
    /// Return a non-nil value to prevent the window from sending the message to
    /// `DefSubclassProc` or `DefWindowProc`.
    ///
    /// From Win32 API reference: https://docs.microsoft.com/en-us/windows/win32/inputdev/wm-syskeyup
    open func onSystemKeyUp(_ message: WindowMessage) -> LRESULT? {
        return nil
    }

    /// Called when the user presses a keyboard key while this window has focus.
    ///
    /// Return a non-nil value to prevent the window from sending the message to
    /// `DefSubclassProc` or `DefWindowProc`.
    ///
    /// Win32 API reference: https://docs.microsoft.com/en-us/windows/win32/inputdev/wm-keydown
    open func onKeyCharDown(_ message: WindowMessage) -> LRESULT? {
        return nil
    }

    /// Called when the user presses a keyboard key of a representable character
    /// while this window has focus.
    ///
    /// Return a non-nil value to prevent the window from sending the message to
    /// `DefSubclassProc` or `DefWindowProc`.
    ///
    /// Win32 API reference: https://docs.microsoft.com/en-us/windows/win32/inputdev/wm-char
    open func onKeyChar(_ message: WindowMessage) -> LRESULT? {
        return nil
    }

    /// Called when the user presses a keyboard key of a representable "dead"
    /// character while this window has focus.
    ///
    /// > A dead key is a key that generates a character, such as the umlaut
    /// > (double-dot), that is combined with another character to form a composite
    /// > character. For example, the umlaut-O character ( ) is generated by typing
    /// > the dead key for the umlaut character, and then typing the O key.
    ///
    /// - Win32 API documentation
    ///
    /// Return a non-nil value to prevent the window from sending the message to
    /// `DefSubclassProc` or `DefWindowProc`.
    ///
    /// Win32 API reference: https://docs.microsoft.com/en-us/windows/win32/inputdev/wm-deadchar
    open func onKeyDeadChar(_ message: WindowMessage) -> LRESULT? {
        return nil
    }
}

fileprivate extension Win32Window {
    func handleMessage(_ uMsg: UINT, _ wParam: WPARAM, _ lParam: LPARAM) -> LRESULT? {
        let message = WindowMessage(uMsg: uMsg, wParam: wParam, lParam: lParam)

        switch Int32(uMsg) {

        // MARK: Native messages
        case WM_DESTROY:
            onClose(message)
            return 0

        case WM_NCDESTROY:
            onDestroy()
            return 0

        case WM_PAINT:
            // If layout is required and hasn't happened yet, do it before rendering.
            if needsLayout {
                onLayout()
            }
            onPaint(message)
            return 0

        case WM_SIZE:
            onResize(message)
            return 0

        case WM_MOUSEMOVE:
            return onMouseMove(message)

        case WM_MOUSEWHEEL:
            return onMouseWheel(message)
        
        case WM_MOUSEHWHEEL:
            return onMouseHWheel(message)

        case WM_LBUTTONDOWN:
            return onLeftMouseDown(message)

        case WM_LBUTTONUP:
            return onLeftMouseUp(message)

        case WM_MBUTTONDOWN:
            return onMiddleMouseDown(message)

        case WM_MBUTTONUP:
            return onMiddleMouseUp(message)

        case WM_RBUTTONDOWN:
            return onRightMouseDown(message)

        case WM_RBUTTONUP:
            return onRightMouseUp(message)

        case WM_KEYDOWN:
            return onKeyDown(message)

        case WM_KEYUP:
            return onKeyUp(message)

        case WM_SYSKEYDOWN:
            return onSystemKeyDown(message)

        case WM_SYSKEYUP:
            return onSystemKeyUp(message)

        case WM_CHAR:
            return onKeyChar(message)

        case WM_DEADCHAR:
            return onKeyDeadChar(message)

        case WM_DPICHANGED:
            onDPIChanged(message)
            return 0

        case WM_GETMINMAXINFO:
            func ClientSizeToWindowSize(_ size: Size) -> Size {
                var rc = Rect(origin: .zero, size: size).asRECT

                let gwlStyle = WS_MINIMIZEBOX | WS_MAXIMIZEBOX | WS_SIZEBOX
                let gwlExStyle = WS_EX_CLIENTEDGE

                if !AdjustWindowRectExForDpi(&rc,
                                             DWORD(gwlStyle),
                                             false,
                                             DWORD(gwlExStyle),
                                             GetDpiForWindow(hwnd)) {
                    WinLogger.warning("AdjustWindowRetExForDpi: \(Win32Error(win32: GetLastError()))")
                }

                return rc.asRect.size
            }

            // Adjust the minimum and maximum tracking size for the window.
            if let lpInfo = UnsafeMutablePointer<MINMAXINFO>(bitPattern: UInt(lParam)) {
                lpInfo.pointee.ptMinTrackSize = ClientSizeToWindowSize(minSize).asPOINT
            }

            return 0

        default:
            return nil
        }
    }
}

private let windowProc: SUBCLASSPROC = { (hWnd, uMsg, wParam, lParam, uIdSubclass, dwRefData) in
    if dwRefData != 0, let window = unsafeBitCast(dwRefData, to: AnyObject.self) as? Win32Window {
        if let result = window.handleMessage(uMsg, wParam, lParam) {
            return result
        }
    }

    return DefSubclassProc(hWnd, uMsg, wParam, lParam)
}
