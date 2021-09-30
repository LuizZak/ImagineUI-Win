import ImagineUI
import MinWin32

extension Win32KeyEventArgs {
    var asKeyEventArgs: KeyEventArgs {
        .init(keyCode: keyCode.asKeys, keyChar: keyChar, modifiers: modifiers.asKeyboardModifier)
    }
}
