import MinWin32
import ImagineUI_Win

class SampleDelegate: MinWin32AppDelegate {
    var main: ImagineUIContentType?

    func appDidLaunch() throws {
        // Disable bitmap caching to smoothen out UI
        ControlView.globallyCacheAsBitmap = false

        let main = SampleWindow()
        app.show(content: main)

        self.main = main
    }
}
