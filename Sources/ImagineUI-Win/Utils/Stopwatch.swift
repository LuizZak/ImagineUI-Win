import Foundation
import WinSDK

/// A high-precision stopwatch that measures time intervals in seconds as a
// double-precision floating-point number.
public class Stopwatch {
    private static let frequency: LARGE_INTEGER = {
        var ret: LARGE_INTEGER
        ret = LARGE_INTEGER()

        QueryPerformanceFrequency(&ret)

        return ret
    }()

    /// A global stopwatch that starts counting from the moment this variable is
    /// first accessed.
    public static let global = Stopwatch.start()

    var start: LARGE_INTEGER = LARGE_INTEGER()

    private init() {
        QueryPerformanceCounter(&start)
    }

    /// Returns a number of seconds since this stopwatch was started.
    public func timeIntervalSinceStart() -> TimeInterval {
        var end: LARGE_INTEGER = LARGE_INTEGER()
        QueryPerformanceCounter(&end)

        let delta_us = Double(end.QuadPart - start.QuadPart) / Double(Self.frequency.QuadPart)

        return delta_us
    }

    public func restart() {
        QueryPerformanceCounter(&start)
    }

    public static func start() -> Stopwatch {
        Stopwatch()
    }
}
