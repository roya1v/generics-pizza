import ArgumentParser
import Foundation
import GenericsCore
import SharedModels

struct Driver: AsyncParsableCommand {

    static let configuration = CommandConfiguration(
        abstract: "A bot that behaives as a driver.")

    func run() async throws {
        print("Login:")
        let login = readLine(strippingNewline: true)!
        print("Password:")
        let password = readLine(strippingNewline: true)!

        print("Trying to log in...")
        let authService = AuthenticationService(baseURL: baseUrl)
        let token: String
        do {
            token =
                try await authService
                .login(email: login, password: password)
        } catch {
            print("Error while logging in: \(error)")
            return
        }

        let orderRepository = buildOrderRestaurantRepository(
            url: baseUrl,
            authenticationProvider: InMemoryAuthenticationProvider(
                token: token
            )
        )

        try await Task.sleep(for: .seconds(9_999_999))
    }

}
