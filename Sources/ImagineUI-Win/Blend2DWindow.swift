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

    /// Returns the computed size for `content`, based on the window's scale
    /// divided by `dpiScalingFactor`.
    public var contentSize: UIIntSize {
        size.asUIIntSize.scaled(by: 1.0 / dpiScalingFactor)
    }

    var usingDoubleBuffer: Bool { _immediateBuffer != nil && secondaryBuffer != nil }

    /// If non-nil, fetching `immediateBuffer` returns this value, if `nil`,
    /// fetching `immediateBuffer` returns `secondaryBuffer.blImage`, instead.
    var _immediateBuffer: BLImage?

    /// An immediate buffer where ``content`` is drawn to it's full scale.
    var immediateBuffer: BLImage? {
        return _immediateBuffer ?? secondaryBuffer?.blImage
    }

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
        _immediateBuffer = nil
        secondaryBuffer = nil

        guard content.size > .zero else {
            return
        }

        if let hdc = GetDC(hwnd) {
            secondaryBuffer = Blend2DImageBuffer(size: secondaryBufferSize, hdc: hdc)
        } else {
            WinLogger.warning("Failed to create device context for secondary buffer")
            secondaryBuffer = nil
        }

        if content.preferredRenderScale != 1 {
            _immediateBuffer = BLImage(size: immediateBufferSize, format: .xrgb32)
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

    override func onClose(_ message: WindowMessage) {
        super.onClose(message)

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

        guard let secondaryBuffer = secondaryBuffer else {
            return
        }

        let uiRect = ps.rcPaint.asUIRectangle.scaled(by: 1 / dpiScalingFactor)

        paintImmediateBuffer(uiRect)
        if usingDoubleBuffer {
            paintScreenBuffer(uiRect)
        }

        let w = ps.rcPaint.right - ps.rcPaint.left
        let h = ps.rcPaint.bottom - ps.rcPaint.top
        secondaryBuffer.pushPixelsToGDI(uiRect)
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

        if immediateBuffer === secondaryBuffer {
            WinLogger.warning("Attempted to paint screen buffer in single-buffered render mode.")
            return
        }

        guard let ctx = BLContext(image: secondaryBuffer.blImage) else { return }

        ctx.compOp = .sourceCopy
        ctx.setPatternQualityHint(.bilinear)
        ctx.setRenderingQualityHint(.antialias)
        ctx.clipToRect(rect.asBLRect)
        ctx.blitScaledImage(immediateBuffer, rectangle: BLRectI(location: .zero, size: secondaryBufferSize))

        ctx.flush(flags: .sync)
        ctx.end()
    }

    // MARK: Mouse Events

    override func onMouseMove(_ message: WindowMessage) -> LRESULT? {
        defer {
            let event = makeMouseEventArgs(message)
            content.mouseMoved(event: event)
        }

        return super.onMouseMove(message)
    }

    override func onLeftMouseDown(_ message: WindowMessage) -> LRESULT? {
        defer {
            SetCapture(hwnd)
            let event = makeMouseEventArgs(message)
            content.mouseDown(event: event)
        }

        return super.onLeftMouseDown(message)
    }

    override func onMiddleMouseDown(_ message: WindowMessage) -> LRESULT? {
        defer {
            SetCapture(hwnd)

            let event = makeMouseEventArgs(message)
            content.mouseDown(event: event)
        }

        return super.onMiddleMouseDown(message)
    }

    override func onRightMouseDown(_ message: WindowMessage) -> LRESULT? {
        defer {
            SetCapture(hwnd)

            let event = makeMouseEventArgs(message)
            content.mouseDown(event: event)
        }

        return super.onRightMouseDown(message)
    }

    override func onLeftMouseUp(_ message: WindowMessage) -> LRESULT? {
        defer {
            ReleaseCapture()

            let event = makeMouseEventArgs(message)
            content.mouseUp(event: event)
        }

        return super.onLeftMouseUp(message)
    }

    override func onMiddleMouseUp(_ message: WindowMessage) -> LRESULT? {
        defer {
            ReleaseCapture()

            let event = makeMouseEventArgs(message)
            content.mouseUp(event: event)
        }

        return super.onMiddleMouseUp(message)
    }

    override func onRightMouseUp(_ message: WindowMessage) -> LRESULT? {
        defer {
            ReleaseCapture()

            let event = makeMouseEventArgs(message)
            content.mouseUp(event: event)
        }

        return super.onRightMouseUp(message)
    }

    // MARK: Keyboard events

    override func onKeyDown(_ message: WindowMessage) -> LRESULT? {
        let event = makeKeyEventArgs(message)
        content.keyDown(event: event)
        WinLogger.info("keyDown: \(message)")
        return 0
    }

    override func onKeyUp(_ message: WindowMessage) -> LRESULT? {
        let event = makeKeyEventArgs(message)
        content.keyUp(event: event)

        return 0
    }

    // TODO: Properly handle WM_CHAR events

    /*
    override func onKeyChar(_ message: WindowMessage) -> LRESULT? {
        guard let event = makeKeyPressEventArgs(message) else {
            WinLogger.info("Coult not convert key press message \(message): Invalid character.")
            return nil
        }

        content.keyPress(event: event)

        return 0
    }

    private func makeKeyPressEventArgs(_ message: WindowMessage) -> KeyPressEventArgs? {
        guard let keyChar = Character(fromWM_CHAR: wchar_t(truncatingIfNeeded: message.wParam)) else {
            return nil
        }

        let modifiers: KeyboardModifier = makeKeyboardModifiers(message)

        return KeyPressEventArgs(keyChar: keyChar, modifiers: modifiers)
    }
    */

    // MARK: Message translation

    private func makeKeyEventArgs(_ message: WindowMessage) -> KeyEventArgs {
        let vkCode: Keys = Keys(fromWin32VK: LOWORD(message.wParam))
        let keyChar: String? = nil
        let modifiers: KeyboardModifier = makeKeyboardModifiers(message)

        return KeyEventArgs(keyCode: vkCode, keyChar: keyChar, modifiers: modifiers)
    }

    private func makeKeyboardModifiers(_ message: WindowMessage) -> KeyboardModifier {
        var modifiers: KeyboardModifier = []

        if IS_BIT_ON(HIWORD(message.lParam), KF_ALTDOWN) {
            modifiers.insert(.alt)
        }
        if IS_HIBIT_ON(GetKeyState(VK_CONTROL)) {
            modifiers.insert(.control)
        }
        if IS_HIBIT_ON(GetKeyState(VK_SHIFT)) {
            modifiers.insert(.shift)
        }

        return modifiers
    }

    private func makeMouseEventArgs(_ message: WindowMessage) -> MouseEventArgs {
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
        let screenBounds = bounds.scaled(by: dpiScalingFactor)
        setNeedsDisplay(screenBounds.rounded().asRect)
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

    public func firstResponderChanged(_ newFirstResponder: KeyboardEventHandler?) {
        if newFirstResponder != nil {
            SetFocus(hwnd)
        }
    }
}
