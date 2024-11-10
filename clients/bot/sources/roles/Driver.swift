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

        let driverRepository = buildDriverRepository(
            url: baseUrl,
            authenticationProvider: InMemoryAuthenticationProvider(
                token: token
            )
        )

        let cancellable = driverRepository
            .getFeed()
            .receive(on: DispatchQueue.main)
            .sink { _ in

            } receiveValue: { message in
                switch message {
                case .offerOrder(let model):
                    Task {
                        try? await driverRepository.send(.acceptOrder(model.id))
                        print("Accepted order with id: \(model.id)")
                        try await Task.sleep(for: .seconds(2))
                        try await driverRepository.send(.delivered(model.id))
                        print("Order delivered")
                    }
                }
            }

        try await Task.sleep(for: .seconds(9_999_999))
    }

}
