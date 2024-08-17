import Foundation
import WinSDK
import WinSDK.User
import WinSDK.WinGDI
import MinWin32
import Blend2DRenderer
import ImagineUI

public class Blend2DWindow: Win32Window {
    private var keyboardManager: Win32KeyboardManager?
    private var buffer: Blend2DGDIDoubleBuffer?

    /// Returns the computed size for `content`, based on the window's scale
    /// divided by `dpiScalingFactor`.
    var scaledContentSize: UIIntSize {
        size.asUIIntSize.scaled(by: 1.0 / dpiScalingFactor)
    }

    /// Content size, equal to this window's size scaled by the current
    /// `dpiScalingFactor` value.
    var contentSize: UIIntSize {
        size.asUIIntSize.scaled(by: dpiScalingFactor)
    }

    /// Number of rendering threads to use in Blend2D during rendering.
    /// A value of 0 specifies synchronous rendering with no threading.
    public var renderingThreads: UInt32 = 6

    /// Rate of update calls per second.
    /// Affects how much the content.update() function is called each second.
    public var updateRate: Double = 60

    public let updateStopwatch = Stopwatch.start()
    public let content: ImagineUIContentType

    /// Event raised when the window has been closed.
    @EventWithSender<Blend2DWindow, Void>
    public var closed

    public init(settings: CreationSettings, content: ImagineUIContentType) {
        self.content = content

        super.init(settings: settings)
    }

    public override func initialize() {
        super.initialize()

        initializeClipboard()
        initializeKeyboardManager()
        initializeContent()

        recreateBuffers()
    }

    private func onImagineActor(_ block: @Sendable @ImagineActor @escaping () -> Void) {
        Task.detached { @ImagineActor in
            block()
        }
    }

    private func initializeKeyboardManager() {
        keyboardManager = Win32KeyboardManager(hwnd: hwnd)
        keyboardManager?.delegate = self
    }

    private func initializeClipboard() {
        globalTextClipboard = Win32TextClipboard()
    }

    private func initializeContent() {
        content.delegate = self
    }

    private func resizeApp() {
        onImagineActor {
            self.content.resize(self.scaledContentSize)
        }

        recreateBuffers()

        setNeedsDisplay()
    }

    private func recreateBuffers() {
        buffer = nil

        guard contentSize > .zero else {
            return
        }
        guard let hdc = GetDC(nil) else {
            WinLogger.warning("Failed to get device context for screen")
            return
        }

        buffer = .init(
            contentSize: contentSize.asBLSizeI,
            format: .xrgb32,
            renderingThreads: renderingThreads,
            hdc: hdc,
            scale: content.preferredRenderScale
        )
    }

    // MARK: Events

    public override func onLayout() {
        super.onLayout()

        onImagineActor {
            self.content.performLayout()
        }
    }

    public override func onResize(_ message: WindowMessage) {
        super.onResize(message)

        resizeApp()
    }

    public override func onDPIChanged(_ message: WindowMessage) {
        super.onDPIChanged(message)

        resizeApp()

        WinLogger.info("DPI for window changed: \(dpi), new sizes: contentSize: \(contentSize), scaledContentSize: \(scaledContentSize)")
    }

    public override func onClose(_ message: WindowMessage) {
        super.onClose(message)

        WinLogger.info("\(self): Closed")
        _closed.publishEvent(sender: self)

        onImagineActor {
            self.content.didCloseWindow()
        }
    }

    public override func onPaint(_ message: WindowMessage) {
        guard needsDisplay else {
            return
        }
        defer { clearNeedsDisplay() }

        var ps = PAINTSTRUCT()
        guard let hdc = BeginPaint(hwnd, &ps) else {
            WinLogger.warning("BeginPaint returned a nil device context handle")
            return
        }
        defer {
            EndPaint(hwnd, &ps)
        }

        guard let buffer = buffer else {
            return
        }

        let uiRect = ps.rcPaint.asUIRectangle.scaled(by: 1 / dpiScalingFactor)

        buffer.renderingToBuffer { (ctx, scale) in
            paintImmediateBuffer(context: ctx, scale: scale, rect: uiRect)
        }

        buffer.renderBufferToScreen(hdc, rect: ps.rcPaint)
    }

    private func paintImmediateBuffer(context ctx: BLContext, scale: UIVector, rect: UIRectangle) {
        let clip = UIRegionClipRegion(region: .init(rectangle: rect))

        let renderer = Blend2DRenderer(context: ctx)

        ImagineActorExecutor.synchronousOperation {
            content.render(renderer: renderer, renderScale: scale * dpiScalingFactor, clipRegion: clip)
        }

        ctx.flush(flags: .sync)
    }

    // MARK: Mouse Events

    public override func onMouseLeave(_ message: WindowMessage) {
        defer {
            Task.detached {
                await self.content.mouseLeave()
            }
        }

        super.onMouseLeave(message)
    }

    public override func onMouseMove(_ message: WindowMessage) -> LRESULT? {
        defer {
            let event = makeMouseEventArgs(message, kind: .other)
            Task.detached {
                await self.content.mouseMoved(event: event)
            }
        }

        return super.onMouseMove(message)
    }

    public override func onMouseWheel(_ message: WindowMessage) -> LRESULT? {
        defer {
            let event = makeMouseEventArgs(message, kind: .mouseWheel)
            Task.detached {
                await self.content.mouseScroll(event: event)
            }
        }

        return super.onMouseWheel(message)
    }

    public override func onMouseHWheel(_ message: WindowMessage) -> LRESULT? {
        defer {
            let event = makeMouseEventArgs(message, kind: .mouseHWheel)
            Task.detached {
                await self.content.mouseScroll(event: event)
            }
        }

        return super.onMouseHWheel(message)
    }

    public override func onLeftMouseDown(_ message: WindowMessage) -> LRESULT? {
        defer {
            SetCapture(hwnd)

            let event = makeMouseEventArgs(message, kind: .other, button: .left)
            Task.detached {
                await self.content.mouseDown(event: event)
            }
        }

        return super.onLeftMouseDown(message)
    }

    public override func onMiddleMouseDown(_ message: WindowMessage) -> LRESULT? {
        defer {
            SetCapture(hwnd)

            let event = makeMouseEventArgs(message, kind: .other, button: .middle)
            Task.detached {
                await self.content.mouseDown(event: event)
            }
        }

        return super.onMiddleMouseDown(message)
    }

    public override func onRightMouseDown(_ message: WindowMessage) -> LRESULT? {
        defer {
            SetCapture(hwnd)

            let event = makeMouseEventArgs(message, kind: .other, button: .right)
            Task.detached {
                await self.content.mouseDown(event: event)
            }
        }

        return super.onRightMouseDown(message)
    }

    public override func onLeftMouseUp(_ message: WindowMessage) -> LRESULT? {
        defer {
            ReleaseCapture()

            let event = makeMouseEventArgs(message, kind: .other, button: .left)
            Task.detached {
                await self.content.mouseUp(event: event)
            }
        }

        return super.onLeftMouseUp(message)
    }

    public override func onMiddleMouseUp(_ message: WindowMessage) -> LRESULT? {
        defer {
            ReleaseCapture()

            let event = makeMouseEventArgs(message, kind: .other, button: .middle)
            Task.detached {
                await self.content.mouseUp(event: event)
            }
        }

        return super.onMiddleMouseUp(message)
    }

    public override func onRightMouseUp(_ message: WindowMessage) -> LRESULT? {
        defer {
            ReleaseCapture()

            let event = makeMouseEventArgs(message, kind: .other, button: .right)
            Task.detached {
                await self.content.mouseUp(event: event)
            }
        }

        return super.onRightMouseUp(message)
    }

    // MARK: Keyboard events

    public override func onKeyDown(_ message: WindowMessage) -> LRESULT? {
        guard let keyboardManager = keyboardManager else {
            return super.onKeyDown(message)
        }

        return keyboardManager.onKeyDown(message)
    }

   public  override func onKeyUp(_ message: WindowMessage) -> LRESULT? {
        guard let keyboardManager = keyboardManager else {
            return super.onKeyUp(message)
        }

        return keyboardManager.onKeyUp(message)
    }

    public override func onSystemKeyDown(_ message: WindowMessage) -> LRESULT? {
        guard let keyboardManager = keyboardManager else {
            return super.onSystemKeyDown(message)
        }

        return keyboardManager.onSystemKeyDown(message)
    }

    public override func onSystemKeyUp(_ message: WindowMessage) -> LRESULT? {
        guard let keyboardManager = keyboardManager else {
            return super.onSystemKeyUp(message)
        }

        return keyboardManager.onSystemKeyUp(message)
    }

    public override func onKeyCharDown(_ message: WindowMessage) -> LRESULT? {
        guard let keyboardManager = keyboardManager else {
            return super.onKeyCharDown(message)
        }

        return keyboardManager.onKeyCharDown(message)
    }

    public override func onKeyChar(_ message: WindowMessage) -> LRESULT? {
        guard let keyboardManager = keyboardManager else {
            return super.onKeyChar(message)
        }

        return keyboardManager.onKeyChar(message)
    }

    public override func onKeyDeadChar(_ message: WindowMessage) -> LRESULT? {
        guard let keyboardManager = keyboardManager else {
            return super.onKeyDeadChar(message)
        }

        return keyboardManager.onKeyDeadChar(message)
    }

    // MARK: Message translation

    private func makeMouseEventArgs(
        _ message: WindowMessage,
        kind: MouseMessageKind,
        button: MouseButton = []
    ) -> MouseEventArgs {

        var x = GET_X_LPARAM(message.lParam)
        var y = GET_Y_LPARAM(message.lParam)

        // Mouse wheel events receive screen space coordinates instead of client
        // space, so we need to convert to client space before proceeding.
        if kind.isWheelMessage {
            var point = POINT(x: LONG(x), y: LONG(y))
            ScreenToClient(hwnd, &point)
            x = Int16(point.x)
            y = Int16(point.y)
        }

        let location = UIVector(x: Double(x), y: Double(y)) / dpiScalingFactor
        var buttons: MouseButton = button
        var modifiers: KeyboardModifier = []
        var delta = UIVector.zero

        // Extract mouse wheel scroll and virtual key parameters
        let keyParam: WPARAM
        if kind.isWheelMessage {
            // TODO: Expose this property for customization.
            let wheelMultiplier = 5.0

            let amount = Double(Int32(GET_WHEEL_DELTA_WPARAM(message.wParam)) / WHEEL_DELTA) * wheelMultiplier

            switch kind {
            case .mouseWheel:
                delta.y = amount
            case .mouseHWheel:
                delta.x = amount
            case .other:
                break
            }

            keyParam = WPARAM(GET_KEYSTATE_WPARAM(message.wParam))
        } else {
            keyParam = WPARAM(message.wParam)
        }

        // Buttons
        if IS_BIT_ON(keyParam, MK_LBUTTON) {
            buttons.insert(.left)
        }
        if IS_BIT_ON(keyParam, MK_MBUTTON) {
            buttons.insert(.middle)
        }
        if IS_BIT_ON(keyParam, MK_RBUTTON) {
            buttons.insert(.right)
        }

        // Modifiers
        if IS_BIT_ON(keyParam, MK_CONTROL) {
            modifiers.insert(.control)
        }
        if IS_BIT_ON(keyParam, MK_SHIFT) {
            modifiers.insert(.shift)
        }

        let event = MouseEventArgs(
            location: location,
            buttons: buttons,
            delta: delta,
            clicks: 0,
            modifiers: modifiers
        )

        return event
    }

    private enum MouseMessageKind {
        /// WM_MOUSEWHEEL message.
        case mouseWheel

        /// WM_MOUSEHWHEEL message.
        case mouseHWheel

        /// Any other mouse message.
        case other

        var isWheelMessage: Bool {
            switch self {
            case .mouseWheel, .mouseHWheel:
                return true
            case .other:
                return false
            }
        }
    }
}

extension Blend2DWindow: Win32KeyboardManagerDelegate {
    public func keyboardManager(_ manager: Win32KeyboardManager, onKeyPress event: Win32KeyPressEventArgs) {
        Task.detached {
            await self.content.keyPress(event: event.asKeyPressEventArgs)
        }
    }

    public func keyboardManager(_ manager: Win32KeyboardManager, onKeyDown event: Win32KeyEventArgs) {
        Task.detached {
            await self.content.keyDown(event: event.asKeyEventArgs)
        }
    }

    public func keyboardManager(_ manager: Win32KeyboardManager, onKeyUp event: Win32KeyEventArgs) {
        Task.detached {
            await self.content.keyUp(event: event.asKeyEventArgs)
        }
    }
}

extension Blend2DWindow: ImagineUIContentDelegate {
    public func needsLayout(_ content: ImagineUIContentType, _ view: View) {
        self.setNeedsLayout()
    }

    public func invalidate(_ content: ImagineUIContentType, bounds: UIRectangle) {
        assert(!bounds.x.isNaN, "!bounds.x.isNaN")
        assert(!bounds.y.isNaN, "!bounds.y.isNaN")
        assert(!bounds.width.isNaN, "!bounds.width.isNaN")
        assert(!bounds.height.isNaN, "!bounds.height.isNaN")

        let screenBounds = bounds
            .inflatedBy(.init(repeating: 3.0))
            .scaled(by: dpiScalingFactor)
            .roundedToLargest()

        let availableBounds =
            UIRectangle(
                x: 0,
                y: 0,
                width: Double(size.width),
                height: Double(size.height)
            )

        guard let clipRegion = screenBounds.intersection(availableBounds) else {
            return
        }

        let message = InvalidateMessage(
            x: LONG(clipRegion.x),
            y: LONG(clipRegion.y),
            width: LONG(clipRegion.width),
            height: LONG(clipRegion.height)
        )
        postMessage(message)
        /*
        DispatchQueue.main.async {
            self.setNeedsDisplay(screenBounds.asRect)
        }
        */
    }

    public func setMouseCursor(
        _ content: ImagineUIContentType,
        cursor: MouseCursorKind
    ) {

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
            SetCursor(hCursor)
            SetClassLongPtrW(hwnd, GCLP_HCURSOR, hCursorToLONG_PTR(hCursor))
        }
    }

    public func setMouseHiddenUntilMouseMoves(_ content: ImagineUIContentType) {
        // TODO: Implement cursor hiding
    }

    public func firstResponderChanged(
        _ content: ImagineUIContentType,
        _ newFirstResponder: KeyboardEventHandler?
    ) {

        if newFirstResponder != nil {
            SetFocus(hwnd)
        }
    }

    public func preferredRenderScaleChanged(
        _ content: ImagineUIContentType,
        renderScale: UIVector
    ) {

        recreateBuffers()
        setNeedsDisplay()
    }

    public func windowDpiScalingFactor(_ content: ImagineUIContentType) -> Double {
        return dpiScalingFactor
    }
}
