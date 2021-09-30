public struct Win32KeyboardModifier: OptionSet {
    public var rawValue: Int

    @_transparent
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let none = Win32KeyboardModifier([])
    public static let shift = Win32KeyboardModifier(rawValue: 0b1)
    public static let control = Win32KeyboardModifier(rawValue: 0b10)
    public static let alt = Win32KeyboardModifier(rawValue: 0b100)
}
