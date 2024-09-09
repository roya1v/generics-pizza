import Foundation

public enum DriverToServerMessage: Codable {
    case locationUpdated(lon: Double, lat: Double)
    case acceptOrder
    case declineOrder
}

public enum DriverFromServerMessage: Codable {
    case offerOrder(fromAddress: AddressModel, toAddress: AddressModel, reward: Int)
}
