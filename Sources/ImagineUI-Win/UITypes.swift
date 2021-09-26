import WinSDK
import ImagineUI
import Blend2DRenderer

// MARK: Type defs

public struct Point {
    public static let zero: Self = .init(x: 0, y: 0)

    public var x: Int
    public var y: Int

    @_transparent
    public init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
}

public struct Size {
    public static let zero: Self = .init(width: 0, height: 0)

    public var width: Int
    public var height: Int

    @_transparent
    public init(width: Int, height: Int) {
        self.width = width
        self.height = height
    }
}

public struct Rect {
    public var origin: Point
    public var size: Size
}

// MARK: App <-> Win32 Conversions

extension Rect {
    var asRECT: RECT {
        .init(left: LONG(self.origin.x),
              top: LONG(self.origin.y),
              right: LONG(self.origin.x + self.size.width),
              bottom: LONG(self.origin.y + self.size.height))
    }
}

extension RECT {
    @_transparent
    var asRect: Rect {
        let origin = Point(x: Int(self.left), y: Int(self.top))
        let size = Size(width: Int(self.right - self.left),
                        height: Int(self.bottom - self.top))

        return .init(origin: origin, size: size)
    }
}

extension Point {
    @_transparent
    var asPOINT: POINT {
        .init(x: LONG(self.x), y: LONG(self.y))
    }
}

extension POINT {
    @_transparent
    var asPoint: Point {
        .init(x: Int(self.x), y: Int(self.y))
    }

    @_transparent
    var asSize: Size {
        .init(width: Int(self.x), height: Int(self.y))
    }
}

extension Size {
    @_transparent
    var asPOINT: POINT {
        .init(x: LONG(self.width), y: LONG(self.height))
    }
}

extension Point {
    @_transparent
    internal init<Integer: FixedWidthInteger>(x: Integer, y: Integer) {
        self.init(x: Int(x), y: Int(y))
    }
}

// MARK: ImagineUI <-> App Conversions

extension UIRectangle {
    @_transparent
    var asRect: Rect {
        let origin = Point(x: Int(self.x), y: Int(self.y))
        let size = Size(width: Int(self.width),
                        height: Int(self.height))

        return .init(origin: origin, size: size)
    }
}

extension BLPoint {
    @_transparent
    var asUIPoint: UIPoint {
        UIPoint(x: x, y: y)
    }

    @_transparent
    var asUIVector: UIVector {
        UIVector(x: x, y: y)
    }
}

extension UIIntSize {
    @_transparent
    var asSize: Size {
        Size(width: width, height: height)
    }

    @_transparent
    var asBLSizeI: BLSizeI {
        BLSizeI(w: Int32(width), h: Int32(height))
    }
}

extension Size {
    @_transparent
    var asUIIntSize: UIIntSize {
        .init(width: width, height: height)
    }

    @_transparent
    var asUISize: UISize {
        .init(width: Double(width), height: Double(height))
    }

    @_transparent
    var asBLPoint: BLPoint {
        .init(x: Double(width), y: Double(height))
    }

    @_transparent
    var asBLPointI: BLPointI {
        .init(x: Int32(width), y: Int32(height))
    }

    @_transparent
    var asBLSize: BLSize {
        .init(w: Double(width), h: Double(height))
    }

    @_transparent
    var asBLSizeI: BLSizeI {
        .init(w: Int32(width), h: Int32(height))
    }
}

// MARK: ImagineUI <-> Win32 Conversions

extension UIRectangle {
    @_transparent
    var asRECT: RECT {
        .init(left: LONG(self.location.x),
              top: LONG(self.location.y),
              right: LONG(self.location.x + self.size.width),
              bottom: LONG(self.location.y + self.size.height))
    }
}

extension RECT {
    @_transparent
    var asUIRectangle: UIRectangle {
        .init(left: Double(left), top: Double(top), right: Double(right), bottom: Double(bottom))
    }
}
