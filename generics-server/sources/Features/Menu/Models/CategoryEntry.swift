import Fluent
import Vapor
import SharedModels

final class CategoryEntry: Model {
    static var schema = "categories"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Children(for: \.$category)
    var menuItems: [MenuEntry]

    init() { }

    init(id: UUID? = nil,
         name: String) {
        self.id = id
        self.name = name
    }
}

extension CategoryEntry: SharedModelRepresentable {
    func toSharedModel() -> MenuItem.Category {
        MenuItem.Category(id: id, name: name)
    }
}
