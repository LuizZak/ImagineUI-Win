import WinSDK
import WinSDK.User

/// A Win32 window.
public class Win32Window {
    /// The default screen DPI constant.
    /// Usually defined as 96 on Windows versions that support it.
    public static let defaultDPI = Int(USER_DEFAULT_SCREEN_DPI)

    private let minSize: Size = Size(width: 200, height: 150)
    private var className: [WCHAR]
    var size: Size
    var needsDisplay: Bool = false

    /// DPI, or dots-per-inch- value of the window.
    /// Initializes to `Win32Window.defaultDPI` by default.
    var dpi: Int = Win32Window.defaultDPI {
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
    private(set) var dpiScalingFactor: Double = 1.0

    internal var hwnd: HWND?

    init(size: Size) {
        self.size = size

        // TODO: Change this
        className = "Sample Window Class".wide

        initialize()
    }

    public func show() {
        ShowWindow(hwnd, SW_RESTORE)
    }

    func setNeedsDisplay() {
        setNeedsDisplay(Rect(origin: .zero, size: size))
    }

    func setNeedsDisplay(_ rect: Rect) {
        var r = rect.asRECT
        InvalidateRect(hwnd, &r, false)

        needsDisplay = true
    }

    // MARK: Events

    // MARK: Window events

    /// Called when the window has received  `WM_DESTROY` message.
    ///
    /// Win32 API reference: https://docs.microsoft.com/en-us/windows/win32/winmsg/wm-destroy
    func onClose(_ message: WindowMessage) {

    }

    /// Called when the window has received a `WM_PAINT` message.
    ///
    /// Classes that override this method should handle updating needsDisplay and
    /// should not call `super.onPaint()` if GDI draw calls where made.
    ///
    /// Win32 API reference: https://docs.microsoft.com/en-us/windows/win32/gdi/wm-paint
    func onPaint(_ message: WindowMessage) {
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
    func onResize(_ message: WindowMessage) {
        let width = LOWORD(message.lParam)
        let height = HIWORD(message.lParam)

        size = Size(width: Int(width), height: Int(height))
    }

    /// Called when the DPI settings for the display the window is hosted on
    /// changes.
    ///
    /// Win32 API reference: https://docs.microsoft.com/en-us/windows/win32/hidpi/wm-dpichanged
    func onDPIChanged(_ message: WindowMessage) {
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
    func onMouseMove(_ message: WindowMessage) -> LRESULT? {
        return nil
    }

    /// Called when the user presses down the left mouse button within the client
    /// area of this window.
    ///
    /// Win32 API reference: https://docs.microsoft.com/en-us/windows/win32/inputdev/wm-lbuttondown
    func onLeftMouseDown(_ message: WindowMessage) -> LRESULT? {
        return nil
    }

    /// Called when the user presses down the middle mouse button within the client
    /// area of this window.
    ///
    /// Return a non-nil value to prevent the window from sending the message to
    /// `DefSubclassProc` or `DefWindowProc`.
    ///
    /// Win32 API reference: https://docs.microsoft.com/en-us/windows/win32/inputdev/wm-mbuttondown
    func onMiddleMouseDown(_ message: WindowMessage) -> LRESULT? {
        return nil
    }

    /// Called when the user presses down the right mouse button within the client
    /// area of this window.
    ///
    /// Return a non-nil value to prevent the window from sending the message to
    /// `DefSubclassProc` or `DefWindowProc`.
    ///
    /// Win32 API reference: https://docs.microsoft.com/en-us/windows/win32/inputdev/wm-rbuttondown
    func onRightMouseDown(_ message: WindowMessage) -> LRESULT? {
        return nil
    }

    /// Called when the user releases the left mouse button within the client
    /// area of this window.
    ///
    /// Return a non-nil value to prevent the window from sending the message to
    /// `DefSubclassProc` or `DefWindowProc`.
    ///
    /// Win32 API reference: https://docs.microsoft.com/en-us/windows/win32/inputdev/wm-lbuttonup
    func onLeftMouseUp(_ message: WindowMessage) -> LRESULT? {
        return nil
    }

    /// Called when the user releases the middle mouse button within the client
    /// area of this window.
    ///
    /// Return a non-nil value to prevent the window from sending the message to
    /// `DefSubclassProc` or `DefWindowProc`.
    ///
    /// Win32 API reference: https://docs.microsoft.com/en-us/windows/win32/inputdev/wm-mbuttonup
    func onMiddleMouseUp(_ message: WindowMessage) -> LRESULT? {
        return nil
    }

    /// Called when the user releases the right mouse button within the client
    /// area of this window.
    ///
    /// Return a non-nil value to prevent the window from sending the message to
    /// `DefSubclassProc` or `DefWindowProc`.
    ///
    /// Win32 API reference: https://docs.microsoft.com/en-us/windows/win32/inputdev/wm-rbuttonup
    func onRightMouseUp(_ message: WindowMessage) -> LRESULT? {
        return nil
    }

    // MARK: Keyboard events

    /// Called when the user presses a keyboard key while this window has focus.
    ///
    /// Return a non-nil value to prevent the window from sending the message to
    /// `DefSubclassProc` or `DefWindowProc`.
    ///
    /// Win32 API reference: https://docs.microsoft.com/en-us/windows/win32/inputdev/wm-keydown
    func onKeyDown(_ message: WindowMessage) -> LRESULT? {
        return nil
    }

    /// Called when the user releases a keyboard key while this window has focus.
    ///
    /// Return a non-nil value to prevent the window from sending the message to
    /// `DefSubclassProc` or `DefWindowProc`.
    ///
    /// Win32 API reference: https://docs.microsoft.com/en-us/windows/win32/inputdev/wm-keyup
    func onKeyUp(_ message: WindowMessage) -> LRESULT? {
        return nil
    }

    /// "Posted to the window with the keyboard focus when the user presses the
    /// F10 key (which activates the menu bar) or holds down the ALT key and
    /// then presses another key."
    ///
    /// "It also occurs when no window currently has
    /// the keyboard focus; in this case, the WM_SYSKEYDOWN message is sent to
    /// the active window. The window that receives the message can distinguish
    /// between these two contexts by checking the context code in the lParam
    /// parameter."
    ///
    /// Return a non-nil value to prevent the window from sending the message to
    /// `DefSubclassProc` or `DefWindowProc`.
    ///
    /// From Win32 API reference: https://docs.microsoft.com/en-us/windows/win32/inputdev/wm-syskeydown
    func onSystemKeyDown(_ message: WindowMessage) -> LRESULT? {
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
    func onSystemKeyUp(_ message: WindowMessage) -> LRESULT? {
        return nil
    }

    // MARK: Initialization and message processing

    internal func initialize() {
        let handle = GetModuleHandleW(nil)

        let IDC_ARROW: UnsafePointer<WCHAR> =
            UnsafePointer<WCHAR>(bitPattern: 32512)!

        // Register the window class.
        var wc = WNDCLASSW()
        className.withUnsafeBufferPointer { p in
            wc.style         = UINT(CS_HREDRAW | CS_VREDRAW)
            wc.hCursor       = LoadCursorW(nil, IDC_ARROW)
            wc.lpfnWndProc   = DefWindowProcW
            wc.hInstance     = handle
            wc.lpszClassName = p.baseAddress!

            RegisterClassW(&wc)
        }

        // Create the window.
        hwnd = CreateWindowExW(
            0,                               // Optional window styles.
            wc.lpszClassName,                // Window class
            // TODO: Change window title text
            "Learn to Program Windows".wide, // Window text
            WS_OVERLAPPEDWINDOW,             // Window style

            // Size and position
            CW_USEDEFAULT, CW_USEDEFAULT, Int32(size.width), Int32(size.height),

            nil,     // Parent window
            nil,     // Menu
            handle,  // Instance handle
            nil      // Additional application data
        )

        if (hwnd == nil) {
            WinLogger.error("Failed to create window: \(Win32Error(win32: GetLastError()))")
            fatalError()
        }

        _ = SetWindowSubclass(hwnd,
                              windowProc,
                              UINT_PTR.max,
                              unsafeBitCast(self as AnyObject, to: DWORD_PTR.self))
    }
}

fileprivate extension Win32Window {
    func handleMessage(_ uMsg: UINT, _ wParam: WPARAM, _ lParam: LPARAM) -> LRESULT? {
        let message = WindowMessage(uMsg: uMsg, wParam: wParam, lParam: lParam)

        switch Int32(uMsg) {
        case WM_DESTROY:
            onClose(message)
            return 0

        case WM_PAINT:
            onPaint(message)
            return 0

        case WM_SIZE:
            onResize(message)
            return 0

        case WM_MOUSEMOVE:
            return onMouseMove(message)

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

        case WM_DPICHANGED:
            onDPIChanged(message)
            return 0

        case WM_GETMINMAXINFO:
            func ClientSizeToWindowSize(_ size: Size) -> Size {
                var rc: RECT = Rect(origin: .zero, size: size).asRECT

                let gwlStyle: LONG = WS_MINIMIZEBOX | WS_MAXIMIZEBOX | WS_SIZEBOX
                let gwlExStyle: LONG = WS_EX_CLIENTEDGE

                if !AdjustWindowRectExForDpi(&rc,
                                             DWORD(gwlStyle),
                                             false,
                                             DWORD(gwlExStyle),
                                             GetDpiForWindow(hwnd)) {
                    WinLogger.warning("AdjustWindowRetExForDpi: \(Win32Error(win32: GetLastError()))")
                }

                return rc.asRect.size
            }

            let lpInfo: UnsafeMutablePointer<MINMAXINFO> = .init(bitPattern: UInt(lParam))!

            // Adjust the minimum and maximum tracking size for the window.
            lpInfo.pointee.ptMinTrackSize = ClientSizeToWindowSize(minSize).asPOINT
            return 0

        default:
            return nil
        }
    }
}

private let windowProc: SUBCLASSPROC = { (hWnd, uMsg, wParam, lParam, uIdSubclass, dwRefData) in
    if let window = unsafeBitCast(dwRefData, to: AnyObject.self) as? Win32Window {
        if let result = window.handleMessage(uMsg, wParam, lParam) {
            return result
        }
    }

    return DefSubclassProc(hWnd, uMsg, wParam, lParam)
}
