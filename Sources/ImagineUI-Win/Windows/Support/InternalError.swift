/// Errors thrown by internal ImagineUI-Win APIs when interacting with Win32 APIs.
public enum InternalError: Error {
    /// Error raised when a pointer returned by a Win32 API is unexpectedly `nil`.
    case unexpectedNilPointer
}
