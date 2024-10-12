import Foundation

public struct MenuItem: Codable, Identifiable, Equatable {

    public init(id: UUID?,
                title: String,
                description: String,
                price: Int,
                isHidden: Bool,
                category: Category?) {
        self.id = id
        self.title = title
        self.description = description
        self.price = price
        self.isHidden = isHidden
        self.category = category
    }

    public let id: UUID?
    public let title: String
    public let description: String
    public let price: Int
    public let isHidden: Bool
    public let category: Category?

    public struct Category: Codable, Identifiable, Equatable, Hashable {

        public init(id: UUID? = nil, name: String) {
            self.id = id
            self.name = name
        }

        public let id: UUID?
        public let name: String
    }
}
