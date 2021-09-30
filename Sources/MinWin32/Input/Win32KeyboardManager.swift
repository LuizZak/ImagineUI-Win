import WinSDK

/// Digests keyboard input and invokes a delegate with information about processed
/// input keys.
public class Win32KeyboardManager {
    let hwnd: HWND
    public weak var delegate: Win32KeyboardManagerDelegate?

    public init(hwnd: HWND) {
        self.hwnd = hwnd
    }

    public func onKeyDown(_ message: WindowMessage) -> LRESULT? {
        let event = makeKeyEventArgs(message)
        delegate?.keyboardManager(self, onKeyDown: event)

        return 0
    }

    public func onKeyUp(_ message: WindowMessage) -> LRESULT? {
        return nil
    }

    public func onSystemKeyDown(_ message: WindowMessage) -> LRESULT? {
        return nil
    }

    public func onSystemKeyUp(_ message: WindowMessage) -> LRESULT? {
        return nil
    }

    public func onKeyCharDown(_ message: WindowMessage) -> LRESULT? {
        return nil
    }

    public func onKeyChar(_ message: WindowMessage) -> LRESULT? {
        let str = String(fromUtf16: WCHAR(truncatingIfNeeded: message.wParam))

        // Enter key
        if str == "\r" || str == "\n" {
            var event = makeKeyEventArgs(message)
            event.keyCode = .enter
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

    public func onKeyDeadChar(_ message: WindowMessage) -> LRESULT? {
        return nil
    }

    // MARK: Message translation

    private func makeKeyPressEventArgs(_ message: WindowMessage) -> Win32KeyPressEventArgs? {
        guard let keyChar = Character(fromWM_CHAR: wchar_t(truncatingIfNeeded: message.wParam)) else {
            return nil
        }
        let modifiers: Win32KeyboardModifier = makeKeyboardModifiers(message)
        return Win32KeyPressEventArgs(keyChar: keyChar, modifiers: modifiers)
    }

    private func makeKeyEventArgs(_ message: WindowMessage) -> Win32KeyEventArgs {
        let vkCode: Win32Keys = Win32Keys(fromWin32VK: LOWORD(message.wParam))
        let keyChar: String? = nil
        let modifiers: Win32KeyboardModifier = makeKeyboardModifiers(message)

        return Win32KeyEventArgs(keyCode: vkCode, keyChar: keyChar, modifiers: modifiers)
    }

    private func makeKeyboardModifiers(_ message: WindowMessage) -> Win32KeyboardModifier {
        var modifiers: Win32KeyboardModifier = []

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

public protocol Win32KeyboardManagerDelegate: AnyObject {
    func keyboardManager(_ manager: Win32KeyboardManager, onKeyPress event: Win32KeyPressEventArgs)
    func keyboardManager(_ manager: Win32KeyboardManager, onKeyDown event: Win32KeyEventArgs)
    func keyboardManager(_ manager: Win32KeyboardManager, onKeyUp event: Win32KeyEventArgs)
}

/// Returns `true` if `GetKeyState` reports that a virtual key is currently held
/// down.
///
/// Win32 API reference: https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getkeystate
@_transparent
public func isKeyStateOn(_ code: Int32) -> Bool {
    IS_HIBIT_ON(GetKeyState(code))
}
