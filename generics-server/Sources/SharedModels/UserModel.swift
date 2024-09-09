import Foundation

public struct UserModel: Codable, Equatable, Identifiable {
    public enum AccessLevel: String, Codable {
        case client
        case employee
        case admin
    }

    public init(id: UUID? = nil, email: String, access: AccessLevel) {
        self.id = id
        self.email = email
        self.access = access
    }

    public let id: UUID?
    public let email: String
    public let access: AccessLevel

    public struct Create: Codable, Equatable {
        public init(email: String, password: String, confirmPassword: String) {
            self.email = email
            self.password = password
            self.confirmPassword = confirmPassword
        }

        public let email: String
        public let  password: String
        public let confirmPassword: String
    }
}
