import ImagineUI
import WinSDK

extension Keys {
    init<T: FixedWidthInteger>(fromWin32VK vk: T) {
        self.init(rawValue: Int(vk))
    }
}
