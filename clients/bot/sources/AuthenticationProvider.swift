import SwiftlyHttp
import GenericsCore

class InMemoryAuthenticationProvider: AuthenticationProvider {

    private let token: String

    init(token: String) {
        self.token = token
    }

    func getAuthentication() throws -> SwiftlyHttp.Authentication {
        return .bearer(token: token)
    }
}
