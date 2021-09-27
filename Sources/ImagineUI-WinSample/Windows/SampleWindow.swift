import Foundation
import SwiftBlend2D
import ImagineUI_Win
import CassowarySwift
import Blend2DRenderer

class SampleWindow: Blend2DWindowContentType {
    private var lastFrame: TimeInterval = 0
    weak var delegate: Blend2DWindowContentDelegate?
    var bounds: BLRect

    var size: UIIntSize

    var width: Int { size.width }
    var height: Int { size.height }

    let rendererContext = Blend2DRendererContext()

    var preferredRenderScale: UIVector = UIVector(repeating: 1)

    var controlSystem = DefaultControlSystem()

    var rootViews: [RootView]

    var debugDrawFlags: Set<DebugDraw.DebugDrawFlags> = []

    init(size: UIIntSize) {
        self.size = size
        bounds = BLRect(location: .zero, size: BLSize(w: Double(size.width), h: Double(size.height)))
        rootViews = []
        controlSystem.delegate = self

        initWindows()
    }

    func initWindows() {
        let window =
        Window(area: UIRectangle(x: 50, y: 120, width: 320, height: 330),
               title: "Window")
        window.delegate = self
        window.areaIntoConstraintsMask = [.location]
        window.rootControlSystem = controlSystem
        window.invalidationDelegate = self

        let panel = Panel(title: "A Panel")
        let panelContents = StackView(orientation: .vertical)
        panelContents.spacing = 5
        panelContents.clipToBounds = false

        let radioButton = RadioButton(title: "Unselected")
        let radioButton2 = RadioButton(title: "Selected")
        radioButton2.isSelected = true

        let checkBox1 = Checkbox(title: "Unselected")
        let checkBox2 = Checkbox(title: "Partial")
        checkBox2.checkboxState = .partial

        let checkBox3 = Checkbox(title: "Checked")
        checkBox3.checkboxState = .checked
        checkBox3.isEnabled = false

        let button = Button(title: "Button")

        var attributedText = AttributedText()
        attributedText.append("A multi\n")
        attributedText.append("line\n", attributes: [.font: Fonts.defaultFont(size: 20)])
        attributedText.append("label!")
        let label = Label()
        label.attributedText = attributedText
        label.horizontalTextAlignment = .center
        label.verticalTextAlignment = .center

        let textField = TextField()
        textField.text = "Abc"
        textField.placeholderText = "Placeholder"

        let progressBar = ProgressBar()
        progressBar.progress = 0.75

        let sliderView = SliderView()
        sliderView.minimumValue = 0
        sliderView.maximumValue = 1
        sliderView.value = 0.75
        sliderView.stepValue = 0.05
        sliderView.showLabels = true

        let scrollView = ScrollView(scrollBarsMode: .vertical)
        scrollView.backColor = .white
        scrollView.contentSize = .init(width: 0, height: 300)

        let scrollViewLabel = Label()
        scrollViewLabel.text = "A\nScroll\nView"
        scrollViewLabel.horizontalTextAlignment = .center
        scrollViewLabel.verticalTextAlignment = .center
        scrollViewLabel.textColor = .black

        let imageView = ImageView(image: createSampleImage())
        let imageViewPanel = Panel(title: "Image View")

        let firstColumn = StackView(orientation: .vertical)
        firstColumn.spacing = 5
        firstColumn.clipToBounds = false
        let secondColumn = StackView(orientation: .vertical)
        secondColumn.spacing = 5
        secondColumn.clipToBounds = false
        secondColumn.alignment = .fill
        let thirdColumn = StackView(orientation: .vertical)
        thirdColumn.spacing = 5
        thirdColumn.clipToBounds = false

        window.addSubview(firstColumn)
        window.addSubview(secondColumn)
        window.addSubview(thirdColumn)
        firstColumn.addArrangedSubview(panel)
        firstColumn.addArrangedSubview(radioButton)
        firstColumn.addArrangedSubview(radioButton2)
        firstColumn.addArrangedSubview(checkBox1)
        firstColumn.addArrangedSubview(checkBox2)
        firstColumn.addArrangedSubview(checkBox3)
        firstColumn.addArrangedSubview(button)
        secondColumn.addArrangedSubview(progressBar)
        secondColumn.addArrangedSubview(sliderView)
        secondColumn.addArrangedSubview(label)
        secondColumn.addArrangedSubview(textField)
        thirdColumn.addArrangedSubview(imageViewPanel)
        imageViewPanel.addSubview(imageView)
        window.addSubview(scrollView)
        panel.addSubview(panelContents)
        panelContents.addArrangedSubview(radioButton)
        panelContents.addArrangedSubview(radioButton2)
        scrollView.addSubview(scrollViewLabel)

        LayoutConstraint.create(first: window.layout.height,
                                relationship: .greaterThanOrEqual,
                                offset: 330)

        firstColumn.layout.makeConstraints { make in
            make.top == window.contentsLayoutArea + 4
            make.left == window.contentsLayoutArea + 10
        }
        firstColumn.setCustomSpacing(after: panel, 10)
        firstColumn.setCustomSpacing(after: checkBox3, 15)

        panelContents.layout.makeConstraints { make in
            make.edges == panel.containerLayoutGuide
        }

        secondColumn.layout.makeConstraints { make in
            make.right(of: firstColumn, offset: 15)
            make.top == window.contentsLayoutArea + 19
        }
        secondColumn.setCustomSpacing(after: label, 15)

        thirdColumn.layout.makeConstraints { make in
            make.right(of: secondColumn, offset: 15)
            make.top == window.contentsLayoutArea + 4
            make.right <= window.contentsLayoutArea - 8
        }

        imageView.layout.makeConstraints { make in
            make.edges == imageViewPanel.containerLayoutGuide
        }

        progressBar.layout.makeConstraints { make in
            make.width == 100
        }
        label.layout.makeConstraints { make in
            make.height == 60
        }
        textField.layout.makeConstraints { make in
            make.height == 24
        }

        scrollView.layout.makeConstraints { make in
            make.left == window.contentsLayoutArea + 8
            make.under(button, offset: 10)
            make.right == window.contentsLayoutArea - 8
            make.bottom == window.contentsLayoutArea - 8
        }

        scrollViewLabel.setContentHuggingPriority(.horizontal, 50)
        scrollViewLabel.setContentHuggingPriority(.vertical, 50)
        scrollViewLabel.layout.makeConstraints { make in
            make.edges == scrollView.contentView
        }

        button.mouseClicked.addListener(owner: self) { _ in
            label.isVisible.toggle()
        }

        sliderView.valueChanged.addListener(owner: self) { (_, event) in
            progressBar.progress = event.newValue
        }

        window.performLayout()

        createRenderSettingsWindow()

        rootViews.append(window)

        lastFrame = Stopwatch.global.timeIntervalSinceStart()
    }

    func willStartLiveResize() {

    }

    func didEndLiveResize() {

    }

    func didClose() {
        WinLogger.info("\(self): Closed")
        app.requestQuit()
    }

    func resize(_ newSize: UIIntSize) {
        self.size = newSize

        bounds = BLRect(location: .zero, size: BLSize(w: Double(width), h: Double(height)))

        for view in rootViews {
            view.setNeedsLayout()
        }
    }

    func invalidateScreen() {
        delegate?.invalidate(bounds: bounds.asRectangle)
    }

    func update(_ time: TimeInterval) {
        // Fixed-frame update
        let delta = time - lastFrame
        lastFrame = time
        Scheduler.instance.onFixedFrame(delta)

        performLayout()
    }

    func performLayout() {
        // Layout loop
        for rootView in rootViews {
            rootView.performLayout()
        }
    }

    func render(context ctx: BLContext, renderScale: UIVector, clipRegion: ClipRegion) {
        let renderer = Blend2DRenderer(context: ctx)
        renderer.scale(by: renderScale)

        renderer.setFill(.cornflowerBlue)
        renderer.fill(clipRegion.bounds())

        // Redraw loop
        for rootView in rootViews {
            rootView.renderRecursive(in: renderer, screenRegion: clipRegion)
        }

        // Debug render
        for rootView in rootViews {
            DebugDraw.debugDrawRecursive(rootView, flags: debugDrawFlags, in: renderer)
        }
    }

    func mouseDown(event: MouseEventArgs) {
        controlSystem.onMouseDown(event)
    }

    func mouseMoved(event: MouseEventArgs) {
        controlSystem.onMouseMove(event)
    }

    func mouseUp(event: MouseEventArgs) {
        controlSystem.onMouseUp(event)
    }

    func mouseScroll(event: MouseEventArgs) {
        controlSystem.onMouseWheel(event)
    }

    func keyDown(event: KeyEventArgs) {
        controlSystem.onKeyDown(event)
    }

    func keyUp(event: KeyEventArgs) {
        controlSystem.onKeyUp(event)
    }

    func createRenderSettingsWindow() {
        func toggleFlag(_ sample: SampleWindow,
                        _ flag: DebugDraw.DebugDrawFlags,
                        _ event: CancellableValueChangedEventArgs<Checkbox.State>) {

            if event.newValue == .checked {
                sample.debugDrawFlags.insert(flag)
            } else {
                sample.debugDrawFlags.remove(flag)
            }

            sample.invalidateScreen()
        }

        let window = Window(area: .zero, title: "Debug render settings")
        window.delegate = self
        window.areaIntoConstraintsMask = [.location]
        window.setShouldCompress(true)
        window.rootControlSystem = controlSystem
        window.invalidationDelegate = self

        let boundsCheckbox = Checkbox(title: "View Bounds")
        let layoutCheckbox = Checkbox(title: "Layout Guides")
        let constrCheckbox = Checkbox(title: "Constraints")
        let stackView = StackView(orientation: .vertical)
        stackView.spacing = 4

        stackView.addArrangedSubview(boundsCheckbox)
        stackView.addArrangedSubview(layoutCheckbox)
        stackView.addArrangedSubview(constrCheckbox)

        window.addSubview(stackView)

        stackView.layout.makeConstraints { make in
            make.left == window.contentsLayoutArea + 12
            make.top == window.contentsLayoutArea + 12
            make.bottom <= window.contentsLayoutArea - 12
            make.right <= window.contentsLayoutArea - 12
        }

        boundsCheckbox.checkboxStateWillChange.addListener(owner: self) { [weak self] (_, event) in
            guard let self = self else { return }

            toggleFlag(self, .viewBounds, event)
        }
        layoutCheckbox.checkboxStateWillChange.addListener(owner: self) { [weak self] (_, event) in
            guard let self = self else { return }

            toggleFlag(self, .layoutGuideBounds, event)
        }
        constrCheckbox.checkboxStateWillChange.addListener(owner: self) { [weak self] (_, event) in
            guard let self = self else { return }

            toggleFlag(self, .constraints, event)
        }

        rootViews.append(window)
    }

    func createSampleImage() -> Image {
        let imgRenderer = rendererContext.createImageRenderer(width: 64, height: 64)

        let ctx = imgRenderer.renderer

        ctx.clear()
        ctx.setFill(Color.skyBlue)
        ctx.fill(UIRectangle(x: 0, y: 0, width: 64, height: 64))

        // Render two mountains
        ctx.setFill(Color.forestGreen)
        ctx.translate(x: 15, y: 40)
        let mount1 = BLTriangle.unitEquilateral.scaledBy(x: 35, y: 35)
        let mount2 = BLTriangle.unitEquilateral.scaledBy(x: 30, y: 30)

        ctx.fill(
            UIPolygon(vertices: [
                mount1.p0.asVector2,
                mount1.p1.asVector2,
                mount1.p2.asVector2
            ])
        )
        ctx.translate(x: 15, y: 4)
        ctx.fill(
            UIPolygon(vertices: [
                mount2.p0.asVector2,
                mount2.p1.asVector2,
                mount2.p2.asVector2
            ])
        )

        // Render ground
        ctx.resetTransform()
        ctx.fill(UIRectangle(x: 0, y: 45, width: 64, height: 64))

        // Render sun
        ctx.setFill(Color.yellow)
        ctx.fill(UICircle(x: 50, y: 20, radius: 10))

        return imgRenderer.renderedImage()
    }
}

extension SampleWindow: DefaultControlSystemDelegate {
    func bringRootViewToFront(_ rootView: RootView) {
        rootViews.removeAll(where: { $0 == rootView })
        rootViews.append(rootView)

        rootView.invalidate()
    }

    func controlViewUnder(point: UIVector, enabledOnly: Bool) -> ControlView? {
        for window in rootViews.reversed() {
            let converted = window.convertFromScreen(point)
            if let view = window.hitTestControl(converted, enabledOnly: enabledOnly) {
                return view
            }
        }

        return nil
    }

    func setMouseCursor(_ cursor: MouseCursorKind) {
        delegate?.setMouseCursor(cursor)
    }

    func setMouseHiddenUntilMouseMoves() {
        delegate?.setMouseHiddenUntilMouseMoves()
    }
}

extension SampleWindow: RootViewRedrawInvalidationDelegate {
    func rootViewInvalidatedLayout(_ rootView: RootView) {
        delegate?.needsLayout(rootView)
    }

    func rootView(_ rootView: RootView, invalidateRect rect: UIRectangle) {
        delegate?.invalidate(bounds: rect)
    }
}

extension SampleWindow: WindowDelegate {
    func windowWantsToClose(_ window: Window) {
        if let index = rootViews.firstIndex(of: window) {
            rootViews.remove(at: index)
            invalidateScreen()
        }
    }

    func windowWantsToMaximize(_ window: Window) {
        switch window.windowState {
        case .maximized:
            window.setWindowState(.normal)

        case .normal, .minimized:
            window.setWindowState(.maximized)
        }
    }

    func windowWantsToMinimize(_ window: Window) {
        window.setWindowState(.minimized)
    }

    func windowSizeForFullscreen(_ window: Window) -> UISize {
        return bounds.asRectangle.size
    }
}
