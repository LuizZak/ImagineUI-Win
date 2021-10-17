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

        public init(title: String, size: Size, windowClass: WindowClass = Win32Window.defaultWindowClass) {
            self.title = title
            self.size = size
            self.windowClass = windowClass
        }
    }
}
