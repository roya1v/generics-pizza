import Foundation

public enum RestaurantToServerMessage: Codable {
    case update(orderId: UUID, state: OrderModel.State)
}

public enum RestaurantFromServerMessage: Codable {
    case newOrder(OrderModel)
}
