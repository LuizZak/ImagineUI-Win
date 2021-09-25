import WinSDK
import Foundation
import ImagineUI_Win

var app: ImagineUIApp!

@_silgen_name("wWinMain")
func wWinMain(_ hInstance: HINSTANCE, 
              _ hPrevInstance: HINSTANCE,
              _ pCmdLine: PWSTR, 
              _ nCmdShow: CInt) -> CInt {
    
    let delegate = SampleDelegate()
    let fontPath = Bundle.module.path(forResource: "NotoSans-Regular", ofType: "ttf")!
    let settings = ImagineUIAppStartupSettings(defaultFontPath: fontPath)

    app = ImagineUIApp(delegate: delegate)

    return try! app.run(settings: settings)
}
