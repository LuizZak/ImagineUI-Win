import WinSDK
import ImagineUI

/// Digests keyboard input and invokes a delegate with information about processed
/// input keys.
class Win32KeyboardManager {
    let hwnd: HWND
    weak var delegate: Win32KeyboardManagerDelegate?

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

protocol Win32KeyboardManagerDelegate: AnyObject {
    func keyboardManager(_ manager: Win32KeyboardManager, onKeyPress event: KeyPressEventArgs)
    func keyboardManager(_ manager: Win32KeyboardManager, onKeyDown event: KeyEventArgs)
    func keyboardManager(_ manager: Win32KeyboardManager, onKeyUp event: KeyEventArgs)
}
