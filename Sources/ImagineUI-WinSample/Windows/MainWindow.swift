import ImagineUI_Win

class MainWindow: ImagineUIWindowContent {
    func show() {
        app.show(content: self)
    }

    override func didClose() {
        super.didClose()
        
        app.requestQuit()
    }
}
