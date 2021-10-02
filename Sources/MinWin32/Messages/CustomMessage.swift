import WinSDK

public protocol CustomMessage {
    static var messageName: String { get }

    var uMsg: UINT { get }
    var wParam: WPARAM { get }
    var lParam: LPARAM { get }
}

internal func registerMessage(name: String) throws -> UINT {
    assert(!name.isEmpty)

    return try name.withUnsafeLPCWSTRPointer { ptr in
        let result = RegisterWindowMessageW(ptr)
        if result == 0 {
            throw Win32Error(win32: GetLastError())
        }

        return result
    }
}
