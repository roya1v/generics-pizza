import Fluent
import Vapor
import SharedModels

final class MenuEntry: Model {
    static var schema = "menu"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "title")
    var title: String

    @Field(key: "description")
    var description: String

    @Field(key: "price")
    var price: Int

    @Field(key: "is_hidden")
    var isHidden: Bool

    @OptionalParent(key: "category_id")
    var category: CategoryEntry?

    init() { }

    init(id: UUID? = nil,
         title: String,
         description: String,
         price: Int,
         isHidden: Bool = false,
         category: CategoryEntry?) {
        self.id = id
        self.title = title
        self.description = description
        self.price = price
        self.isHidden = isHidden
        self.category = category
    }
}

extension MenuEntry: SharedModelRepresentable {
    func toSharedModel() -> MenuItem {
        MenuItem(id: id,
                 title: title,
                 description: description,
                 price: price,
                 isHidden: isHidden,
                 category: category?.toSharedModel())
    }
}
