import Foundation
import CassowarySwift
import SwiftBlend2D
import Blend2DRenderer
import MinWin32
import ImagineUI_Win

@ImagineActor
class SampleWindow: ImagineUIWindowContent {
    nonisolated(unsafe) private var timer: Timer?
    private let data: TreeDataSource = TreeDataSource()
    private var comboBoxSelection: Int = 1

    let rendererContext = Blend2DRendererContext()

    override init(size: UIIntSize = .init(width: 600, height: 500)) {
        super.init(size: size)
    }

    deinit {
        timer?.invalidate()
    }

    override func initialize() {
        super.initialize()

        createSampleWindow()
        createTreeViewWindow()
        createRenderSettingsWindow()
        initializeTimer()
    }

    @ImagineActor
    func createSampleWindow() {
        let window =
            Window(area: UIRectangle(x: 50, y: 120, width: 320, height: 330),
                   title: "Window")
        window.delegate = self
        window.areaIntoConstraintsMask = [.location]

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
        let label = Label(textColor: .white)
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

        let scrollViewLabel = Label(textColor: .white)
        scrollViewLabel.text = "A\nScroll\nView"
        scrollViewLabel.horizontalTextAlignment = .center
        scrollViewLabel.verticalTextAlignment = .center
        scrollViewLabel.textColor = .black

        let imageView = ImageView(image: createSampleImage())
        let imageViewPanel = Panel(title: "Image View")

        let comboBox = ComboBox()
        comboBox.dataSource = self
        comboBox.didSelect.addWeakListener(self) { (self, event) in
            self.comboBoxSelection = event.args
        }

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
        thirdColumn.addArrangedSubview(comboBox)
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

        panelContents.layout.makeConstraints { make in
            make.edges == panel.containerLayoutGuide
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
            make.width == scrollView.contentView
        }

        scrollViewLabel.setContentHuggingPriority(.horizontal, 50)
        scrollViewLabel.setContentHuggingPriority(.vertical, 50)
        scrollViewLabel.layout.makeConstraints { make in
            make.edges == scrollView.contentView
        }

        button.mouseClicked.addListener(weakOwner: self) { _ in
            label.isVisible.toggle()
        }

        sliderView.valueChanged.addListener(weakOwner: self) { (_, event) in
            progressBar.progress = event.newValue
        }

        window.performLayout()

        addRootView(window)
    }

    @ImagineActor
    func createTreeViewWindow() {
        let window =
            Window(area: UIRectangle(x: 150, y: 50, width: 320, height: 330),
                   title: "Window")
        window.areaIntoConstraintsMask = [.location]
        window.delegate = self

        let tree = TreeView()
        tree.dataSource = data
        tree.reloadData()

        window.addSubview(tree)

        LayoutConstraint.create(first: window.layout.height,
                                relationship: .greaterThanOrEqual,
                                offset: 100)

        tree.layout.makeConstraints { make in
            make.edges == window.contentsLayoutArea - 12
        }

        window.performLayout()

        addRootView(window)
    }

    private func initializeTimer() {
        let timer = Timer(timeInterval: 1 / 60.0, repeats: true) { [weak self] _ in
            Task.detached { [weak self] in
                await self?.update(Stopwatch.global.timeIntervalSinceStart())
            }
        }

        RunLoop.main.add(timer, forMode: .default)

        self.timer = timer
    }

    override func didCloseWindow() {
        super.didCloseWindow()

        app.requestQuit()
    }

    @ImagineActor
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
        window.areaIntoConstraintsMask = [.location]
        window.setShouldCompress(true)
        window.delegate = self

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

        boundsCheckbox.checkboxStateWillChange.addListener(weakOwner: self) { [weak self] (_, event) in
            guard let self = self else { return }

            toggleFlag(self, .viewBounds, event)
        }
        layoutCheckbox.checkboxStateWillChange.addListener(weakOwner: self) { [weak self] (_, event) in
            guard let self = self else { return }

            toggleFlag(self, .layoutGuideBounds, event)
        }
        constrCheckbox.checkboxStateWillChange.addListener(weakOwner: self) { [weak self] (_, event) in
            guard let self = self else { return }

            toggleFlag(self, .constraints, event)
        }

        addRootView(window)
    }

    private func createSampleImage() -> Image {
        let imgRenderer = rendererContext.createImageRenderer(width: 64, height: 64)

        return imgRenderer.withRenderer { renderer in
            renderer.clear()
            renderer.setFill(Color.skyBlue)
            renderer.fill(UIRectangle(x: 0, y: 0, width: 64, height: 64))

            // Render two mountains
            renderer.setFill(Color.forestGreen)
            renderer.translate(x: 15, y: 40)
            let mount1 = BLTriangle.unitEquilateral.scaledBy(x: 35, y: 35)
            let mount2 = BLTriangle.unitEquilateral.scaledBy(x: 30, y: 30)

            renderer.fill(
                UIPolygon(vertices: [
                    mount1.p0.asUIVector,
                    mount1.p1.asUIVector,
                    mount1.p2.asUIVector
                ])
            )
            renderer.translate(x: 15, y: 4)
            renderer.fill(
                UIPolygon(vertices: [
                    mount2.p0.asUIVector,
                    mount2.p1.asUIVector,
                    mount2.p2.asUIVector
                ])
            )

            // Render ground
            renderer.resetTransform()
            renderer.fill(UIRectangle(x: 0, y: 45, width: 64, height: 64))

            // Render sun
            renderer.setFill(Color.yellow)
            renderer.fill(UICircle(x: 50, y: 20, radius: 10))
        }
    }
}

extension SampleWindow: ComboBox.DataSource {
    var comboBoxItems: [AttributedText] {
        ["Apples", "Oranges", "Mangoes", "Grapes", "Bananas", "Strawberries", "Blueberries", "Watermelons"]
    }

    func comboBox(_ comboBox: ComboBox, itemAt index: Int) -> ComboBoxItemEntry {
        return .item(.init(title: comboBoxItems[index]))
    }

    func comboBoxItemCount(_ comboBox: ComboBox) -> Int {
        return self.comboBoxItems.count
    }

    func comboBoxSelectedItemIndex(_ comboBox: ComboBox) -> Int {
        return comboBoxSelection
    }
}

private class TreeDataSource: TreeView.DataSource {
    let icon: Image = {
        let context = Blend2DRendererContext().createImageRenderer(width: 10, height: 10)

        return context.withRenderer { renderer in
            renderer.clear(.black)
        }
    }()

    func hasSubItems(at index: TreeView.ItemIndex) -> Bool {
        if index == TreeView.ItemIndex(parent: .root, index: 2) {
            return true
        }
        if index.asHierarchyIndex.isSubHierarchy(of: TreeView.HierarchyIndex(indices: [2, 0])) {
            return true
        }

        return false
    }

    func numberOfItems(at hierarchyIndex: TreeView.HierarchyIndex) -> Int {
        if hierarchyIndex.isRoot {
            return 10
        }
        if hierarchyIndex.indices == [2] {
            return 2
        }
        if hierarchyIndex.isSubHierarchy(of: TreeView.HierarchyIndex(indices: [2, 0])) {
            return 1
        }

        return 0
    }

    func titleForItem(at index: TreeView.ItemIndex) -> AttributedText {
        if !index.parent.isRoot {
            return "Item \(index.parent.indices.map { "\($0 + 1)" }.joined(separator: " -> ")) -> \(index.index + 1)"
        }

        return "Item \(index.index + 1)"
    }

    func iconForItem(at index: TreeView.ItemIndex) -> Image? {
        if index.asHierarchyIndex.indices == [3] || index.asHierarchyIndex.indices == [2, 0, 0] {
            return icon
        }

        return nil
    }
}
