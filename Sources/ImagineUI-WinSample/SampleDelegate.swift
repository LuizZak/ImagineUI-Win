import Foundation
import MinWin32
import ImagineUI_Win

class SampleDelegate: MinWin32AppDelegate {
    func onImagineActor(_ block: sending @ImagineActor @escaping () async -> Void) {
        Task.detached {
            await block()
        }
    }

    func appDidLaunch() throws {
        onImagineActor {
            // Disable bitmap caching to smoothen out UI
            ControlView.globallyCacheAsBitmap = false

            let main = SampleWindow()

            app.show(content: main)
        }
    }
}
