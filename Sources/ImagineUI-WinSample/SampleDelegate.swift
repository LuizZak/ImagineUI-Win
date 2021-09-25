import ImagineUI_Win

class SampleDelegate: ImagineUIAppDelegate {
    let main = MainWindow(size: .init(width: 400, height: 300))
    
    func appDidLaunch() {
        main.show()
    }
}
