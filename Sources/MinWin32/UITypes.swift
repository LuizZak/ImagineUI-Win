import WinSDK

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

    @_transparent
    public init(origin: Point, size: Size) {
        self.origin = origin
        self.size = size
    }
}

// MARK: App <-> Win32 Conversions

public extension Rect {
    @_transparent
    var asRECT: RECT {
        .init(left: LONG(self.origin.x),
              top: LONG(self.origin.y),
              right: LONG(self.origin.x + self.size.width),
              bottom: LONG(self.origin.y + self.size.height))
    }
}

public extension RECT {
    @_transparent
    var asRect: Rect {
        let origin = Point(x: Int(self.left), y: Int(self.top))
        let size = Size(width: Int(self.right - self.left),
                        height: Int(self.bottom - self.top))

        return .init(origin: origin, size: size)
    }
}

public extension Point {
    @_transparent
    var asPOINT: POINT {
        .init(x: LONG(self.x), y: LONG(self.y))
    }
}

public extension POINT {
    @_transparent
    var asPoint: Point {
        .init(x: Int(self.x), y: Int(self.y))
    }

    @_transparent
    var asSize: Size {
        .init(width: Int(self.x), height: Int(self.y))
    }
}

public extension Size {
    @_transparent
    var asPOINT: POINT {
        .init(x: LONG(self.width), y: LONG(self.height))
    }
}

public extension Point {
    @_transparent
    internal init<Integer: FixedWidthInteger>(x: Integer, y: Integer) {
        self.init(x: Int(x), y: Int(y))
    }
}
