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
        let event = makeKeyEventArgs(message)
        delegate?.keyboardManager(self, onKeyDown: event)

        return 0
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
        let str = String(fromUtf16: WCHAR(truncatingIfNeeded: message.wParam))

        // Enter key
        if str == "\r" || str == "\n" {
            var event = makeKeyEventArgs(message)
            event = event.withKeyCode(.enter)
            delegate?.keyboardManager(self, onKeyDown: event)

            return 0
        }

        // Handle regular character codes
        if !isKeyStateOn(VK_CONTROL) {
            // Ignore control characters that would otherwise have been passed
            // to onKeyDown()
            switch Int32(message.wParam) {
            case VK_BACK,   // Backspace
                 VK_RETURN, // Return (Enter key)
                 VK_TAB,    // Tab
                 10         // Line-feed
                 :
                return nil

            default:
                if let event = makeKeyPressEventArgs(message) {
                    delegate?.keyboardManager(self, onKeyPress: event)
                }
            }
        }

        return nil
    }

    func onKeyDeadChar(_ message: WindowMessage) -> LRESULT? {
        return nil
    }

    // MARK: Message translation

    private func makeKeyPressEventArgs(_ message: WindowMessage) -> KeyPressEventArgs? {
        guard let keyChar = Character(fromWM_CHAR: wchar_t(truncatingIfNeeded: message.wParam)) else {
            return nil
        }
        let modifiers: KeyboardModifier = makeKeyboardModifiers(message)
        return KeyPressEventArgs(keyChar: keyChar, modifiers: modifiers)
    }

    private func makeKeyEventArgs(_ message: WindowMessage) -> KeyEventArgs {
        let vkCode: Keys = Keys(fromWin32VK: LOWORD(message.wParam))
        let keyChar: String? = nil
        let modifiers: KeyboardModifier = makeKeyboardModifiers(message)

        return KeyEventArgs(keyCode: vkCode, keyChar: keyChar, modifiers: modifiers)
    }

    private func makeKeyboardModifiers(_ message: WindowMessage) -> KeyboardModifier {
        var modifiers: KeyboardModifier = []

        if IS_BIT_ON(HIWORD(message.lParam), KF_ALTDOWN) {
            modifiers.insert(.alt)
        }
        if isKeyStateOn(VK_CONTROL) {
            modifiers.insert(.control)
        }
        if isKeyStateOn(VK_SHIFT) {
            modifiers.insert(.shift)
        }

        return modifiers
    }
}

protocol Win32KeyboardManagerDelegate: AnyObject {
    func keyboardManager(_ manager: Win32KeyboardManager, onKeyPress event: KeyPressEventArgs)
    func keyboardManager(_ manager: Win32KeyboardManager, onKeyDown event: KeyEventArgs)
    func keyboardManager(_ manager: Win32KeyboardManager, onKeyUp event: KeyEventArgs)
}

/// Returns `true` if `GetKeyState` reports that a virtual key is currently held
/// down.
///
/// Win32 API reference: https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getkeystate
func isKeyStateOn(_ code: Int32) -> Bool {
    IS_HIBIT_ON(GetKeyState(code))
}
