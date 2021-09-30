import ImagineUI
import WinSDK
import MinWin32

extension Win32Keys {
    var asKeys: Keys {
        .init(rawValue: rawValue)
    }
}
