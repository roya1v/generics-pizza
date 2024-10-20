import Fluent
import Vapor
import SharedModels

final class OrderEntry: Model {
    static var schema = "orders"

    @ID(key: .id)
    var id: UUID?

    @Timestamp(key: "created_at", on: .create, format: .unix)
    var createdAt: Date?

    @Enum(key: "state")
    var state: OrderModel.State

    @Children(for: \.$order)
    var items: [OrderItemEntry]

    @Field(key: "address")
    var address: String?

    init() { }

    public init(id: UUID? = nil, state: OrderModel.State, address: String?) {
        self.id = id
        self.state = state
        self.address = address
    }
}

extension OrderEntry: Hashable {
    static func == (lhs: OrderEntry, rhs: OrderEntry) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

extension OrderEntry: SharedModelRepresentable {
    func toSharedModel() -> OrderModel {
        OrderModel(
            id: id,
            createdAt: createdAt,
            items: items.map { $0.toSharedModel() },
            state: state,
            destination: address != nil
            ? .delivery(OrderModel.Destination.Address(street: address!, floor: nil, comment: ""))
            : .pickUp
        )
    }
}
