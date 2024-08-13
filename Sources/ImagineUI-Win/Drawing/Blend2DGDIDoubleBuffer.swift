import WinSDK
import WinSDK.WinGDI
import SwiftBlend2D
import ImagineUI

class Blend2DGDIDoubleBuffer {
    private var contentSize: BLSizeI
    private var scale: UIVector
    private let format: BLFormat
    private let renderingThreads: UInt32

    private var buffer: BufferKind

    /// - precondition: contentSize.w > 0 && contentSize.h > 0 && scale > .zero
    init(
        contentSize: BLSizeI,
        format: BLFormat,
        renderingThreads: UInt32,
        hdc: HDC,
        scale: UIVector = .init(repeating: 1)
    ) {

        precondition(contentSize.w > 0 && contentSize.h > 0 && scale > .zero)
        self.contentSize = contentSize
        self.scale = scale
        self.format = format
        self.renderingThreads = renderingThreads
        self.buffer = .makeBuffer(
            size: contentSize,
            renderingThreads: renderingThreads,
            format: format,
            scale: scale,
            hdc: hdc
        )
    }

    /// - precondition: scale > .zero
    func setPrimaryBufferScale(_ scale: UIVector) {
        precondition(scale > .zero)
        self.scale = scale
    }

    /// - precondition: `primary > .zero && scale > .zero`
    func resizeBuffer(primary: BLSizeI, scale: UIVector, hdc: HDC) {
        guard contentSize != primary || self.scale != scale else { return }

        self.buffer.end()
        self.buffer = .makeBuffer(
            size: primary,
            renderingThreads: renderingThreads,
            format: format,
            scale: scale,
            hdc: hdc
        )
    }

    func renderingToBuffer(_ block: (BLContext, _ renderScale: UIVector) -> Void) {
        block(buffer.immediateBufferContext, scale)
    }

    func renderBufferToScreen(
        _ hdc: HDC,
        rect: RECT? = nil
    ) {

        let screenBuffer = buffer.screenBuffer

        let rect = rect ?? RECT(
            left: 0,
            top: 0,
            right: screenBuffer.blImage.size.w,
            bottom: screenBuffer.blImage.size.h
        )

        buffer.pushPixelsToScreenBuffer(rect: rect)

        let w = rect.right - rect.left
        let h = rect.bottom - rect.top
        screenBuffer.pushPixelsToGDI(rect.asUIRectangle)
        screenBuffer.bitBlt(to: hdc, rect.left, rect.top, w, h, rect.left, rect.top, SRCCOPY)
    }
}

private enum BufferKind {
    case singleBuffer(Blend2DImageBuffer)
    case doubleBuffer(
        primaryContext: BLContext,
        primaryBuffer: BLImage,
        primaryBufferScale: UIVector,
        secondaryBuffer: Blend2DImageBuffer
    )

    var immediateBufferContext: BLContext {
        switch self {
        case .singleBuffer(let buffer):
            return buffer.blContext

        case .doubleBuffer(let primaryContext, _, _, _):
            return primaryContext
        }
    }

    var immediateBuffer: BLImage {
        switch self {
        case .singleBuffer(let buffer):
            return buffer.blImage

        case .doubleBuffer(_, let primaryBuffer, _, _):
            return primaryBuffer
        }
    }

    var screenBuffer: Blend2DImageBuffer {
        switch self {
        case .singleBuffer(let b),
             .doubleBuffer(_, _, _, let b):
            return b
        }
    }

    /// Clears memory retained by this buffer reference.
    func end() {
        switch self {
        case .singleBuffer:
            break

        case .doubleBuffer(let primaryContext, _, _, _):
            primaryContext.end()
        }
    }

    func pushPixelsToScreenBuffer(rect: RECT) {
        switch self {
        case .singleBuffer:
            break

        case .doubleBuffer(_, let primaryBuffer, let primaryBufferScale, let secondaryBuffer):
            let ctx = secondaryBuffer.blContext

            ctx.clipToRect(rect.asBLRect)

            let sizeI = primaryBuffer.size.scaled(by: 1 / primaryBufferScale)
            let size = BLSize(w: Double(sizeI.w), h: Double(sizeI.h))
            ctx.blitScaledImage(primaryBuffer, rectangle: BLRect(location: .zero, size: size))

            ctx.flush(flags: .sync)
        }
    }

    static func makeBuffer(
        size: BLSizeI,
        renderingThreads: UInt32,
        format: BLFormat,
        scale: UIVector,
        hdc: HDC
    ) -> Self {
        let secondary = Blend2DImageBuffer(
            size: size,
            renderingThreads: renderingThreads,
            hdc: hdc
        )

        if scale == 1.0 {
            return .singleBuffer(secondary)
        } else {
            let primary = BLImage(size: size.scaled(by: scale), format: format)
            let primaryContext = BLContext(image: primary, options: .init(threadCount: renderingThreads))!

            return .doubleBuffer(
                primaryContext: primaryContext,
                primaryBuffer: primary,
                primaryBufferScale: scale,
                secondaryBuffer: secondary
            )
        }
    }
}
