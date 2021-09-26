import WinSDK

/// Standard arrow
let IDC_ARROW       = MAKEINTRESOURCE(32512)

/// I-beam
let IDC_IBEAM       = MAKEINTRESOURCE(32513)

/// Hourglass
let IDC_WAIT        = MAKEINTRESOURCE(32514)

/// Crosshair
let IDC_CROSS       = MAKEINTRESOURCE(32515)

/// Vertical arrow
let IDC_UPARROW     = MAKEINTRESOURCE(32516)

/// Obsolete for applications marked version 4.0 or later. Use IDC_SIZEALL.
@available(*, renamed: "IDC_SIZEALL")
let IDC_SIZE        = MAKEINTRESOURCE(32640)

/// Obsolete for applications marked version 4.0 or later.
@available(*, renamed: "IDC_ARROW")
let IDC_ICON        = MAKEINTRESOURCE(32641)

/// Double-pointed arrow pointing northwest and southeast
let IDC_SIZENWSE    = MAKEINTRESOURCE(32642)

/// Double-pointed arrow pointing northeast and southwest
let IDC_SIZENESW    = MAKEINTRESOURCE(32643)

/// Double-pointed arrow pointing west and east
let IDC_SIZEWE      = MAKEINTRESOURCE(32644)

/// Double-pointed arrow pointing north and south
let IDC_SIZENS      = MAKEINTRESOURCE(32645)

/// Four-pointed arrow pointing north, south, east, and west
let IDC_SIZEALL     = MAKEINTRESOURCE(32646)

/// Slashed circle
let IDC_NO          = MAKEINTRESOURCE(32648) /*not in win3.1 */

/// Hand
let IDC_HAND        = MAKEINTRESOURCE(32649)

/// Standard arrow and small hourglass
let IDC_APPSTARTING = MAKEINTRESOURCE(32650) /*not in win3.1 */

/// Arrow and question mark
let IDC_HELP        = MAKEINTRESOURCE(32651)

let IDC_PIN         = MAKEINTRESOURCE(32671)

let IDC_PERSON      = MAKEINTRESOURCE(32672)

@_transparent
func MAKEINTRESOURCE<T: FixedWidthInteger>(_ i: T) -> LPWSTR? {
    MAKEINTRESOURCEW(i)
}

@_transparent
func MAKEINTRESOURCEW<T: FixedWidthInteger>(_ i: T) -> LPWSTR? {
    LPWSTR(bitPattern: UInt(WORD(i)))
}

@_transparent
func hCursorToLONG_PTR(_ hCursor: HCURSOR?) -> LONG_PTR {
    guard let hCursor = hCursor else {
        return 0
    }

    return LONG_PTR(bitPattern: UInt64(UInt(bitPattern: hCursor)))
}
