import Foundation
import ComposableArchitecture
import Factory

@Reducer
public struct CreateAccountFeature {
    @ObservableState
    public struct State: Equatable {
        public var isLoading = false
        public var errorMessage: String?
        public var email = ""
        public var password = ""
        public var confirmPassword = ""

        public init() { }
    }

    public enum Action: BindableAction {
        case createAccountTapped
        case createAccountCompleted(Error?)
        case goToLoginTapped
        case binding(BindingAction<State>)
    }

    @Injected(\.authenticationRepository)
    private var repository

    public init() { }

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .createAccountTapped:
                guard !state.email.isEmpty && !state.password.isEmpty else {
                    state.errorMessage = "Fill out email and password!"
                    return .none
                }
                state.errorMessage = nil
                state.isLoading = true
                return .run { [state] send in
                    do {
                        try await repository.createAccount(email: state.email,
                                                           password: state.password,
                                                           confirmPassword: state.confirmPassword)
                    } catch {
                        await send(.createAccountCompleted(error))
                    }
                    await send(.createAccountCompleted(nil))
                }
            case .createAccountCompleted(let error):
                state.isLoading = false
                if let error {
                    state.errorMessage = error.localizedDescription
                }
                return .none
            case .binding, .goToLoginTapped:
                return .none
            }
        }
    }
}
