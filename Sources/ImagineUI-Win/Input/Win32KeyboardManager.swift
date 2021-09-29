import WinSDK

class Win32KeyboardManager {
    let hwnd: HWND

    init(hwnd: HWND) {
        self.hwnd = hwnd
    }

    func onKeyDown(_ message: WindowMessage) -> LRESULT? {
        return nil
    }

    func onKeyUp(_ message: WindowMessage) -> LRESULT? {
        return nil
    }

    func onSystemKeyDown(_ message: WindowMessage) -> LRESULT? {
        return nil
    }

    func onSystemKeyUp(_ message: WindowMessage) -> LRESULT? {
        return nil
    }

    func onKeyCharDown(_ message: WindowMessage) -> LRESULT? {
        return nil
    }

    func onKeyChar(_ message: WindowMessage) -> LRESULT? {
        return nil
    }
}
