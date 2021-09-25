import WinSDK

/// A Win32 window.
public class Win32Window {
    private let minSize: Size = Size(width: 200, height: 150)
    private var className: [WCHAR]
    var size: Size
    var needsDisplay: Bool = false

    internal var hwnd: HWND?

    init(size: Size) {
        self.size = size

        className = "Sample Window Class".wide
        
        initialize()
    }

    deinit {
        DestroyWindow(hwnd)
    }

    public func show() {
        ShowWindow(hwnd, SW_RESTORE)
    }

    func updateAndPaint() {
        onPaint()
    }

    func setNeedsDisplay(_ rect: Rect) {
        var r = RECT(from: rect)
        InvalidateRect(hwnd, &r, false)

        needsDisplay = true
    }

    // MARK: Messaging

    /// Called when the window is about to be closed by the user.
    func onClose() {

    }

    func onPaint() {
        var ps = PAINTSTRUCT()
        let hdc: HDC = BeginPaint(hwnd, &ps)
        defer { 
            EndPaint(hwnd, &ps) 
            needsDisplay = false
        }
        
        // All painting occurs here, between BeginPaint and EndPaint.
        FillRect(hdc, &ps.rcPaint, GetSysColorBrush(COLOR_WINDOW))
    }

    func onResize() {
        
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
            logging.error("Failed to create window: \(Win32Error(win32: GetLastError()))")
            fatalError()
        }

        _ = SetWindowSubclass(hwnd, 
                              windowProc, 
                              UINT_PTR.max,
                              unsafeBitCast(self as AnyObject, to: DWORD_PTR.self))
    }

    fileprivate func handleMessage(_ uMsg: UINT, _ wParam: WPARAM, _ lParam: LPARAM) -> LRESULT? {
        switch Int32(uMsg) {
        case WM_DESTROY:
            onClose()
            return 0

        case WM_PAINT:
            updateAndPaint()

            return 0

        case WM_SIZE:
            let width = LOWORD(lParam)
            let height = HIWORD(lParam)

            size = Size(width: Int(width), height: Int(height))

            onResize()
            
            return 0

        case WM_GETMINMAXINFO:
            func ClientSizeToWindowSize(_ size: Size) -> Size {
                var rc: RECT = RECT(from: Rect(origin: .zero, size: size))

                let gwlStyle: LONG = WS_MINIMIZEBOX | WS_MAXIMIZEBOX | WS_SIZEBOX
                let gwlExStyle: LONG = WS_EX_CLIENTEDGE

                if !AdjustWindowRectExForDpi(&rc,
                                             DWORD(gwlStyle),
                                             false,
                                             DWORD(gwlExStyle),
                                             GetDpiForWindow(hwnd)) {
                    logging.warning("AdjustWindowRetExForDpi: \(Win32Error(win32: GetLastError()))")
                }

                return Rect(from: rc).size
            }
            
            let lpInfo: UnsafeMutablePointer<MINMAXINFO> = .init(bitPattern: UInt(lParam))!
            
            // Adjust the minimum and maximum tracking size for the window.
            lpInfo.pointee.ptMinTrackSize =
                POINT(from: ClientSizeToWindowSize(minSize))

            return LRESULT(0)

        default:
            return DefWindowProcW(hwnd, uMsg, wParam, lParam)
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
