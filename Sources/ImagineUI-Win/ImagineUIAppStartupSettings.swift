import ImagineUI
import Blend2DRenderer

/// Startup settings for an ImagineUIApp instance.
public struct ImagineUIAppStartupSettings {
    public var defaultFontPath: String
    public var fontManager: FontManager

    public init(defaultFontPath: String, fontManager: FontManager = Blend2DFontManager()) {
        self.defaultFontPath = defaultFontPath
        self.fontManager = fontManager
    }
}
