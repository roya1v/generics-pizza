import Fluent
import Vapor
import SharedModels

final class OrderItemEntry: Model {
    static var schema = "order_items"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "menu_item")
    var item: MenuEntry

    @Parent(key: "order")
    var order: OrderEntry

    @Field(key: "count")
    var count: Int

    init() { }

    public init(id: UUID? = nil, item: MenuEntry, order: OrderEntry, count: Int) {
        self.id = id
        self.item = item
        self.order = order
        self.count = count
    }

    public init(id: UUID? = nil, item: UUID, count: Int) {
        self.id = id
        self.count = count
        self.$item.id = item
    }
}

extension OrderItemEntry: SharedModelRepresentable {
    func toSharedModel() -> OrderModel.Item {
        OrderModel.Item(menuItem: item.toSharedModel(), count: count)
    }
}
