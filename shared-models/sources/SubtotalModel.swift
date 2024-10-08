import Foundation

public struct SubtotalModel: Codable, Equatable {
    public init(name: String, value: Int, isSecondary: Bool = true) {
        self.name = name
        self.value = value
        self.isSecondary = isSecondary
    }

    public let name: String
    public let value: Int
    public let isSecondary: Bool
}
