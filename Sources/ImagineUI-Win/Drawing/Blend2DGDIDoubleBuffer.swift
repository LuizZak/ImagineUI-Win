import WinSDK
import WinSDK.WinGDI
import SwiftBlend2D
import ImagineUI

class Blend2DGDIDoubleBuffer {
    private var contentSize: BLSizeI
    private var scale: UIVector
    private let format: BLFormat

    private var buffer: BufferKind

    /// - precondition: contentSize.w > 0 && contentSize.h > 0 && scale > .zero
    init(contentSize: BLSizeI, format: BLFormat, hdc: HDC, scale: UIVector = .init(repeating: 1)) {
        precondition(contentSize.w > 0 && contentSize.h > 0 && scale > .zero)
        self.contentSize = contentSize
        self.scale = scale
        self.format = format
        self.buffer = .makeBuffer(size: contentSize, format: format, scale: scale, hdc: hdc)
    }

    /// - precondition: scale > .zero
    func setPrimaryBufferScale(_ scale: UIVector) {
        precondition(scale > .zero)
        self.scale = scale
    }

    /// - precondition: `primary > .zero && scale > .zero`
    func resizeBuffer(primary: BLSizeI, scale: UIVector, hdc: HDC) {
        guard contentSize != primary || self.scale != scale else { return }

        self.buffer = .makeBuffer(size: primary, format: format, scale: scale, hdc: hdc)
    }

    func renderingToBuffer(_ block: (BLImage, _ renderScale: UIVector) -> Void) {
        block(buffer.immediateBuffer, scale)
    }

    func renderBufferToScreen(_ hdc: HDC, rect: RECT? = nil) {
        let screenBuffer = buffer.screenBuffer

        let rect = rect ?? RECT(left: 0,
                                top: 0,
                                right: screenBuffer.blImage.size.w,
                                bottom: screenBuffer.blImage.size.h)

        let w = rect.right - rect.left
        let h = rect.bottom - rect.top
        screenBuffer.pushPixelsToGDI(rect.asUIRectangle)
        screenBuffer.bitBlt(to: hdc, rect.left, rect.top, w, h, rect.left, rect.top, SRCCOPY)
    }
}

private enum BufferKind {
    case singleBuffer(Blend2DImageBuffer)
    case doubleBuffer(primaryBuffer: BLImage, primaryBufferScale: UIVector, secondaryBuffer: Blend2DImageBuffer)

    var immediateBuffer: BLImage {
        switch self {
        case .singleBuffer(let buffer):
            return buffer.blImage
        case .doubleBuffer(let primaryBuffer, _, _):
            return primaryBuffer
        }
    }

    var screenBuffer: Blend2DImageBuffer {
        switch self {
        case .singleBuffer(let b),
             .doubleBuffer(_, _, let b):
            return b
        }
    }

    static func makeBuffer(size: BLSizeI, format: BLFormat, scale: UIVector, hdc: HDC) -> Self {
        let secondary = Blend2DImageBuffer(size: size, hdc: hdc)

        if scale == 1.0 {
            return .singleBuffer(secondary)
        } else {
            let primary = BLImage(size: size.scaled(by: scale), format: format)
            return .doubleBuffer(primaryBuffer: primary, primaryBufferScale: scale, secondaryBuffer: secondary)
        }
    }
}
