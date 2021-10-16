import WinSDK

public extension String {
    init(from utf16: WCHAR_16) {
        self = withUnsafeBytes(of: utf16) {
            let buffer = $0.bindMemory(to: WCHAR.self)

            return String(from: Array(buffer))
        }
    }

    init(from utf16: WCHAR_32) {
        self = withUnsafeBytes(of: utf16) {
            let buffer = $0.bindMemory(to: WCHAR.self)

            return String(from: Array(buffer))
        }
    }

    init(from utf16: WCHAR_64) {
        self = withUnsafeBytes(of: utf16) {
            let buffer = $0.bindMemory(to: WCHAR.self)

            return String(from: Array(buffer))
        }
    }

    init(from utf16: WCHAR_128) {
        self = withUnsafeBytes(of: utf16) {
            let buffer = $0.bindMemory(to: WCHAR.self)

            return String(from: Array(buffer))
        }
    }

    init(from utf16: WCHAR_256) {
        self = withUnsafeBytes(of: utf16) {
            let buffer = $0.bindMemory(to: WCHAR.self)

            return String(from: Array(buffer))
        }
    }
}

/// Common static 16-character Win32 string type.
public typealias WCHAR_16 = (
    WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, // 8
    WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR  // 16
)

/// Common static 32-character Win32 string type.
public typealias WCHAR_32 = (
    WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, // 8
    WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, // 16
    WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR,
    WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR  // 32
)

/// Common static 64-character Win32 string type.
public typealias WCHAR_64 = (
    WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, // 8
    WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, // 16
    WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR,
    WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, // 32
    WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR,
    WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR,
    WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR,
    WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR  // 64
)

/// Common static 128-character Win32 string type.
public typealias WCHAR_128 = (
    WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, // 8
    WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, // 16
    WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR,
    WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, // 32
    WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR,
    WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR,
    WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR,
    WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, // 64
    WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR,
    WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR,
    WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR,
    WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR,
    WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR,
    WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR,
    WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR,
    WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR  // 128
)

/// Common static 256-character Win32 string type.
public typealias WCHAR_256 = (
    WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, // 8
    WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, // 16
    WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR,
    WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, // 32
    WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR,
    WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR,
    WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR,
    WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, // 64
    WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR,
    WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR,
    WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR,
    WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR,
    WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR,
    WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR,
    WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR,
    WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, // 128
    WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR,
    WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR,
    WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR,
    WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR,
    WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR,
    WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR,
    WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR,
    WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR,
    WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR,
    WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR,
    WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR,
    WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR,
    WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR,
    WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR,
    WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR,
    WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR, WCHAR  // 256
)