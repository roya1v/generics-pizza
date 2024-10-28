import Vapor
import SotoS3

// swiftlint:disable nesting
extension Application {
    struct OrderDispatcherKey: StorageKey {
        typealias Value = OrderDispatcher
    }

    var dispatcher: OrderDispatcher {
        guard let dispatcher = self.storage[OrderDispatcherKey.self] else {
            let newDispatcher = OrderDispatcher(logger: logger) { updatedOrder in
                if let order = try? await OrderEntry.find(updatedOrder.id, on: self.db) {
                    order.state = updatedOrder.state!
                    try? await order.save(on: self.db)
                }
            }
            self.storage.set(OrderDispatcherKey.self, to: newDispatcher)
            return newDispatcher
        }
        return dispatcher
    }
}

extension Request {
    var dispatcher: OrderDispatcher {
        return application.dispatcher
    }
}
// swiftlint:enable nesting
