public struct Win32KeyEventArgs {
    public var keyCode: Win32Keys
    public var keyChar: String?
    public var modifiers: Win32KeyboardModifier

    @_transparent
    public init(keyCode: Win32Keys, keyChar: String?, modifiers: Win32KeyboardModifier) {
        self.keyCode = keyCode
        self.keyChar = keyChar
        self.modifiers = modifiers
    }
}
