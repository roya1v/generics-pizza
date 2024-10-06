import ComposableArchitecture
import Factory
import Foundation
import GenericsCore
import SharedModels
import GenericsHelpers

@Reducer
struct UsersFeature {

    enum Action {
        case shown
        case loaded(Result<[UserModel]?, Error>)
        case deleteTapped(user: UserModel)
        case newAccessSelected(forUser: UserModel, newAccess: UserModel.AccessLevel)
    }

    @Injected(\.usersRepository)
    var repository

    @Injected(\.authenticationRepository)
    var authRepository

    var body: some Reducer<SimpleListState<UserModel>, Action> {
        Reduce { state, action in
            switch action {
            case .shown:
                state = .loading
                return .run { send in
                    await send(
                        .loaded(
                            Result { try await repository.getAll() }
                        )
                    )
                }
            case .loaded(.success(let newUsers)):
                if let newUsers {
                    state = .loaded(IdentifiedArray(uniqueElements: newUsers))
                }
                return .none
            case .loaded(.failure(let error)):
                state = .error(error.localizedDescription)
                return .none
            case .deleteTapped(let user):
                state = .loading
                return .run { send in
                    try await repository.delete(user: user)
                    await send(.shown)
                }
            case .newAccessSelected(let user, let newAccess):
                state = .loading
                return .run { send in
                    try await repository.updateAccessLevel(for: user, to: newAccess)
                    await send(.loaded(.success(nil)))
                }
            }
        }
    }
}
