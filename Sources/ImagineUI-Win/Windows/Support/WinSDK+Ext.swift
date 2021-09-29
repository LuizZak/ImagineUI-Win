import WinSDK

@_transparent
internal func LOWORD<T: FixedWidthInteger>(_ dword: T) -> WORD {
    WORD(truncatingIfNeeded: DWORD_PTR(truncatingIfNeeded: dword) >>  0 & 0xffff)
}

@_transparent
internal func HIWORD<T: FixedWidthInteger>(_ dword: T) -> WORD {
    WORD(truncatingIfNeeded: DWORD_PTR(truncatingIfNeeded: dword) >> 16 & 0xffff)
}

@_transparent
internal func IS_HIBIT_ON<T: FixedWidthInteger>(_ dword: T) -> Bool {
    (dword >> (T.bitWidth - 1)) & 1 == 1
}

@_transparent
internal func IS_LOBIT_ON<T: FixedWidthInteger>(_ dword: T) -> Bool {
    dword & 1 == 1
}

@_transparent
internal func IS_BIT_ON<T: FixedWidthInteger>(_ lp: WPARAM, _ mask: T) -> Bool {
    T(lp) & mask != 0
}

@_transparent
internal func IS_BIT_ON<T: FixedWidthInteger>(_ lp: LPARAM, _ mask: T) -> Bool {
    T(lp) & mask != 0
}

@_transparent
internal func IS_BIT_ON<T: FixedWidthInteger>(_ lp: WORD, _ mask: T) -> Bool {
    T(lp) & mask != 0
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

@_transparent
internal func GET_X_LPARAM<T: FixedWidthInteger>(_ lp: T) -> WORD {
    LOWORD(lp)
}

@_transparent
internal func GET_Y_LPARAM<T: FixedWidthInteger>(_ lp: T) -> WORD {
    HIWORD(lp)
}

@_transparent
internal func GET_WHEEL_DELTA_WPARAM<T: FixedWidthInteger>(_ wParam: T) -> Int16 {
     Int16(bitPattern: HIWORD(wParam))
}
