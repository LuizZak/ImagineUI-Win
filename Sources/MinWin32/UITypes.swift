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

    @inlinable
    @_transparent
    public static func - (lhs: Self, rhs: Self) -> Self {
        Self.op(lhs, rhs, -)
    }

    @inlinable
    @_transparent
    public static func - (lhs: Self, rhs: Size) -> Self {
        Self.op(lhs, rhs, -)
    }

    @inlinable
    @_transparent
    public static func - (lhs: Size, rhs: Self) -> Self {
        Self.op(lhs, rhs, -)
    }

    @inlinable
    @_transparent
    public static func + (lhs: Self, rhs: Self) -> Self {
        Self.op(lhs, rhs, +)
    }

    @inlinable
    @_transparent
    public static func + (lhs: Self, rhs: Size) -> Self {
        Self.op(lhs, rhs, +)
    }

    @inlinable
    @_transparent
    public static func + (lhs: Size, rhs: Self) -> Self {
        Self.op(lhs, rhs, +)
    }

    @inlinable
    @_transparent
    public static func / (lhs: Self, rhs: Int) -> Self {
        Self.op(lhs, rhs, /)
    }

    @inlinable
    @_transparent
    public static func op(_ lhs: Self, _ rhs: Int, _ op: (Int, Int) -> Int) -> Self {
        .init(x: op(lhs.x, rhs), y: op(lhs.y, rhs))
    }

    @inlinable
    @_transparent
    public static func op(_ lhs: Self, _ rhs: Self, _ op: (Int, Int) -> Int) -> Self {
        .init(x: op(lhs.x, rhs.x), y: op(lhs.y, rhs.y))
    }

    @inlinable
    @_transparent
    public static func op(_ lhs: Self, _ rhs: Size, _ op: (Int, Int) -> Int) -> Self {
        .init(x: op(lhs.x, rhs.width), y: op(lhs.y, rhs.height))
    }

    @inlinable
    @_transparent
    public static func op(_ lhs: Size, _ rhs: Self, _ op: (Int, Int) -> Int) -> Self {
        .init(x: op(lhs.width, rhs.y), y: op(lhs.height, rhs.y))
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

    @inlinable
    @_transparent
    public static func / (lhs: Self, rhs: Int) -> Self {
        Self.op(lhs, rhs, /)
    }

    @inlinable
    @_transparent
    public static func op(_ lhs: Self, _ rhs: Int, _ op: (Int, Int) -> Int) -> Self {
        .init(width: op(lhs.width, rhs), height: op(lhs.height, rhs))
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

    @_transparent
    var center: POINT {
        return POINT(x: (left + right) / 2, y: (top + bottom) / 2)
    }

    @_transparent
    var size: SIZE {
        return SIZE(cx: right - left, cy: bottom - top)
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

    @_transparent
    var asSIZE: SIZE {
        .init(cx: LONG(self.width), cy: LONG(self.height))
    }
}

public extension SIZE {
    @_transparent
    var asPoint: Point {
        .init(x: Int(self.cx), y: Int(self.cy))
    }

    @_transparent
    var asSize: Size {
        .init(width: Int(self.cx), height: Int(self.cy))
    }
}

public extension Point {
    @_transparent
    internal init<Integer: FixedWidthInteger>(x: Integer, y: Integer) {
        self.init(x: Int(x), y: Int(y))
    }
}
