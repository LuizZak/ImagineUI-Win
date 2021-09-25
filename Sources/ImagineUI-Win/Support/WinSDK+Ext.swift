import WinSDK

@_transparent
internal func LOWORD<T: FixedWidthInteger>(_ dword: T) -> WORD {
    WORD(DWORD_PTR(dword) >>  0 & 0xffff)
}

@_transparent
internal func HIWORD<T: FixedWidthInteger>(_ dword: T) -> WORD {
    WORD(DWORD_PTR(dword) >> 16 & 0xffff)
}

@_transparent
internal func SUCCEEDED<T: FixedWidthInteger>(_ hr: T) -> Bool {
    HRESULT(hr) >= 0
}

@_transparent
internal func FAILED<T: FixedWidthInteger>(_ hr: T) -> Bool {
    HRESULT(hr) < 0
}

@_transparent
internal func IS_ERROR<T: FixedWidthInteger>(_ hr: T) -> Bool {
    (UInt32(hr) >> 31) == SEVERITY_ERROR
}
