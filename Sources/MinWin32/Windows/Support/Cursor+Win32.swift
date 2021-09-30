import WinSDK

/// Standard arrow
public let IDC_ARROW       = MAKEINTRESOURCE(32512)

/// I-beam
public let IDC_IBEAM       = MAKEINTRESOURCE(32513)

/// Hourglass
public let IDC_WAIT        = MAKEINTRESOURCE(32514)

/// Crosshair
public let IDC_CROSS       = MAKEINTRESOURCE(32515)

/// Vertical arrow
public let IDC_UPARROW     = MAKEINTRESOURCE(32516)

/// Obsolete for applications marked version 4.0 or later. Use IDC_SIZEALL.
@available(*, renamed: "IDC_SIZEALL")
public let IDC_SIZE        = MAKEINTRESOURCE(32640)

/// Obsolete for applications marked version 4.0 or later.
@available(*, renamed: "IDC_ARROW")
public let IDC_ICON        = MAKEINTRESOURCE(32641)

/// Double-pointed arrow pointing northwest and southeast
public let IDC_SIZENWSE    = MAKEINTRESOURCE(32642)

/// Double-pointed arrow pointing northeast and southwest
public let IDC_SIZENESW    = MAKEINTRESOURCE(32643)

/// Double-pointed arrow pointing west and east
public let IDC_SIZEWE      = MAKEINTRESOURCE(32644)

/// Double-pointed arrow pointing north and south
public let IDC_SIZENS      = MAKEINTRESOURCE(32645)

/// Four-pointed arrow pointing north, south, east, and west
public let IDC_SIZEALL     = MAKEINTRESOURCE(32646)

/// Slashed circle
public let IDC_NO          = MAKEINTRESOURCE(32648) /*not in win3.1 */

/// Hand
public let IDC_HAND        = MAKEINTRESOURCE(32649)

/// Standard arrow and small hourglass
public let IDC_APPSTARTING = MAKEINTRESOURCE(32650) /*not in win3.1 */

/// Arrow and question mark
public let IDC_HELP        = MAKEINTRESOURCE(32651)

public let IDC_PIN         = MAKEINTRESOURCE(32671)

public let IDC_PERSON      = MAKEINTRESOURCE(32672)

@_transparent
public func MAKEINTRESOURCE<T: FixedWidthInteger>(_ i: T) -> LPWSTR? {
    MAKEINTRESOURCEW(i)
}

@_transparent
public func MAKEINTRESOURCEW<T: FixedWidthInteger>(_ i: T) -> LPWSTR? {
    LPWSTR(bitPattern: UInt(WORD(i)))
}

@_transparent
public func hCursorToLONG_PTR(_ hCursor: HCURSOR?) -> LONG_PTR {
    guard let hCursor = hCursor else {
        return 0
    }

    return LONG_PTR(bitPattern: UInt64(UInt(bitPattern: hCursor)))
}
