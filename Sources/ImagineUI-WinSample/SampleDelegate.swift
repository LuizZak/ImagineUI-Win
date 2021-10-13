import ImagineUI_Win

class SampleDelegate: ImagineUIAppDelegate {
    var main: Blend2DWindowContentType?

    func appDidLaunch() throws {
        let main = SampleWindow(size: .init(width: 400, height: 450))
        app.show(content: main)

        self.main = main
    }
}
