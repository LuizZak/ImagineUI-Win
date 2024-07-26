import XCTest
@testable import ImagineUI_Win

final class ImagineUI_WinTests: XCTestCase {
    func testTaskTimer() async {
        let timer = TaskTimer.spawn()
        var container = TaskContainer.task(timer)

        container.cancel()
        container = TaskContainer.task(TaskTimer.spawn())
    }
}

class TaskTimer {
    var task: Task<Void, any Error>

    init(task: Task<Void, any Error>) {
        self.task = task
    }

    deinit {
        task.cancel()
    }

    func cancel() {
        task.cancel()
    }

    static func spawn() -> TaskTimer {
        return TaskTimer(task: .init {
            try await Task.sleep(nanoseconds: 1_000_000_000)
        })
    }
}

enum TaskContainer {
    case none
    case task(TaskTimer)

    func cancel() {
        switch self {
        case .none:
            break

        case .task(let timer):
            timer.cancel()
        }
    }
}
