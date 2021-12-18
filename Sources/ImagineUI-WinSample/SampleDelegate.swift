import ImagineUI_Win

class SampleDelegate: ImagineUIAppDelegate {
    var main: ImagineUIContentType?

    func appDidLaunch() throws {
        // Disable bitmap caching to smoothen out UI
        ControlView.globallyCacheAsBitmap = false

        let main = SampleWindow()
        app.show(content: main)

        self.main = main
    }
}
