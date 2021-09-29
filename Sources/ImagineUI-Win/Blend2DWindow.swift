import ImagineUI
import Blend2DRenderer
import WinSDK
import WinSDK.User
import WinSDK.WinGDI

public class Blend2DWindow: Win32Window {
    private var keyboardManager: Win32KeyboardManager?
    private var buffer: Blend2DGDIDoubleBuffer?

    /// Returns the computed size for `content`, based on the window's scale
    /// divided by `dpiScalingFactor`.
    var scaledContentSize: UIIntSize {
        size.asUIIntSize.scaled(by: 1.0 / dpiScalingFactor)
    }

    /// Content size, equal to this window's size scaled by the current `dpiScalingFactor`
    /// value.
    var contentSize: UIIntSize {
        size.asUIIntSize.scaled(by: dpiScalingFactor)
    }

    /// Rate of update calls per second.
    /// Affects how much the content.update() function is called each second.
    public var updateRate: Double = 60

    public let updateStopwatch = Stopwatch.start()
    public let content: Blend2DWindowContentType

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

        initializeClipboard()
        initializeKeyboardManager()
        initializeContent()

        recreateBuffers()
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
        content.resize(scaledContentSize)

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

        buffer = .init(contentSize: contentSize.asBLSizeI, format: .xrgb32, hdc: hdc, scale: content.preferredRenderScale)
    }

    func update() {
        content.update(Stopwatch.global.timeIntervalSinceStart())
    }

    // MARK: Events

    override func onResize(_ message: WindowMessage) {
        super.onResize(message)

        resizeApp()
    }

    override func onDPIChanged(_ message: WindowMessage) {
        super.onDPIChanged(message)

        resizeApp()

        WinLogger.info("DPI for window changed: \(dpi), new sizes: contentSize: \(contentSize), content.size: \(content.size)")
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

        buffer.renderingToBuffer { (buffer, scale) in
            paintImmediateBuffer(image: buffer, scale: scale, rect: uiRect)
        }

        buffer.renderBufferToScreen(hdc, rect: ps.rcPaint)
    }

    private func paintImmediateBuffer(image: BLImage, scale: UIVector, rect: UIRectangle) {
        let options = BLContext.CreateOptions(threadCount: 0) // TODO: Multi-threading on Windows is crashing, disable threads in Blend2D for now.
        let ctx = BLContext(image: image, options: options)!

        let clip = Blend2DClipRegion(region: .init(rectangle: .init(rounding: rect.asBLRect)))

        content.render(context: ctx, renderScale: scale * dpiScalingFactor, clipRegion: clip)

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
        guard let keyboardManager = keyboardManager else {
            return super.onKeyDown(message)
        }

        return keyboardManager.onKeyDown(message)
    }

    override func onKeyUp(_ message: WindowMessage) -> LRESULT? {
        guard let keyboardManager = keyboardManager else {
            return super.onKeyUp(message)
        }

        return keyboardManager.onKeyUp(message)
    }

    override func onSystemKeyDown(_ message: WindowMessage) -> LRESULT? {
        guard let keyboardManager = keyboardManager else {
            return super.onSystemKeyDown(message)
        }

        return keyboardManager.onSystemKeyDown(message)
    }

    override func onSystemKeyUp(_ message: WindowMessage) -> LRESULT? {
        guard let keyboardManager = keyboardManager else {
            return super.onSystemKeyUp(message)
        }

        return keyboardManager.onSystemKeyUp(message)
    }

    override func onKeyCharDown(_ message: WindowMessage) -> LRESULT? {
        guard let keyboardManager = keyboardManager else {
            return super.onKeyCharDown(message)
        }

        return keyboardManager.onKeyCharDown(message)
    }

    override func onKeyChar(_ message: WindowMessage) -> LRESULT? {
        guard let keyboardManager = keyboardManager else {
            return super.onKeyChar(message)
        }

        return keyboardManager.onKeyChar(message)
    }

    override func onKeyDeadChar(_ message: WindowMessage) -> LRESULT? {
        guard let keyboardManager = keyboardManager else {
            return super.onKeyDeadChar(message)
        }

        return keyboardManager.onKeyDeadChar(message)
    }

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
        var modifiers: KeyboardModifier = []

        // Buttons
        if IS_BIT_ON(message.wParam, MK_LBUTTON) {
            buttons.insert(.left)
        }
        if IS_BIT_ON(message.wParam, MK_MBUTTON) {
            buttons.insert(.middle)
        }
        if IS_BIT_ON(message.wParam, MK_RBUTTON) {
            buttons.insert(.right)
        }
        // Modifiers
        if IS_BIT_ON(message.wParam, MK_CONTROL) {
            modifiers.insert(.control)
        }
        if IS_BIT_ON(message.wParam, MK_SHIFT) {
            modifiers.insert(.shift)
        }

        let event = MouseEventArgs(
            location: location,
            buttons: buttons,
            delta: .zero,
            clicks: 0,
            modifiers: modifiers
        )

        return event
    }
}

extension Blend2DWindow: Win32KeyboardManagerDelegate {
    func keyboardManager(_ manager: Win32KeyboardManager, onKeyPress event: KeyPressEventArgs) {
        content.keyPress(event: event)
    }

    func keyboardManager(_ manager: Win32KeyboardManager, onKeyDown event: KeyEventArgs) {
        content.keyDown(event: event)
    }

    func keyboardManager(_ manager: Win32KeyboardManager, onKeyUp event: KeyEventArgs) {
        content.keyUp(event: event)
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
