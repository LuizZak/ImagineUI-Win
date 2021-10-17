import WinSDK

/// A Win32 window class type.
///
/// Win32 reference: https://docs.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-wndclassw
public class WindowClass {
    private var classNameChar: [WCHAR]
    private var isRegistered: Bool = false
    private var wndProc: WNDPROC

    public let className: String
    private(set) public var windowClass: WNDCLASSW

    public init(className: String, wndProc: @escaping WNDPROC = DefWindowProcW) {
        self.className = className
        self.classNameChar = className.wide
        self.wndProc = wndProc
        self.windowClass = WNDCLASSW()

        let handle = GetModuleHandleW(nil)

        withClassName { ptr in
            windowClass.style         = UINT(CS_HREDRAW | CS_VREDRAW)
            windowClass.hCursor       = LoadCursorW(nil, IDC_ARROW)
            windowClass.lpfnWndProc   = wndProc
            windowClass.hInstance     = handle
            windowClass.lpszClassName = ptr
        }

        // Register the window class.
        RegisterClassW(&windowClass)
    }

    /// Invokes a provided closure with the underlying pointer to this window's
    /// class name.
    public func withClassName<T>(_ closure: (LPCWSTR) throws -> T) rethrows -> T {
        return try classNameChar.withUnsafeBufferPointer { ptr in
            try closure(ptr.baseAddress!)
        }
    }

    public func createWindow(title: String, size: Size) -> HWND {
        let handle = GetModuleHandleW(nil)

        let hwnd = CreateWindowExW(
            0,
            windowClass.lpszClassName,
            title.wide,
            WS_OVERLAPPEDWINDOW,

            // Size and position
            CW_USEDEFAULT, CW_USEDEFAULT, Int32(size.width), Int32(size.height),

            nil,    // Parent window
            nil,    // Menu
            handle, // Instance handle
            nil     // Additional application data
        )

        guard let hwnd = hwnd else {
            WinLogger.error("Failed to create window: \(Win32Error(win32: GetLastError()))")
            fatalError()
        }

        return hwnd
    }

    /// Registers a window as a subclass of this window class type.
    ///
    /// A procedure for window messages must be provided to be invoked with a
    /// pointer to `thisPointer` as the `dwRefData` parameter on the procedure
    /// invocation.
    public func registerSubClass(hwnd: HWND,
                                 thisPointer: AnyObject,
                                 procedure: @escaping SUBCLASSPROC) {

        _ = SetWindowSubclass(hwnd,
                              procedure,
                              UINT_PTR.max,
                              unsafeBitCast(thisPointer, to: DWORD_PTR.self))
    }
}
