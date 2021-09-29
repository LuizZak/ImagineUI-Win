import Foundation
import ImagineUI
import Blend2DRenderer

open class ImagineUIWindowContent: Blend2DWindowContentType {
    private var lastFrame: TimeInterval = 0
    private var bounds: BLRect
    private let rendererContext = Blend2DRendererContext()
    private var controlSystem = DefaultControlSystem()
    private var rootViews: [RootView]
    private var currentRedrawRegion: UIRectangle? = nil
    private var debugDrawFlags: Set<DebugDraw.DebugDrawFlags> = []

    private(set) public var size: UIIntSize

    public var width: Int { size.width }
    public var height: Int { size.height }

    public var preferredRenderScale: UIVector = .init(repeating: 1)

    /// The default refresh color for this window content.
    /// If `nil`, no region clear is done before render calls and the last
    /// refresh's pixels will remain on the backbuffer.
    public var backgroundColor: Color? = .cornflowerBlue {
        didSet {
            invalidateScreen()
        }
    }

    /// The main view for this window content.
    public let rootView = RootView()

    public weak var delegate: Blend2DWindowContentDelegate?

    public init(size: UIIntSize) {
        self.size = size
        bounds = BLRect(location: .zero, size: BLSize(w: Double(size.width), h: Double(size.height)))
        rootViews = []
        controlSystem.delegate = self

        initialize()
    }

    open func initialize() {
        addRootView(rootView)
    }

    open func addRootView(_ view: RootView) {
        view.invalidationDelegate = self
        rootViews.append(view)
    }

    open func removeRootView(_ view: RootView) {
        view.invalidationDelegate = nil
        rootViews.removeAll { $0 === view }
    }

    open func willStartLiveResize() {

    }

    open func didEndLiveResize() {

    }

    open func resize(_ newSize: UIIntSize) {
        self.size = newSize

        rootView.location = .zero
        rootView.size = .init(width: Double(width), height: Double(height))

        bounds = BLRect(location: .zero, size: BLSize(w: Double(width), h: Double(height)))
        currentRedrawRegion = bounds.asRectangle

        for case let window as Window in rootViews where window.windowState == .maximized {
            window.setNeedsLayout()
        }
    }

    open func invalidateScreen() {
        currentRedrawRegion = bounds.asRectangle
        delegate?.invalidate(bounds: bounds.asRectangle)
    }

    open func update(_ time: TimeInterval) {
        // Fixed-frame update
        let delta = time - lastFrame
        lastFrame = time
        Scheduler.instance.onFixedFrame(delta)

        performLayout()
    }

    open func performLayout() {
        // Layout loop
        for rootView in rootViews {
            rootView.performLayout()
        }
    }

    open func render(context ctx: BLContext, renderScale: UIVector, clipRegion: ClipRegion) {
        let renderer = Blend2DRenderer(context: ctx)
        renderer.scale(by: renderScale)

        if let backgroundColor = backgroundColor {
            renderer.setFill(backgroundColor)
            renderer.fill(clipRegion.bounds())
        }

        // Redraw loop
        for rootView in rootViews {
            rootView.renderRecursive(in: renderer, screenRegion: clipRegion)
        }

        // Debug render
        for rootView in rootViews {
            DebugDraw.debugDrawRecursive(rootView, flags: debugDrawFlags, in: renderer)
        }
    }

    open func mouseDown(event: MouseEventArgs) {
        controlSystem.onMouseDown(event)
    }

    open func mouseMoved(event: MouseEventArgs) {
        controlSystem.onMouseMove(event)
    }

    open func mouseUp(event: MouseEventArgs) {
        controlSystem.onMouseUp(event)
    }

    open func mouseScroll(event: MouseEventArgs) {
        controlSystem.onMouseWheel(event)
    }

    open func keyDown(event: KeyEventArgs) {
        controlSystem.onKeyDown(event)
    }

    open func keyUp(event: KeyEventArgs) {
        controlSystem.onKeyUp(event)
    }

    open func keyPress(event: KeyPressEventArgs) {
        controlSystem.onKeyPress(event)
    }

    open func didClose() {

    }
}

extension ImagineUIWindowContent: DefaultControlSystemDelegate {
    open func bringRootViewToFront(_ rootView: RootView) {
        rootViews.removeAll(where: { $0 == rootView })
        rootViews.append(rootView)

        rootView.invalidate()
    }

    open func controlViewUnder(point: UIVector, enabledOnly: Bool) -> ControlView? {
        for window in rootViews.reversed() {
            let converted = window.convertFromScreen(point)
            if let view = window.hitTestControl(converted, enabledOnly: enabledOnly) {
                return view
            }
        }

        return nil
    }

    open func setMouseCursor(_ cursor: MouseCursorKind) {
        delegate?.setMouseCursor(cursor)
    }

    open func setMouseHiddenUntilMouseMoves() {
        delegate?.setMouseHiddenUntilMouseMoves()
    }

    open func firstResponderChanged(_ newFirstResponder: KeyboardEventHandler?) {
        delegate?.firstResponderChanged(newFirstResponder)
    }
}

extension ImagineUIWindowContent: RootViewRedrawInvalidationDelegate {
    /// Signals the delegate that a given root view has invalidated its layout
    /// and needs to update it.
    open func rootViewInvalidatedLayout(_ rootView: RootView) {
        delegate?.needsLayout(rootView)
    }

    open func rootView(_ rootView: RootView, invalidateRect rect: UIRectangle) {
        delegate?.invalidate(bounds: rect)
    }
}

extension ImagineUIWindowContent: WindowDelegate {
    open func windowWantsToClose(_ window: Window) {
        if let index = rootViews.firstIndex(of: window) {
            rootViews.remove(at: index)
            invalidateScreen()
        }
    }

    open func windowWantsToMaximize(_ window: Window) {
        switch window.windowState {
        case .maximized:
            window.setWindowState(.normal)

        case .normal, .minimized:
            window.setWindowState(.maximized)
        }
    }

    open func windowWantsToMinimize(_ window: Window) {
        window.setWindowState(.minimized)
    }

    open func windowSizeForFullscreen(_ window: Window) -> UISize {
        return bounds.asRectangle.size
    }
}
