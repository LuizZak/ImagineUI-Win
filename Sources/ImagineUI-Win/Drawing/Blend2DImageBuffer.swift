import WinSDK
import WinSDK.WinGDI
import SwiftBlend2D

/// A pairing of BLImage and HBITMAP which map to the same underlying memory
/// block.
class Blend2DImageBuffer {
    private var cHDC: HDC
    private var bitmapInfo: BITMAPINFO

    var blImage: BLImage
    var hBitmap: HBITMAP

    var size: BLSizeI

    convenience init(width: Int, height: Int, format: BLFormat, hdc: HDC) {
        self.init(size: .init(w: Int32(width), h: Int32(height)), format: format, hdc: hdc)
    }

    convenience init(size: UIIntSize, format: BLFormat, hdc: HDC) {
        self.init(size: size.asBLSizeI, format: format, hdc: hdc)
    }

    init(size: BLSizeI, format: BLFormat, hdc: HDC) {
        self.size = size
        self.cHDC = CreateCompatibleDC(hdc)
        self.blImage = BLImage(size: size, format: .xrgb32)

        guard let hBitmap = CreateCompatibleBitmap(hdc, size.w, size.h) else {
            WinLogger.error("Failed to create device-compatible bitmap")
            fatalError()
        }

        self.hBitmap = hBitmap

        SaveDC(cHDC)

        SelectObject(cHDC, hBitmap)

        let bitDepth: WORD = 32

        bitmapInfo = BITMAPINFO()
        bitmapInfo.bmiHeader.biSize = DWORD(MemoryLayout.size(ofValue: bitmapInfo.bmiHeader))
        bitmapInfo.bmiHeader.biWidth = LONG(size.w)
        bitmapInfo.bmiHeader.biHeight = -LONG(size.h)
        bitmapInfo.bmiHeader.biPlanes = 1
        bitmapInfo.bmiHeader.biBitCount = bitDepth
        bitmapInfo.bmiHeader.biCompression = DWORD(BI_RGB)
    }

    deinit {
        DeleteDC(cHDC)
        DeleteObject(hBitmap)
    }

    /// Copies pixels from the Blend2D `blImage` into the GDI `hBitmap`.
    func pushPixelsToGDI(_ rect: UIRectangle) {
        // Release image prior to SetDIBits
        RestoreDC(cHDC, -1)

        let imageData = blImage.getImageData()

        let result = SetDIBits(
            cHDC,
            hBitmap,
            0,
            UINT(imageData.size.h),
            imageData.pixelData,
            &bitmapInfo,
            UINT(DIB_RGB_COLORS)
        )
        if result == 0 {
            WinLogger.error("Error while pushing pixels to GDI: \(Win32Error(win32: GetLastError()))")
            fatalError()
        }

        // Select bitmap again
        SelectObject(cHDC, hBitmap)
    }

    @discardableResult
    func bitBlt(to hdc: HDC!, _ x: Int32, _ y: Int32, _ cx: Int32, _ cy: Int32, _ x1: Int32, _ y1: Int32, _ rop: DWORD) -> Bool {
        BitBlt(hdc, x, y, cx, cy, cHDC, x1, y1, rop)
    }
}
