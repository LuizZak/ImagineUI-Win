import ImagineUI
import WinSDK
import MinWin32

extension Win32KeyPressEventArgs {
    var asKeyPressEventArgs: KeyPressEventArgs {
        .init(keyChar: keyChar, modifiers: modifiers.asKeyboardModifier)
    }
}
