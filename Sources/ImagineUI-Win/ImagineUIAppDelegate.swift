public protocol ImagineUIAppDelegate {
    func appDidLaunch() throws

    func appWillMoveToBackground()
    func appDidMoveToBackground()

    func appWillMoveToForeground()
    func appDidMoveToForeground()
}

public extension ImagineUIAppDelegate {
    func appWillMoveToBackground() {

    }

    func appDidMoveToBackground() {

    }

    func appWillMoveToForeground() {

    }

    func appDidMoveToForeground() {

    }
}
