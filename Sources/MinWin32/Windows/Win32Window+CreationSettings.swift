extension Win32Window {
    /// Settings used to create the window in the Win32 APIs.
    public struct CreationSettings {
        /// Window's initial display title.
        public var title: String

        /// Window's initial size on screen.
        public var size: Size

        /// Window class.
        /// Defaults to ``Win32Window.defaultWindowClass``.
        public var windowClass: WindowClass

        public init(
            title: String,
            size: Size,
            windowClass: WindowClass = Win32Window.defaultWindowClass
        ) {
            self.title = title
            self.size = size
            self.windowClass = windowClass
        }
    }

    /// Specifies the desired initial position of a Win32Window as its shown on
    /// screen.
    public enum InitialPosition {
        /// Position is specified by the system, and not changed.
        case `default`

        /// Centers the window as its shown so that it occupies the center
        /// section of the screen it is in.
        case centered
    }
}
