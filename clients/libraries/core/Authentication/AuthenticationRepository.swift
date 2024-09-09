import Foundation
import Combine
import clients_libraries_SwiftlyHttp
import SharedModels
import Spyable

public func buildAuthenticationRepository(url: String) -> AuthenticationRepository {
    AuthenticationRepositoryImpl(baseURL: url)
}

public enum AuthenticationState {
    case unknown
    case loggedIn
    case loggedOut
}

@Spyable
public protocol AuthenticationRepository: AuthenticationProvider {
    var statePublisher: AnyPublisher<AuthenticationState, Never> { get }
    var state: AuthenticationState { get }
    func login(email: String, password: String) async throws
    func createAccount(email: String, password: String, confirmPassword: String) async throws
    func reload()
    func signOut() async throws
    func getMe() async throws -> UserModel
    // https://github.com/Matejkob/swift-spyable/issues/47
    func getAuthentication() throws -> SwiftlyHttp.Authentication
}

final class AuthenticationRepositoryImpl: AuthenticationRepository {

    private let stateSubject = PassthroughSubject<AuthenticationState, Never>()

    private let settingsService = LocalSettingsServiceImpl()
    private let authenticationService: AuthenticationService

    init(baseURL: String) {
        self.authenticationService = AuthenticationService(baseURL: baseURL)
    }

    // MARK: - AuthenticationRepository

    var statePublisher: AnyPublisher<AuthenticationState, Never> {
        if state == .unknown {
            Task {
                reload()
            }
        }
        return stateSubject.eraseToAnyPublisher()
    }

    private(set) var state = AuthenticationState.unknown {
        didSet {
            stateSubject.send(state)
        }
    }

    func login(email: String, password: String) async throws {
        let token = try await authenticationService.login(email: email, password: password)

        settingsService.setAuthToken(token)

        state = .loggedIn
    }

    func createAccount(email: String, password: String, confirmPassword: String) async throws {
        _ = try await authenticationService.createAccount(email: email,
                                                          password: password,
                                                          confirmPassword: confirmPassword)

        try await login(email: email, password: password)
    }

    func reload() {
        if settingsService.getAuthToken() != nil {
            Task {
                if (try? await getMe()) != nil {
                    state = .loggedIn
                } else {
                    settingsService.resetAuthToken()
                    state = .loggedOut
                }
            }

        } else {
            state = .loggedOut
        }
    }

    func signOut() async throws {
        guard let token = settingsService.getAuthToken() else {
            fatalError()
        }
        try await authenticationService.signOut(token)
        settingsService.resetAuthToken()
        state = .loggedOut
    }

    func getMe() async throws -> UserModel {
        guard let token = settingsService.getAuthToken() else {
            fatalError()
        }
        return try await authenticationService.getMe(token)
    }

    func getAuthentication() throws -> SwiftlyHttp.Authentication {
        guard let token = settingsService.getAuthToken() else {
            fatalError()
        }

        return .bearer(token: token)
    }
}
