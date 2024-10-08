import Fluent
import Vapor
import SharedModels

typealias CustomerMessenger = Messenger<CustomerFromServerMessage, CustomerFromServerMessage>
typealias RestaurantMessenger = Messenger<RestaurantToServerMessage, RestaurantFromServerMessage>
typealias DriverMessenger = Messenger<DriverToServerMessage, DriverFromServerMessage>

final class OrdersController: RouteCollection {

    var clients = [UUID: CustomerMessenger]()
    var restaurant: RestaurantMessenger?
    var drivers = [DriverMessenger]()

    func boot(routes: RoutesBuilder) throws {
        let order = routes.grouped("order")

        // Customer endpoints
        order.post("check_price", use: checkPrice)
        order.post("check_location", use: checkRestaurantLocation)
        order.post(use: new)
        order.grouped("activity").grouped(":orderId").webSocket(onUpgrade: orderActivity)

        // Restaurant endpoints
        let authenticated = order.grouped(UserTokenEntry.authenticator())
        authenticated.get("current", use: getCurrent)
        authenticated.get("history", use: getHistory)
        authenticated.grouped("activity").webSocket(onUpgrade: restaurantActivity)
    }
}
