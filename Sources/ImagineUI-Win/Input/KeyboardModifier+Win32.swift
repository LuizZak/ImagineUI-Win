import ImagineUI
import MinWin32

extension Win32KeyboardModifier {
    var asKeyboardModifier: KeyboardModifier {
        .init(rawValue: rawValue)
    }
}
