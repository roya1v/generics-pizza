import Foundation

public enum DriverToServerMessage: Codable {
    case acceptOrder(OrderModel.ID)
    case delivered(OrderModel.ID)
}

public enum DriverFromServerMessage: Codable {
    case offerOrder(OrderModel)
}
