import Fluent
import Vapor
import SharedModels

extension OrdersController {
    /// Get the current orders.
    func getCurrent(req: Request) async throws -> [OrderModel] {
        try req.requireEmployeeOrAdminUser()
        return try await OrderEntry.query(on: req.db)
            .filter(\.$state != .finished)
            .with(\.$items) { $0.with(\.$item) }
            .all()
            .toSharedModels()
    }

    /// Get all finished orders.
    func getHistory(req: Request) async throws -> [OrderModel] {
        try req.requireEmployeeOrAdminUser()
        return try await OrderEntry.query(on: req.db)
            .filter(\.$state == .finished)
            .with(\.$items) { $0.with(\.$item) }
            .all()
            .toSharedModels()
    }

    /// Connect to order activity as a restaurant.
    func restaurantActivity(req: Request, ws: WebSocket) async {

        ws.onText { ws, text in
            guard let token = try? await  UserTokenEntry
                .query(on: req.db)
                .filter(\.$value == text)
                .with(\.$user)
                .first(),
                  token.user.access != .client else {
                try? await ws.close()
                return
            }
            self.restaurant = .init(ws: ws, eventLoop: req.eventLoop)
            req.logger.debug("New restaurant joined.")

            try? await OrderEntry.query(on: req.db)
                .filter(\.$state != .finished)
                .with(\.$items) { $0.with(\.$item) }
                .all()
                .toSharedModels()
                .forEach({ order in
                    try? self.restaurant!.send(message: .newOrder(order))
                })

            self.restaurant!.onMessage { message in
                Task {
                    switch message {
                    case .update(let id, let state):
                        if let order = try? await OrderEntry.find(id, on: req.db) {
                            order.state = state
                            try? await order.save(on: req.db)
                            if let client = self.clients[id] {
                                try? await client.send(message: .newState(state))
                            }
                        }
                    }
                }
            }
        }
    }
}
