import Foundation
import ImagineUI
import SwiftBlend2D

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
    public var backgroundColor: BLRgba32? = .cornflowerBlue {
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
        UISettings.scale = preferredRenderScale

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

    open func render(context ctx: BLContext, renderScale: UIVector) {
        guard let rect = currentRedrawRegion else {
            return
        }

        ctx.scale(by: renderScale.asBLPoint)

        if let backgroundColor = backgroundColor {
            ctx.setFillStyle(backgroundColor)
            ctx.fillRect(rect.asBLRect)
        }

        let redrawRegion = BLRegion(rectangle: BLRectI(rounding: rect.asBLRect))

        let renderer = Blend2DRenderer(context: ctx)

        // Redraw loop
        for rootView in rootViews {
            rootView.renderRecursive(in: renderer, screenRegion: Blend2DClipRegion(region: redrawRegion))
        }

        // Debug render
        for rootView in rootViews {
            DebugDraw.debugDrawRecursive(rootView, flags: debugDrawFlags, to: ctx)
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
}

extension ImagineUIWindowContent: RootViewRedrawInvalidationDelegate {
    open func rootView(_ rootView: RootView, invalidateRect rect: UIRectangle) {
        guard let intersectedRect = rect.intersection(bounds.asRectangle) else {
            return
        }

        if let current = currentRedrawRegion {
            currentRedrawRegion = current.union(intersectedRect)
        } else {
            currentRedrawRegion = intersectedRect
        }

        delegate?.invalidate(bounds: intersectedRect)
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
