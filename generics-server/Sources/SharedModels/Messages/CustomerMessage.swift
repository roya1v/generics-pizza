import Foundation

public enum CustomerFromServerMessage: Codable {
    case accepted
    case newState(OrderModel.State)
}
