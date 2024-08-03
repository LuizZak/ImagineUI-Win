import WinSDK
import WinSDK.WinGDI
import SwiftBlend2D
import MinWin32

/// A pairing of BLImage and HBITMAP which map to the same underlying memory
/// block.
/// Blend2D bitmaps are always created with format BLFormat.xrgb32.
class Blend2DImageBuffer {
    private var bitmapInfo: BITMAPINFO
    private var bitmapPointer: UnsafeMutableRawPointer?

    let blImage: BLImage
    let blContext: BLContext
    let renderingThreads: UInt32
    let hBitmap: HBITMAP

    let size: BLSizeI

    convenience init(
        width: Int,
        height: Int,
        renderingThreads: UInt32,
        hdc: HDC
    ) {
        self.init(
            size: .init(w: Int32(width), h: Int32(height)),
            renderingThreads: renderingThreads,
            hdc: hdc
        )
    }

    convenience init(
        size: UIIntSize,
        renderingThreads: UInt32,
        hdc: HDC
    ) {
        self.init(
            size: size.asBLSizeI,
            renderingThreads: renderingThreads,
            hdc: hdc
        )
    }

    init(size: BLSizeI, renderingThreads: UInt32, hdc: HDC) {
        self.size = size
        self.renderingThreads = renderingThreads

        let bitDepth: WORD = 32

        bitmapInfo = BITMAPINFO()
        bitmapInfo.bmiHeader.biSize = DWORD(MemoryLayout.size(ofValue: bitmapInfo.bmiHeader))
        bitmapInfo.bmiHeader.biWidth = LONG(size.w)
        bitmapInfo.bmiHeader.biHeight = -LONG(size.h)
        bitmapInfo.bmiHeader.biPlanes = 1
        bitmapInfo.bmiHeader.biBitCount = bitDepth
        bitmapInfo.bmiHeader.biCompression = DWORD(BI_RGB)

        let screen = GetDC(nil)
        defer { ReleaseDC(nil, screen) }

        self.hBitmap = CreateDIBSection(screen, &bitmapInfo, UINT(DIB_RGB_COLORS), &bitmapPointer, nil, 0)

        guard let pointer = bitmapPointer else {
            WinLogger.error("Failed to create DIB")
            fatalError()
        }

        let stride = Int(size.w) * 4
        self.blImage = BLImage(fromUnownedData: pointer, stride: stride, size: size, format: .xrgb32)
        self.blContext = BLContext(image: blImage, options: .init(threadCount: renderingThreads))!
    }

    deinit {
        blContext.end()
        DeleteObject(hBitmap)
    }

    /// Copies pixels from the Blend2D `blImage` into the GDI `hBitmap`.
    func pushPixelsToGDI(_ rect: UIRectangle) {
        // Noop: Using CreateDIBSection
    }

    @discardableResult
    func bitBlt(to hdc: HDC!, _ x: Int32, _ y: Int32, _ cx: Int32, _ cy: Int32, _ x1: Int32, _ y1: Int32, _ rop: DWORD) -> Bool {
        let cHDC = CreateCompatibleDC(hdc)
        let oldBitmap = SelectObject(cHDC, hBitmap)
        defer {
            SelectObject(cHDC, oldBitmap)
            DeleteDC(cHDC)
        }

        return BitBlt(hdc, x, y, cx, cy, cHDC, x1, y1, rop)
    }
}
