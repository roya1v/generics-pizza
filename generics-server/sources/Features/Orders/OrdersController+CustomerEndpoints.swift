import Fluent
import Vapor
import SharedModels

extension OrdersController {

    /// Check price for an order.
    func checkPrice(req: Request) async throws -> [SubtotalModel] {
        let sum = try req.content.decode(OrderModel.self)
            .items.reduce(0, {$0 + $1.menuItem.price * $1.count})
        return [
            .init(name: "Subtotal", value: sum),
            .init(name: "Total", value: sum, isSecondary: false)
        ]
    }

    /// Create a new order.
    func new(req: Request) async throws -> OrderModel {
        let orderModel = try req.content.decode(OrderModel.self)

//        switch orderModel.destination {
//        case .delivery:
//            throw Abort(.notAcceptable, reason: "Delivered orders not supported")
//        case .pickUp:
//            addressId = nil
//        }

        let order = OrderEntry(state: .new)
        try await order.save(on: req.db)

        let items = orderModel.items.map { OrderItemEntry(item: $0.menuItem.id!, count: $0.count) }
        try await order.$items.create(items, on: req.db)

        if case let .delivery(address) = orderModel.destination {
            let addressEntry = OrderAddressEntry(
                latitude: address.coordinates.latitude,
                longitude: address.coordinates.longitude,
                street: address.street,
                floor: address.floor,
                appartment: address.appartment,
                comment: address.comment,
                orderId: order.id!
            )
            try await addressEntry.create(on: req.db)
        }

        try await order.$items.load(on: req.db)
        try await order.$address.load(on: req.db)
        for item in order.items {
            try await item.$item.load(on: req.db)
        }

        try req.dispatcher.placeOrder(order.toSharedModel())

        return order.toSharedModel()
    }

    /// Connect to order activity as a customer.
    func orderActivity(req: Request, ws: WebSocket) async {
        try? req.dispatcher.customerJoined(
            .init(ws: ws, eventLoop: req.eventLoop),
            forId: req.parameters.get("orderId")
        )
    }
}
