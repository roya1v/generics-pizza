@preconcurrency import Combine

extension Publisher where Failure == Never {
    public var stream: AsyncStream<Output> {
        AsyncStream { continuation in
            let cancellable = self.sink { _ in
                continuation.finish()
            } receiveValue: { value in
                continuation.yield(value)
            }
            continuation.onTermination = { _ in
                cancellable.cancel()
            }
        }
    }
}
