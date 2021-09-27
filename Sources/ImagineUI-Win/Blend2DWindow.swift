import ImagineUI
import Blend2DRenderer
import WinSDK
import WinSDK.User
import WinSDK.WinGDI

public class Blend2DWindow: Win32Window {
    /// Rate of update calls per second.
    /// Affects how much the content.update() function is called each second.
    public var updateRate: Double = 60

    public let updateStopwatch = Stopwatch.start()
    public let content: Blend2DWindowContentType

    /// Returns the computed size for `content`, based on the window's scaled
    /// divided by `dpiScalingFactor`.
    public var contentSize: UIIntSize {
        size.asUIIntSize.scaled(by: 1.0 / dpiScalingFactor)
    }

    /// An immediate buffer where ``content`` is drawn to it's full scale.
    var immediateBuffer: BLImage?

    /// Returns the render scale for content that must be drawn on the
    /// `immediateBuffer` with a 1:1 relationship between rendered pixel and
    /// screen pixel.
    var immediateBufferRenderScale: BLPoint {
        (content.preferredRenderScale * dpiScalingFactor).asBLPoint
    }

    /// Expected size for immediate buffer, calculated by scaling the content's
    /// size by its `renderScale` and the current `dpiScalingFactor`.
    var immediateBufferSize: BLSizeI {
        size.asBLSizeI.scaled(by: immediateBufferRenderScale)
    }

    /// A secondary buffer where ``immediateBuffer`` is drawn to, scaling up or
    /// down to fit the window's size.
    var secondaryBuffer: Blend2DImageBuffer?

    /// Expected size for secondary buffer, calculated by scaling the window's
    /// size by its DPI scaling.
    var secondaryBufferSize: BLSizeI {
        size.asBLSizeI.scaled(by: dpiScalingFactor)
    }

    /// Event raised when the window has been closed.
    @Event public var closed: EventSourceWithSender<Blend2DWindow, Void>

    convenience init(content: Blend2DWindowContentType) {
        self.init(size: content.size, content: content)
    }

    init(size: UIIntSize, content: Blend2DWindowContentType) {
        self.content = content

        super.init(size: size.asSize)
    }

    override func initialize() {
        super.initialize()

        globalTextClipboard = Win32TextClipboard()

        content.delegate = self

        recreateBuffers()
    }

    func update() {
        content.update(Stopwatch.global.timeIntervalSinceStart())
    }

    private func resizeApp() {
        content.resize(contentSize)

        recreateBuffers()

        setNeedsDisplay()
    }

    private func recreateBuffers() {
        guard content.size > .zero else {
            immediateBuffer = nil
            secondaryBuffer = nil
            return
        }

        // TODO: Support using a single buffer if the preferred render scale of
        // TODO: self.content is 1.0.
        immediateBuffer = BLImage(size: immediateBufferSize, format: .xrgb32)

        if let hdc = GetDC(hwnd) {
            secondaryBuffer = Blend2DImageBuffer(size: secondaryBufferSize, hdc: hdc)
        } else {
            WinLogger.warning("Failed to create device context for secondary buffer")
            secondaryBuffer = nil
        }
    }

    // MARK: Events

    override func onResize(_ message: WindowMessage) {
        super.onResize(message)

        resizeApp()
    }

    override func onDPIChanged(_ message: WindowMessage) {
        super.onDPIChanged(message)

        resizeApp()

        WinLogger.info("DPI for window changed: \(dpi), new sizes: contentSize: \(contentSize), immediateBufferSize: \(immediateBufferSize), secondaryBufferSize: \(secondaryBufferSize)")
    }

    override func onClose() {
        super.onClose()

        WinLogger.info("\(self): Closed")
        _closed.publishEvent(sender: self)
        content.didClose()
    }

    override func onPaint(_ message: WindowMessage) {
        update()

        guard needsDisplay else {
            return
        }
        defer { needsDisplay = false }

        var ps = PAINTSTRUCT()
        let hdc = BeginPaint(hwnd, &ps)
        defer {
            EndPaint(hwnd, &ps)
        }

        let uiRect = ps.rcPaint.asUIRectangle.scaled(by: 1 / dpiScalingFactor)

        paintImmediateBuffer(uiRect)
        paintScreenBuffer(uiRect)

        guard let secondaryBuffer = secondaryBuffer else {
            return
        }
        let bitmapWidth = secondaryBufferSize.w
        let bitmapHeight = secondaryBufferSize.h

        // TODO: Should we refresh the secondary buffer if the device context
        // TODO: for the draw call changes?
        secondaryBuffer.pushPixelsToGDI(uiRect)
        let w = ps.rcPaint.right - ps.rcPaint.left
        let h = ps.rcPaint.bottom - ps.rcPaint.top
        secondaryBuffer.bitBlt(to: hdc, ps.rcPaint.left, ps.rcPaint.top, w, h, ps.rcPaint.left, ps.rcPaint.top, SRCCOPY)
    }

    private func paintImmediateBuffer(_ rect: UIRectangle) {
        guard let immediateBuffer = immediateBuffer else {
            return
        }

        let options = BLContext.CreateOptions(threadCount: 0) // TODO: Multi-threading on Windows is crashing, disable threads in Blend2D for now.
        let ctx = BLContext(image: immediateBuffer, options: options)!

        let clip = Blend2DClipRegion(region: .init(rectangle: .init(rounding: rect.asBLRect)))

        content.render(context: ctx, renderScale: immediateBufferRenderScale.asUIVector, clipRegion: clip)

        ctx.flush(flags: .sync)
        ctx.end()
    }

    private func paintScreenBuffer(_ rect: UIRectangle) {
        guard let immediateBuffer = immediateBuffer else { return }
        guard let secondaryBuffer = secondaryBuffer else { return }
        guard let ctx = BLContext(image: secondaryBuffer.blImage) else { return }

        ctx.compOp = .sourceCopy
        ctx.setPatternQualityHint(.bilinear)
        ctx.setRenderingQualityHint(.antialias)
        ctx.blitScaledImage(immediateBuffer, rectangle: BLRectI(location: .zero, size: secondaryBufferSize))

        ctx.flush(flags: .sync)
        ctx.end()
    }

    // MARK: Mouse Events

    override func onMouseMove(_ message: WindowMessage) {
        super.onMouseMove(message)

        let event = makeMouseEventArgs(message)
        content.mouseMoved(event: event)
    }

    override func onLeftMouseDown(_ message: WindowMessage) {
        super.onLeftMouseDown(message)

        SetCapture(hwnd)

        let event = makeMouseEventArgs(message)
        content.mouseDown(event: event)
    }

    override func onMiddleMouseDown(_ message: WindowMessage) {
        super.onMiddleMouseDown(message)

        SetCapture(hwnd)

        let event = makeMouseEventArgs(message)
        content.mouseDown(event: event)
    }

    override func onRightMouseDown(_ message: WindowMessage) {
        super.onRightMouseDown(message)

        SetCapture(hwnd)

        let event = makeMouseEventArgs(message)
        content.mouseDown(event: event)
    }

    override func onLeftMouseUp(_ message: WindowMessage) {
        super.onLeftMouseUp(message)

        ReleaseCapture()

        let event = makeMouseEventArgs(message)
        content.mouseUp(event: event)
    }

    override func onMiddleMouseUp(_ message: WindowMessage) {
        super.onMiddleMouseUp(message)

        ReleaseCapture()

        let event = makeMouseEventArgs(message)
        content.mouseUp(event: event)
    }

    override func onRightMouseUp(_ message: WindowMessage) {
        super.onRightMouseUp(message)

        ReleaseCapture()

        let event = makeMouseEventArgs(message)
        content.mouseUp(event: event)
    }

    func makeMouseEventArgs(_ message: WindowMessage) -> MouseEventArgs {
        let x = GET_X_LPARAM(message.lParam)
        let y = GET_Y_LPARAM(message.lParam)
        let location = UIVector(x: Double(x), y: Double(y)) / dpiScalingFactor

        var buttons: MouseButton = []

        if IS_BIT_ON(message.wParam, MK_LBUTTON) {
            buttons.insert(.left)
        }
        if IS_BIT_ON(message.wParam, MK_MBUTTON) {
            buttons.insert(.middle)
        }
        if IS_BIT_ON(message.wParam, MK_RBUTTON) {
            buttons.insert(.right)
        }

        let event = MouseEventArgs(
            location: location,
            buttons: buttons,
            delta: .zero,
            clicks: 0
        )

        return event
    }
}

extension Blend2DWindow: Blend2DWindowContentDelegate {
    public func needsLayout(_ view: View) {
        setNeedsDisplay()
    }

    public func invalidate(bounds: UIRectangle) {
        setNeedsDisplay(bounds.scaled(by: dpiScalingFactor).asRect)
    }

    public func setMouseCursor(_ cursor: MouseCursorKind) {
        var hCursor: HCURSOR?

        // TODO: Implement cursor change
        switch cursor {
        case .arrow:
            hCursor = LoadCursorW(nil, IDC_ARROW)

        case .iBeam:
            hCursor = LoadCursorW(nil, IDC_IBEAM)

        case .resizeUpDown:
            hCursor = LoadCursorW(nil, IDC_SIZENS)

        case .resizeLeftRight:
            hCursor = LoadCursorW(nil, IDC_SIZEWE)

        case .resizeTopLeftBottomRight:
            hCursor = LoadCursorW(nil, IDC_SIZENWSE)

        case .resizeTopRightBottomLeft:
            hCursor = LoadCursorW(nil, IDC_SIZENESW)

        case .resizeAll:
            hCursor = LoadCursorW(nil, IDC_SIZEALL)

        case .custom(let imagePath, let hotspot):
            // TODO: Implement custom cursor

            break
        }

        if let hCursor = hCursor {
            SetClassLongPtrW(hwnd, GCLP_HCURSOR, hCursorToLONG_PTR(hCursor))
        }
    }

    public func setMouseHiddenUntilMouseMoves() {
        // TODO: Implement cursor hiding
    }
}
