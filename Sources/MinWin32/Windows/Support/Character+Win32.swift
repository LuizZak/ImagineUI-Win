import WinSDK

public extension Character {
    init?(fromWide wide: WCHAR) {
        guard let scalar = UnicodeScalar(wide) else { return nil }
        self.init(scalar)
    }

    init?(fromWM_CHAR wide: WCHAR) {
        // Values from 1 - 26 represent Ctrl+A...Ctrl+Z.

        guard let scalar = UnicodeScalar(wide) else { return nil }
        self.init(scalar)
    }
}
