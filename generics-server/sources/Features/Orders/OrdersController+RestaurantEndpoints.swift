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
            let restaurant = RestaurantMessenger(ws: ws, eventLoop: req.eventLoop)
            req.logger.debug("New restaurant joined.")

            try? await OrderEntry.query(on: req.db)
                .filter(\.$state != .finished)
                .with(\.$items) { $0.with(\.$item) }
                .all()
                .toSharedModels()
                .forEach({ order in
                    try? restaurant.send(message: .newOrder(order))
                })

            req.dispatcher.restaurantJoined(restaurant)
        }
    }

    /// Connect to order activity as a driver.
    func driverActivity(req: Request, ws: WebSocket) async {

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
            let driver = DriverMessenger(ws: ws, eventLoop: req.eventLoop)
            req.logger.debug("New driver joined.")

            req.dispatcher.driverJoined(driver)
        }
    }
}
