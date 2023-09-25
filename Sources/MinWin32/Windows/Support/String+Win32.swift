import Foundation
import WinSDK

public extension String {
    init(from utf16: [WCHAR]) {
        self = utf16.withUnsafeBufferPointer {
            String(decodingCString: $0.baseAddress!, as: UTF16.self)
        }
    }

    init(from utf16: UnsafePointer<WCHAR>) {
        self = String(decodingCString: utf16, as: UTF16.self)
    }

    init(fromUtf16 utf16: WCHAR) {
        self.init(from: [utf16])
    }

    /// Initializes a string by allocating a buffer of the desired length, using
    /// a provided closure to fill the buffer, which is then decoded as a
    /// null-terminated C-string with a given encoding.
    init(
        decodingCStringBufferLength length: Int,
        as encoding: String.Encoding = .utf8,
        _ fillBuffer: (UnsafeMutableBufferPointer<UInt8>) throws -> Void
    ) rethrows {
        precondition(length >= 0)

        var buffer: [UInt8] = .init(repeating: 0, count: length)

        try buffer.withUnsafeMutableBufferPointer { pointer in
            try fillBuffer(pointer)
        }

        // Handle zero-length strings
        guard length >= 1 else {
            self = ""
            return
        }

        // Verify the string is null-terminated
        precondition(buffer.contains(0))

        self.init(cString: buffer)
    }

    /// Initializes a string by allocating a buffer of WCHAR elements of the desired
    /// length, using a provided closure to fill the buffer, which is then decoded
    /// as a null-terminated UTF16 C-string.
    init(
        decodingWideCStringBufferLength length: Int,
        _ fillBuffer: (UnsafeMutableBufferPointer<WCHAR>) throws -> Void
    ) rethrows {
        precondition(length >= 0)

        var buffer: [WCHAR] = .init(repeating: 0, count: length)

        try buffer.withUnsafeMutableBufferPointer { pointer in
            try fillBuffer(pointer)
        }

        // Handle zero-length strings
        guard length >= 1 else {
            self = ""
            return
        }

        // Verify the string is null-terminated
        precondition(buffer.contains(0))

        self.init(from: buffer)
    }
}

public extension String {
    var wide: [WCHAR] {
        Array<WCHAR>(from: self)
    }

    func withUnsafeWideBuffer<T>(_ block: (UnsafeBufferPointer<WCHAR>) throws -> T) rethrows -> T {
        let w = wide
        return try w.withUnsafeBufferPointer { p in
            return try block(p)
        }
    }

    /// Invokes a given block with a pointer to a null-terminated UTF16 string
    /// pointer.
    func withUnsafeLPCWSTRPointer<T>(_ block: (LPCWSTR) throws -> T) rethrows -> T {
        let w = wide
        return try w.withUnsafeBufferPointer { p in
            return try block(p.baseAddress!)
        }
    }

    /// Invokes a given block with a pointer to a null-terminated UTF8 string
    /// pointer.
    func withUnsafeLPCSTRPointer<T>(_ block: (LPCSTR) throws -> T) rethrows -> T {
        try withCString { p in
            try block(p)
        }
    }
}
