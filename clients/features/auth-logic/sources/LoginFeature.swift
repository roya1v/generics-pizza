import Foundation
import ComposableArchitecture
import Factory

@Reducer
public struct LoginFeature {
    @ObservableState
    public struct State: Equatable {
        public var isLoading = false
        public var errorMessage: String?
        public var email = ""
        public var password = ""

        public init() { }
    }

    public enum Action: BindableAction {
        case loginTapped
        case loginCompleted(Error?)
        case goToCreateAccountTapped
        case binding(BindingAction<State>)
    }

    @Injected(\.authenticationRepository)
    var repository

    public init() { }

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .loginTapped:
                guard !state.email.isEmpty && !state.password.isEmpty else {
                    state.errorMessage = "Fill out email and password!"
                    return .none
                }
                state.errorMessage = nil
                state.isLoading = true
                return .run { [state] send in
                    do {
                        try await repository.login(email: state.email, password: state.password)
                    } catch {
                        await send(.loginCompleted(error))
                    }
                    await send(.loginCompleted(nil))
                }
            case .loginCompleted(let error):
                state.isLoading = false
                if let error {
                    state.errorMessage = error.localizedDescription
                }
                return .none
            case .binding, .goToCreateAccountTapped:
                return .none
            }
        }
    }
}
