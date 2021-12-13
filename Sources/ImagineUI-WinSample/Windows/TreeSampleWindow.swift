import Foundation
import CassowarySwift
import SwiftBlend2D
import Blend2DRenderer
import MinWin32
import ImagineUI_Win

private class DataSource: TreeViewDataSource {
    let icon: Image = {
        let context = Blend2DRendererContext().createImageRenderer(width: 10, height: 10)

        context.renderer.clear(.black)

        return context.renderedImage()
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

class TreeSampleWindow: ImagineUIWindowContent {
    private var timer: Timer?
    private let data: DataSource = DataSource()

    override init(size: UIIntSize = .init(width: 600, height: 500)) {
        super.init(size: size)
    }

    deinit {
        timer?.invalidate()
    }

    override func initialize() {
        super.initialize()

        initializeWindows()
        initializeTimer()
    }

    func initializeWindows() {
        let window =
            Window(area: UIRectangle(x: 50, y: 120, width: 320, height: 330),
                   title: "Window")
        window.areaIntoConstraintsMask = [.location]

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

        createRenderSettingsWindow()

        addRootView(window)
    }

    private func initializeTimer() {
        let timer = Timer(timeInterval: 1 / 60.0, repeats: true) { [weak self] _ in
            self?.update(Stopwatch.global.timeIntervalSinceStart())
        }

        RunLoop.main.add(timer, forMode: .default)

        self.timer = timer
    }

    override func didCloseWindow() {
        super.didCloseWindow()

        app.requestQuit()
    }

    func createRenderSettingsWindow() {
        func toggleFlag(_ sample: TreeSampleWindow,
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
}
