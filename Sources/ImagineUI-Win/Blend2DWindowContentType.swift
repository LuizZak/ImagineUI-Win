import Foundation
import SwiftBlend2D
import ImagineUI

public protocol Blend2DWindowContentType: AnyObject {
    var size: UIIntSize { get }
    var preferredRenderScale: UIVector { get }

    var delegate: Blend2DWindowContentDelegate? { get set }

    func willStartLiveResize()
    func didEndLiveResize()
    func resize(_ newSize: UIIntSize)

    // func update(_ time: TimeInterval)
    func performLayout()
    func render(context ctx: BLContext, renderScale: UIVector, clipRegion: ClipRegion)

    func mouseDown(event: MouseEventArgs)
    func mouseMoved(event: MouseEventArgs)
    func mouseUp(event: MouseEventArgs)
    func mouseScroll(event: MouseEventArgs)

    func keyDown(event: KeyEventArgs)
    func keyUp(event: KeyEventArgs)
    func keyPress(event: KeyPressEventArgs)

    // MARK: Events

    func didClose()
}

public protocol Blend2DWindowContentDelegate: AnyObject {
    func needsLayout(_ view: View)
    func invalidate(bounds: UIRectangle)
    func setMouseCursor(_ cursor: MouseCursorKind)
    func setMouseHiddenUntilMouseMoves()
    func firstResponderChanged(_ newFirstResponder: KeyboardEventHandler?)
    func preferredRenderScaleChanged(_ renderScale: UIVector)
}
