import WinSDK

public struct Win32Keys: Hashable {
    public var rawValue: Int

    @_transparent
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    @_transparent
    public init<T: FixedWidthInteger>(fromWin32VK vk: T) {
        self.init(rawValue: Int(vk))
    }

    @_transparent
    public init(fromWin32WParam wParam: WPARAM) {
        self.init(rawValue: Int(wParam))
    }

    @_transparent
    public func hasModifier(_ key: Win32Keys) -> Bool {
        return (rawValue & key.rawValue) == key.rawValue
    }

    @_transparent
    public func hasModifier(_ modifier: Win32KeyboardModifier) -> Bool {
        return (rawValue & modifier.rawValue) == modifier.rawValue
    }
}

public extension Win32Keys {
    /// The A key.
    static let a = Win32Keys(rawValue: 65)

    /// The add key.
    static let add = Win32Keys(rawValue: 107)

    /// The ALT modifier key.
    static let alt = Win32Keys(rawValue: 262144)

    /// The application key (Microsoft Natural Keyboard).
    static let apps = Win32Keys(rawValue: 93)

    /// The ATTN key.
    static let attn = Win32Keys(rawValue: 246)

    /// The B key.
    static let b = Win32Keys(rawValue: 66)

    /// The BACKSPACE key.
    static let back = Win32Keys(rawValue: 8)

    /// The browser back key (Windows 2000 or later).
    static let browserBack = Win32Keys(rawValue: 166)

    /// The browser favorites key (Windows 2000 or later).
    static let browserFavorites = Win32Keys(rawValue: 171)

    /// The browser forward key (Windows 2000 or later).
    static let browserForward = Win32Keys(rawValue: 167)

    /// The browser home key (Windows 2000 or later).
    static let browserHome = Win32Keys(rawValue: 172)

    /// The browser refresh key (Windows 2000 or later).
    static let browserRefresh = Win32Keys(rawValue: 168)

    /// The browser search key (Windows 2000 or later).
    static let browserSearch = Win32Keys(rawValue: 170)

    /// The browser stop key (Windows 2000 or later).
    static let browserStop = Win32Keys(rawValue: 169)

    /// The C key.
    static let c = Win32Keys(rawValue: 67)

    /// The CANCEL key.
    static let cancel = Win32Keys(rawValue: 3)

    /// The CAPS LOCK key.
    static let capital = Win32Keys(rawValue: 20)

    /// The CAPS LOCK key.
    static let capsLock = Win32Keys(rawValue: 20)

    /// The CLEAR key.
    static let clear = Win32Keys(rawValue: 12)

    /// The CTRL modifier key.
    static let control = Win32Keys(rawValue: 131072)

    /// The CTRL key.
    static let controlKey = Win32Keys(rawValue: 17)

    /// The CRSEL key.
    static let crsel = Win32Keys(rawValue: 247)

    /// The D key.
    static let d = Win32Keys(rawValue: 68)

    /// The 0 key.
    static let d0 = Win32Keys(rawValue: 48)

    /// The 1 key.
    static let d1 = Win32Keys(rawValue: 49)

    /// The 2 key.
    static let d2 = Win32Keys(rawValue: 50)

    /// The 3 key.
    static let d3 = Win32Keys(rawValue: 51)

    /// The 4 key.
    static let d4 = Win32Keys(rawValue: 52)

    /// The 5 key.
    static let d5 = Win32Keys(rawValue: 53)

    /// The 6 key.
    static let d6 = Win32Keys(rawValue: 54)

    /// The 7 key.
    static let d7 = Win32Keys(rawValue: 55)

    /// The 8 key.
    static let d8 = Win32Keys(rawValue: 56)

    /// The 9 key.
    static let d9 = Win32Keys(rawValue: 57)

    /// The decimal key.
    static let decimal = Win32Keys(rawValue: 110)

    /// The DEL key.
    static let delete = Win32Keys(rawValue: 46)

    /// The divide key.
    static let divide = Win32Keys(rawValue: 111)

    /// The DOWN ARROW key.
    static let down = Win32Keys(rawValue: 40)

    /// The E key.
    static let e = Win32Keys(rawValue: 69)

    /// The END key.
    static let end = Win32Keys(rawValue: 35)

    /// The ENTER key.
    static let enter = Win32Keys(rawValue: 13)

    /// The ERASE EOF key.
    static let eraseEof = Win32Keys(rawValue: 249)

    /// The ESC key.
    static let escape = Win32Keys(rawValue: 27)

    /// The EXECUTE key.
    static let execute = Win32Keys(rawValue: 43)

    /// The EXSEL key.
    static let exsel = Win32Keys(rawValue: 248)

    /// The F key.
    static let f = Win32Keys(rawValue: 70)

    /// The F1 key.
    static let f1 = Win32Keys(rawValue: 112)

    /// The F10 key.
    static let f10 = Win32Keys(rawValue: 121)

    /// The F11 key.
    static let f11 = Win32Keys(rawValue: 122)

    /// The F12 key.
    static let f12 = Win32Keys(rawValue: 123)

    /// The F13 key.
    static let f13 = Win32Keys(rawValue: 124)

    /// The F14 key.
    static let f14 = Win32Keys(rawValue: 125)

    /// The F15 key.
    static let f15 = Win32Keys(rawValue: 126)

    /// The F16 key.
    static let f16 = Win32Keys(rawValue: 127)

    /// The F17 key.
    static let f17 = Win32Keys(rawValue: 128)

    /// The F18 key.
    static let f18 = Win32Keys(rawValue: 129)

    /// The F19 key.
    static let f19 = Win32Keys(rawValue: 130)

    /// The F2 key.
    static let f2 = Win32Keys(rawValue: 113)

    /// The F20 key.
    static let f20 = Win32Keys(rawValue: 131)

    /// The F21 key.
    static let f21 = Win32Keys(rawValue: 132)

    /// The F22 key.
    static let f22 = Win32Keys(rawValue: 133)

    /// The F23 key.
    static let f23 = Win32Keys(rawValue: 134)

    /// The F24 key.
    static let f24 = Win32Keys(rawValue: 135)

    /// The F3 key.
    static let f3 = Win32Keys(rawValue: 114)

    /// The F4 key.
    static let f4 = Win32Keys(rawValue: 115)

    /// The F5 key.
    static let f5 = Win32Keys(rawValue: 116)

    /// The F6 key.
    static let f6 = Win32Keys(rawValue: 117)

    /// The F7 key.
    static let f7 = Win32Keys(rawValue: 118)

    /// The F8 key.
    static let f8 = Win32Keys(rawValue: 119)

    /// The F9 key.
    static let f9 = Win32Keys(rawValue: 120)

    /// The IME final mode key.
    static let finalMode = Win32Keys(rawValue: 24)

    /// The G key.
    static let g = Win32Keys(rawValue: 71)

    /// The H key.
    static let h = Win32Keys(rawValue: 72)

    /// The IME Hanguel mode key. (maintained for compatibility; use HangulMode)
    static let hanguelMode = Win32Keys(rawValue: 21)

    /// The IME Hangul mode key.
    static let hangulMode = Win32Keys(rawValue: 21)

    /// The IME Hanja mode key.
    static let hanjaMode = Win32Keys(rawValue: 25)

    /// The HELP key.
    static let help = Win32Keys(rawValue: 47)

    /// The HOME key.
    static let home = Win32Keys(rawValue: 36)

    /// The I key.
    static let i = Win32Keys(rawValue: 73)

    /// The IME accept key, replaces IMEAceept.
    static let imeAccept = Win32Keys(rawValue: 30)

    /// The IME accept key. Obsolete, use IMEAccept instead.
    static let imeAceept = Win32Keys(rawValue: 30)

    /// The IME convert key.
    static let imeConvert = Win32Keys(rawValue: 28)

    /// The IME mode change key.
    static let imeModeChange = Win32Keys(rawValue: 31)

    /// The IME nonconvert key.
    static let imeNonconvert = Win32Keys(rawValue: 29)

    /// The INS key.
    static let insert = Win32Keys(rawValue: 45)

    /// The J key.
    static let j = Win32Keys(rawValue: 74)

    /// The IME Junja mode key.
    static let junjaMode = Win32Keys(rawValue: 23)

    /// The K key.
    static let k = Win32Keys(rawValue: 75)

    /// The IME Kana mode key.
    static let kanaMode = Win32Keys(rawValue: 21)

    /// The IME Kanji mode key.
    static let kanjiMode = Win32Keys(rawValue: 25)

    /// The bitmask to extract a key code from a key value.
    static let keyCode = Win32Keys(rawValue: 65535)

    /// The L key.
    static let l = Win32Keys(rawValue: 76)

    /// The start application one key (Windows 2000 or later).
    static let launchApplication1 = Win32Keys(rawValue: 182)

    /// The start application two key (Windows 2000 or later).
    static let launchApplication2 = Win32Keys(rawValue: 183)

    /// The launch mail key (Windows 2000 or later).
    static let launchMail = Win32Keys(rawValue: 180)

    /// The left mouse button.
    static let lButton = Win32Keys(rawValue: 1)

    /// The left CTRL key.
    static let lControlKey = Win32Keys(rawValue: 162)

    /// The LEFT ARROW key.
    static let left = Win32Keys(rawValue: 37)

    /// The LINEFEED key.
    static let lineFeed = Win32Keys(rawValue: 10)

    /// The left ALT key.
    static let lMenu = Win32Keys(rawValue: 164)

    /// The left SHIFT key.
    static let lShiftKey = Win32Keys(rawValue: 160)

    /// The left Windows logo key (Microsoft Natural Keyboard).
    static let lWin = Win32Keys(rawValue: 91)

    /// The M key.
    static let m = Win32Keys(rawValue: 77)

    /// The middle mouse button (three-button mouse).
    static let mButton = Win32Keys(rawValue: 4)

    /// The media next track key (Windows 2000 or later).
    static let mediaNextTrack = Win32Keys(rawValue: 176)

    /// The media play pause key (Windows 2000 or later).
    static let mediaPlayPause = Win32Keys(rawValue: 179)

    /// The media previous track key (Windows 2000 or later).
    static let mediaPreviousTrack = Win32Keys(rawValue: 177)

    /// The media Stop key (Windows 2000 or later).
    static let mediaStop = Win32Keys(rawValue: 178)

    /// The ALT key.
    static let menu = Win32Keys(rawValue: 18)

    /// The bitmask to extract modifiers from a key value.
    static let modifiers = Win32Keys(rawValue: -65536)

    /// The multiply key.
    static let multiply = Win32Keys(rawValue: 106)

    /// The N key.
    static let n = Win32Keys(rawValue: 78)

    /// The PAGE DOWN key.
    static let next = Win32Keys(rawValue: 34)

    /// A constant reserved for future use.
    static let noName = Win32Keys(rawValue: 252)

    /// No key pressed.
    static let none = Win32Keys(rawValue: 0)

    /// The NUM LOCK key.
    static let numLock = Win32Keys(rawValue: 144)

    /// The 0 key on the numeric keypad.
    static let numPad0 = Win32Keys(rawValue: 96)

    /// The 1 key on the numeric keypad.
    static let numPad1 = Win32Keys(rawValue: 97)

    /// The 2 key on the numeric keypad.
    static let numPad2 = Win32Keys(rawValue: 98)

    /// The 3 key on the numeric keypad.
    static let numPad3 = Win32Keys(rawValue: 99)

    /// The 4 key on the numeric keypad.
    static let numPad4 = Win32Keys(rawValue: 100)

    /// The 5 key on the numeric keypad.
    static let numPad5 = Win32Keys(rawValue: 101)

    /// The 6 key on the numeric keypad.
    static let numPad6 = Win32Keys(rawValue: 102)

    /// The 7 key on the numeric keypad.
    static let numPad7 = Win32Keys(rawValue: 103)

    /// The 8 key on the numeric keypad.
    static let numPad8 = Win32Keys(rawValue: 104)

    /// The 9 key on the numeric keypad.
    static let numPad9 = Win32Keys(rawValue: 105)

    /// The O key.
    static let o = Win32Keys(rawValue: 79)

    /// The OEM 1 key.
    static let oem1 = Win32Keys(rawValue: 186)

    /// The OEM 102 key.
    static let oem102 = Win32Keys(rawValue: 226)

    /// The OEM 2 key.
    static let oem2 = Win32Keys(rawValue: 191)

    /// The OEM 3 key.
    static let oem3 = Win32Keys(rawValue: 192)

    /// The OEM 4 key.
    static let oem4 = Win32Keys(rawValue: 219)

    /// The OEM 5 key.
    static let oem5 = Win32Keys(rawValue: 220)

    /// The OEM 6 key.
    static let oem6 = Win32Keys(rawValue: 221)

    /// The OEM 7 key.
    static let oem7 = Win32Keys(rawValue: 222)

    /// The OEM 8 key.
    static let oem8 = Win32Keys(rawValue: 223)

    /// The OEM angle bracket or backslash key on the RT 102 key keyboard
    /// (Windows 2000 or later).
    static let oemBackslash = Win32Keys(rawValue: 226)

    /// The CLEAR key.
    static let oemClear = Win32Keys(rawValue: 254)

    /// The OEM close bracket key on a US standard keyboard (Windows 2000 or later).
    static let oemCloseBrackets = Win32Keys(rawValue: 221)

    /// The OEM comma key on any country/region keyboard (Windows 2000 or later).
    static let oemcomma = Win32Keys(rawValue: 188)

    /// The OEM minus key on any country/region keyboard (Windows 2000 or later).
    static let oemMinus = Win32Keys(rawValue: 189)

    /// The OEM open bracket key on a US standard keyboard (Windows 2000 or later).
    static let oemOpenBrackets = Win32Keys(rawValue: 219)

    /// The OEM period key on any country/region keyboard (Windows 2000 or later).
    static let oemPeriod = Win32Keys(rawValue: 190)

    /// The OEM pipe key on a US standard keyboard (Windows 2000 or later).
    static let oemPipe = Win32Keys(rawValue: 220)

    /// The OEM plus key on any country/region keyboard (Windows 2000 or later).
    static let oemplus = Win32Keys(rawValue: 187)

    /// The OEM question mark key on a US standard keyboard (Windows 2000 or later).
    static let oemQuestion = Win32Keys(rawValue: 191)

    /// The OEM singled/double quote key on a US standard keyboard (Windows 2000
    /// or later).
    static let oemQuotes = Win32Keys(rawValue: 222)

    /// The OEM Semicolon key on a US standard keyboard (Windows 2000 or later).
    static let oemSemicolon = Win32Keys(rawValue: 186)

    /// The OEM tilde key on a US standard keyboard (Windows 2000 or later).
    static let oemtilde = Win32Keys(rawValue: 192)

    /// The P key.
    static let p = Win32Keys(rawValue: 80)

    /// The PA1 key.
    static let pa1 = Win32Keys(rawValue: 253)

    /// Used to pass Unicode characters as if they were keystrokes. The Packet
    /// /key value is the low word of a 32-bit virtual-key value used for
    /// non-keyboard input methods.
    static let packet = Win32Keys(rawValue: 231)

    /// The PAGE DOWN key.
    static let pageDown = Win32Keys(rawValue: 34)

    /// The PAGE UP key.
    static let pageUp = Win32Keys(rawValue: 33)

    /// The PAUSE key.
    static let pause = Win32Keys(rawValue: 19)

    /// The PLAY key.
    static let play = Win32Keys(rawValue: 250)

    /// The PRINT key.
    static let print = Win32Keys(rawValue: 42)

    /// The PRINT SCREEN key.
    static let printScreen = Win32Keys(rawValue: 44)

    /// The PAGE UP key.
    static let prior = Win32Keys(rawValue: 33)

    /// The PROCESS KEY key.
    static let processKey = Win32Keys(rawValue: 229)

    /// The Q key.
    static let q = Win32Keys(rawValue: 81)

    /// The R key.
    static let r = Win32Keys(rawValue: 82)

    /// The right mouse button.
    static let rButton = Win32Keys(rawValue: 2)

    /// The right CTRL key.
    static let rControlKey = Win32Keys(rawValue: 163)

    /// The RETURN key.
    static let `return` = Win32Keys(rawValue: 13)

    /// The RIGHT ARROW key.
    static let right = Win32Keys(rawValue: 39)

    /// The right ALT key.
    static let rMenu = Win32Keys(rawValue: 165)

    /// The right SHIFT key.
    static let rShiftKey = Win32Keys(rawValue: 161)

    /// The right Windows logo key (Microsoft Natural Keyboard).
    static let rWin = Win32Keys(rawValue: 92)

    /// The S key.
    static let s = Win32Keys(rawValue: 83)

    /// The SCROLL LOCK key.
    static let scroll = Win32Keys(rawValue: 145)

    /// The SELECT key.
    static let select = Win32Keys(rawValue: 41)

    /// The select media key (Windows 2000 or later).
    static let selectMedia = Win32Keys(rawValue: 181)

    /// The separator key.
    static let separator = Win32Keys(rawValue: 108)

    /// The SHIFT modifier key.
    static let shift = Win32Keys(rawValue: 65536)

    /// The SHIFT key.
    static let shiftKey = Win32Keys(rawValue: 16)

    /// The computer sleep key.
    static let sleep = Win32Keys(rawValue: 95)

    /// The PRINT SCREEN key.
    static let snapshot = Win32Keys(rawValue: 44)

    /// The SPACEBAR key.
    static let space = Win32Keys(rawValue: 32)

    /// The subtract key.
    static let subtract = Win32Keys(rawValue: 109)

    /// The T key.
    static let t = Win32Keys(rawValue: 84)

    /// The TAB key.
    static let tab = Win32Keys(rawValue: 9)

    /// The U key.
    static let u = Win32Keys(rawValue: 85)

    /// The UP ARROW key.
    static let up = Win32Keys(rawValue: 38)

    /// The V key.
    static let v = Win32Keys(rawValue: 86)

    /// The volume down key (Windows 2000 or later).
    static let volumeDown = Win32Keys(rawValue: 174)

    /// The volume mute key (Windows 2000 or later).
    static let volumeMute = Win32Keys(rawValue: 173)

    /// The volume up key (Windows 2000 or later).
    static let volumeUp = Win32Keys(rawValue: 175)

    /// The W key.
    static let w = Win32Keys(rawValue: 87)

    /// The X key.
    static let x = Win32Keys(rawValue: 88)

    /// The first x mouse button (five-button mouse).
    static let xButton1 = Win32Keys(rawValue: 5)

    /// The second x mouse button (five-button mouse).
    static let xButton2 = Win32Keys(rawValue: 6)

    /// The Y key.
    static let y = Win32Keys(rawValue: 89)

    /// The Z key.
    static let z = Win32Keys(rawValue: 90)

    /// The ZOOM key.
    static let zoom = Win32Keys(rawValue: 251)
}
