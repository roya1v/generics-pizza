import ComposableArchitecture
import Factory

@Reducer
struct ProfileFeature {
    @ObservableState
    struct State: Equatable {

    }

    enum Action {
        // View
        case signOutTapped

        // Child
        // Internal
        case loggedOut(Result<Void, Error>)
    }

    @Injected(\.authenticationRepository)
    private var repository

    var body: some ReducerOf<Self> {
        Reduce<State, Action> { _, action in
            switch action {
            case .signOutTapped:
                return .run { send in
                    await send(.loggedOut(Result { try await repository.signOut() }))
                }
            case .loggedOut:
                return .none
            }
        }
    }
}
