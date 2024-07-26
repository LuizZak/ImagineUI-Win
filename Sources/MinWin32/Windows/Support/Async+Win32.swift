import Foundation

/// Based on: https://forums.swift.org/t/using-async-functions-from-synchronous-functions-and-breaking-all-the-rules/59782/4

fileprivate class Box<ResultType> {
	var result: Result<ResultType, Error>? = nil
}

/// Unsafely awaits an async function from a synchronous context.
func _unsafeWait<ResultType>(priority: TaskPriority, _ f: @escaping () async throws -> ResultType) throws -> ResultType {
	let box = Box<ResultType>()
	let semaphore = DispatchSemaphore(value: 0)
	Task(priority: priority) {
		do {
			let val = try await f()
			box.result = .success(val)
		} catch {
			box.result = .failure(error)
		}
		semaphore.signal()
	}
	semaphore.wait()
	return try box.result!.get()
}
