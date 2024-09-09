import Foundation
import ComposableArchitecture
import SharedModels
import Factory
import clients_libraries_GenericsCore

@Reducer
struct OrderHistoryFeature {

    enum Action {
        case shown
        case loaded(Result<[OrderModel], Error>)
    }

    @Injected(\.orderRestaurantRepository)
    var repository

    var body: some Reducer<SimpleListState<OrderModel>, Action> {
        Reduce { state, action in
            switch action {
            case .shown:
                state = .loading
                return .run { send in
                    await send(
                        .loaded(
                            Result { try await repository.getHistory() }
                        )
                    )
                }
            case .loaded(.success(let items)):
                state = .loaded(IdentifiedArray(uniqueElements: items))
                return .none
            case .loaded(.failure(let error)):
                state = .error(error.localizedDescription)
                return .none
            }
        }
    }
}
