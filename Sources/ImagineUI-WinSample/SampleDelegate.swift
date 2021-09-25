import ImagineUI_Win

class SampleDelegate: ImagineUIAppDelegate {
    var main: MainWindow?

    func appDidLaunch() {
        let main = MainWindow(size: .init(width: 400, height: 300))
        main.show()

        self.main = main
    }
}
