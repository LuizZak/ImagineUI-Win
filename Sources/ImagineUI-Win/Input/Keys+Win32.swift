import ImagineUI
import WinSDK

extension Keys {
    init<T: FixedWidthInteger>(fromWin32VK vk: T) {
        self.init(rawValue: Int(vk))
    }

    init(fromWin32WParam wParam: WPARAM) {
        self.init(rawValue: Int(wParam))
    }
}
