import Vapor
import Fluent

extension UserEntry: ModelAuthenticatable {
    static let usernameKey = \UserEntry.$email
    static let passwordHashKey = \UserEntry.$passwordHash

    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.passwordHash)
    }
}
