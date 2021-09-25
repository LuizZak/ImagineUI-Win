import ImagineUI
import SwiftBlend2D
import WinSDK
import WinSDK.User
import WinSDK.WinGDI

public class Blend2DWindow: Win32Window {
    /// Rate of update calls per second.
    /// Affects how much the content.update() function is called each second.
    public var updateRate: Double = 60

    public let updateStopwatch = Stopwatch.start()
    public let content: Blend2DWindowContentType
    var blImage: BLImage?
    var redrawBounds: [UIRectangle] = []

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

        recreateBufferImage()
    }

    override func updateAndPaint() {
        update()

        super.updateAndPaint()
    }

    func update() {
        guard updateStopwatch.timeIntervalSinceStart() > (1 / updateRate) else {
            return
        }
        updateStopwatch.restart()

        content.update(Stopwatch.global.timeIntervalSinceStart())

        guard let first = redrawBounds.first else {
            return
        }
        guard let blImage = blImage else {
            return
        }

        let options = BLContext.CreateOptions(threadCount: 4)
        let ctx = BLContext(image: blImage, options: options)!

        content.render(context: ctx)

        ctx.flush(flags: .sync)
        ctx.end()

        let reduced = redrawBounds.reduce(first, { $0.union($1) })
        redrawBounds.removeAll()

        setNeedsDisplay(.init(from: reduced))
    }

    private func resizeApp() {
        content.resize(.init(width: Int(size.width), height: Int(size.height)))

        recreateBufferImage()

        redrawBounds.append(.init(location: .zero, size: size.asUISize))
    }

    private func recreateBufferImage() {
        guard content.size > .zero else {
            blImage = nil
            return
        }

        blImage = BLImage(width: content.size.width * Int(content.renderScale.x),
                          height: content.size.height * Int(content.renderScale.y),
                          format: .xrgb32)
    }

    // MARK: Events

    override func onResize() {
        resizeApp()
    }

    override func onClose() {
        super.onClose()

        WinLogger.info("\(self): Closed")
        _closed.publishEvent(sender: self)
        content.didClose()
    }

    override func onPaint() {
        guard needsDisplay else {
            return
        }
        defer { needsDisplay = false }

        guard let hdc = GetDC(hwnd) else {
            return
        }
        guard let blImage = blImage else {
            return
        }

        let imageData = blImage.getImageData()

        let bitmapWidth = Int32(blImage.width)
        let bitmapHeight = Int32(blImage.height)

        let bitDepth: UINT = 32
        let map =
        CreateBitmap(
            bitmapWidth,
            bitmapHeight,
            1,
            bitDepth,
            imageData.pixelData
        )
        defer { DeleteObject(map) }

        let src = CreateCompatibleDC(hdc)
        defer { DeleteDC(src) }

        SelectObject(src, map)

        // TODO: Fix bad artifacts by doing this downscaling in Blend2D instead (GDI+ API is not available in Swift yet)
        if content.renderScale == .init(repeating: 1) {
            BitBlt(hdc, 0, 0, bitmapWidth, bitmapHeight, src, 0, 0, SRCCOPY)
        } else {
            StretchBlt(
                hdc,
                0,
                0,
                Int32(size.width),
                Int32(size.height),
                src,
                0,
                0,
                bitmapWidth,
                bitmapHeight,
                SRCCOPY
            )
        }
    }

    // MARK: Mouse Events

    override func onMouseMove(_ wParam: WPARAM, _ lParam: LPARAM) {
        super.onMouseMove(wParam, lParam)

        let event = makeMouseEventArgs(wParam, lParam)
        content.mouseMoved(event: event)
    }

    override func onLeftMouseDown(_ wParam: WPARAM, _ lParam: LPARAM) {
        super.onLeftMouseDown(wParam, lParam)

        SetCapture(hwnd)

        let event = makeMouseEventArgs(wParam, lParam)
        content.mouseDown(event: event)
    }

    override func onMiddleMouseDown(_ wParam: WPARAM, _ lParam: LPARAM) {
        super.onMiddleMouseDown(wParam, lParam)

        SetCapture(hwnd)

        let event = makeMouseEventArgs(wParam, lParam)
        content.mouseDown(event: event)
    }

    override func onRightMouseDown(_ wParam: WPARAM, _ lParam: LPARAM) {
        super.onRightMouseDown(wParam, lParam)

        SetCapture(hwnd)

        let event = makeMouseEventArgs(wParam, lParam)
        content.mouseDown(event: event)
    }

    override func onLeftMouseUp(_ wParam: WPARAM, _ lParam: LPARAM) {
        super.onLeftMouseUp(wParam, lParam)

        ReleaseCapture()

        let event = makeMouseEventArgs(wParam, lParam)
        content.mouseUp(event: event)
    }

    override func onMiddleMouseUp(_ wParam: WPARAM, _ lParam: LPARAM) {
        super.onMiddleMouseUp(wParam, lParam)

        ReleaseCapture()

        let event = makeMouseEventArgs(wParam, lParam)
        content.mouseUp(event: event)
    }

    override func onRightMouseUp(_ wParam: WPARAM, _ lParam: LPARAM) {
        super.onRightMouseUp(wParam, lParam)

        ReleaseCapture()

        let event = makeMouseEventArgs(wParam, lParam)
        content.mouseUp(event: event)
    }

    func makeMouseEventArgs(_ wParam: WPARAM, _ lParam: LPARAM) -> MouseEventArgs {
        let x = GET_X_LPARAM(lParam)
        let y = GET_Y_LPARAM(lParam)

        var buttons: MouseButton = []

        if IS_BIT_ON(wParam, MK_LBUTTON) {
            buttons.insert(.left)
        }
        if IS_BIT_ON(wParam, MK_MBUTTON) {
            buttons.insert(.middle)
        }
        if IS_BIT_ON(wParam, MK_RBUTTON) {
            buttons.insert(.right)
        }

        let location = UIVector(x: Double(x), y: Double(y))

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
    public func invalidate(bounds: UIRectangle) {
        redrawBounds.append(bounds)
    }

    public func setMouseCursor(_ cursor: MouseCursorKind) {
        // TODO: Implement cursor change
    }

    public func setMouseHiddenUntilMouseMoves() {
        // TODO: Implement cursor hiding
    }
}
