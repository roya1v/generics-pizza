import ComposableArchitecture
import Factory
import GenericsCore
import SharedModels

@Reducer
struct NewCategoryFeature {
    @ObservableState
    struct State: Equatable {
        var name = ""
    }

    enum Action {
        case nameUpdated(String)
        case createTapped
        case cancelTapped
        case newCategoryCreated(Result<MenuItem.Category, Error>)
    }

    @Injected(\.menuRepository)
    private var repository

    var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .nameUpdated(let name):
                state.name = name
                return .none
            case .createTapped:
                return .run { [name = state.name] send in
                    await send(
                        .newCategoryCreated(
                            Result { try await repository.create(category: MenuItem.Category(name: name) )}
                        )
                    )
                }
            case .cancelTapped:
                return .none
            case .newCategoryCreated(.failure(let error)):
                // TODO: Add error handling
                return .none
            case .newCategoryCreated:
                return .none
            }
        }
    }
}
