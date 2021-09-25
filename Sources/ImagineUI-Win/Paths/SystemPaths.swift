import struct Foundation.URL
import WinSDK

/// Contains factories for system paths.
public enum SystemPaths {
    internal typealias Knownfolderid = KNOWNFOLDERID
    internal typealias KnownFolderIdRef = UnsafePointer<Knownfolderid>

    /// "The file system directory that serves as a common repository for
    /// application-specific data."
    ///
    /// "A typical path is `C:\Documents and Settings\username\Application Data`."
    ///
    /// (from Win32 API reference: https://docs.microsoft.com/en-us/windows/win32/shell/knownfolderid#FOLDERID_RoamingAppData)
    public static func appData() throws -> URL {
        return try internalSystemPath(FOLDERID_RoamingAppData)
    }

    /// "The file system directory that contains application data for all users."
    ///
    /// Default: `%ALLUSERSPROFILE%`` (`%ProgramData%``, `%SystemDrive%\ProgramData`)
    ///
    /// (from Win32 API reference: https://docs.microsoft.com/en-us/windows/win32/shell/knownfolderid#FOLDERID_ProgramData)
    public static func commonAppData() throws -> URL {
        return try internalSystemPath(FOLDERID_ProgramData)
    }

    /// "The file system directory that serves as a data repository for local
    /// (nonroaming) applications."
    ///
    /// Default: `%LOCALAPPDATA%`` (`%USERPROFILE%\AppData\Local`).
    ///
    /// (from Win32 API reference: https://docs.microsoft.com/en-us/windows/win32/shell/knownfolderid#FOLDERID_LocalAppData)
    public static func localAppData() throws -> URL {
        return try internalSystemPath(FOLDERID_LocalAppData)
    }

    /// "A virtual folder path that contains fonts."
    ///
    /// "A typical path is `C:\Windows\Fonts`."
    ///
    /// (from Win32 API reference: https://docs.microsoft.com/en-us/windows/win32/shell/knownfolderid#FOLDERID_Fonts)
    public static func fontsPath() throws -> URL {
        return try internalSystemPath(FOLDERID_Fonts)
    }

    /// "The virtual folder that represents the My Documents desktop item."
    ///
    /// Default: `%USERPROFILE%\Documents`
    ///
    /// (from Win32 API reference: https://docs.microsoft.com/en-us/windows/win32/shell/knownfolderid#FOLDERID_Documents)
    public static func myDocuments() throws -> URL {
        return try internalSystemPath(FOLDERID_Documents)
    }

    @_transparent
    internal static func internalSystemPath(_ folderId: Knownfolderid) throws -> URL {
        var ptr: PWSTR? = nil
        let result = withUnsafePointer(to: folderId) {
            SHGetKnownFolderPath($0, 0, nil, &ptr)
        }

        if FAILED(result) {
            throw Win32Error(hresult: result)
        }

        guard let ptr = ptr else {
            throw InternalError.unexpectedNilPointer
        }

        let path = String(from: ptr)

        return URL(fileURLWithPath: path, isDirectory: true)
    }
}
