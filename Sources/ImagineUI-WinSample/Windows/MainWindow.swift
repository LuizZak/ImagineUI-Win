import ImagineUI_Win

class MainWindow: ImagineUIWindowContent {
    func show() {
        app.show(content: self)
    }

    override func initialize() {
        super.initialize()
    }

    override func didClose() {
        super.didClose()

        WinLogger.info("\(self): Closed")
        app.requestQuit()
    }
}
