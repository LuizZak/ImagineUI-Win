import MinWin32
import ImagineUI_Win

final class MainWindow: ImagineUIWindowContent {
    func show() {
        app.show(content: self)
    }

    override func initialize() {
        super.initialize()

        backgroundColor = .lightGray

        let button = Button(title: "Press me!")
        button.location = .init(x: 15, y: 15)
        button.areaIntoConstraintsMask = [.location]
        rootView.addSubview(button)
    }

    override func didCloseWindow() {
        super.didCloseWindow()

        app.requestQuit()
    }
}
