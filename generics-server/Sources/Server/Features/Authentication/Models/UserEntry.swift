import Fluent
import Vapor
// Why??
// swiftlint:disable:next entry_shared_model_content
import SharedModels

final class UserEntry: Model {
    static let schema = "users"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "email")
    var email: String

    @Field(key: "password_hash")
    var passwordHash: String

    @Enum(key: "access")
    var access: AccessLevel

    init() { }

    init(id: UUID? = nil,
         email: String,
         passwordHash: String,
         access: AccessLevel = .client) {
        self.id = id
        self.email = email
        self.passwordHash = passwordHash
        self.access = access
    }

    func generateToken() throws -> UserTokenEntry {
        try .init(
            value: [UInt8].random(count: 16).base64,
            userID: self.requireID()
        )
    }
}

extension UserEntry: SharedModelRepresentable {
    func toSharedModel() -> UserModel {
        let access: UserModel.AccessLevel = switch access {
        case .client:
                .client
        case .employee:
                .employee
        case .admin:
                .admin
        }
        return UserModel(id: id, email: email, access: access)
    }
}

enum AccessLevel: String, Content {
    case client
    case employee
    case admin
}
