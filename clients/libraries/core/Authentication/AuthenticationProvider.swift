import Foundation
import clients_libraries_SwiftlyHttp

public protocol AuthenticationProvider {
    func getAuthentication() throws -> SwiftlyHttp.Authentication
}
