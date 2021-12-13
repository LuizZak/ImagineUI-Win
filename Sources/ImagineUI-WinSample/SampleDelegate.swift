import ImagineUI_Win

class SampleDelegate: ImagineUIAppDelegate {
    var main: ImagineUIContentType?

    func appDidLaunch() throws {
        let main = TreeSampleWindow()
        app.show(content: main)

        self.main = main
    }
}
