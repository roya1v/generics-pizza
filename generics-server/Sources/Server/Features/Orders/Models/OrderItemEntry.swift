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

    init() { }

    public init(id: UUID? = nil, item: MenuEntry, order: OrderEntry) {
        self.id = id
        self.item = item
        self.order = order
    }

    public init(id: UUID? = nil, item: UUID) {
        self.id = id
        self.$item.id = item
    }
}
