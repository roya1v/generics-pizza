import Foundation
import SwiftlyHttp

public protocol AuthenticationProvider {
    func getAuthentication() throws -> SwiftlyHttp.Authentication
}
