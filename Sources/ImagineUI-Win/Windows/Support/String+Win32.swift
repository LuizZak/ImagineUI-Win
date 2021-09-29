import WinSDK

extension String {
    internal init(from utf16: [WCHAR]) {
        self = utf16.withUnsafeBufferPointer {
            String(decodingCString: $0.baseAddress!, as: UTF16.self)
        }
    }

    internal init(from utf16: UnsafePointer<WCHAR>) {
        self = String(decodingCString: utf16, as: UTF16.self)
    }

    internal init(fromUtf16 utf16: WCHAR) {
        self.init(from: [utf16])
    }
}

extension String {
    public var wide: [WCHAR] {
        return Array<WCHAR>(from: self)
    }

    public func withUnsafeWideBuffer<T>(_ block: (UnsafeBufferPointer<WCHAR>) throws -> T) rethrows -> T {
        let w = wide
        return try w.withUnsafeBufferPointer { p in
            return try block(p)
        }
    }

    public func withUnsafeLPCWSTRPointer<T>(_ block: (LPCWSTR) throws -> T) rethrows -> T {
        let w = wide
        return try w.withUnsafeBufferPointer { p in
            return try block(p.baseAddress!)
        }
    }
}
