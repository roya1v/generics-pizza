import ComposableArchitecture
import Factory
import Foundation
import GenericsCore
import SharedModels
import GenericsHelpers

@Reducer
struct InsightsFeature {

    @ObservableState
    struct State: Equatable {
        var test = [Test]()

        struct Test: Equatable, Identifiable {
            var itemName: String
            var count: Int

            var id: String {
                itemName
            }
        }
    }

    enum Action {
        case shown
        case loaded(Result<[OrderModel], Error>)
    }

    @Injected(\.orderRestaurantRepository)
    var repository

    var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case .shown:
                return .run { send in
                    await send(
                        .loaded(
                            Result { try await repository.getHistory() }
                        )
                    )
                }
            case .loaded(.success(let items)):
                var resut = [String: Int]()
                items.flatMap(\.items).forEach { resut[$0.menuItem.title, default: 0] += $0.count }
                state.test = resut.map { .init(itemName: $0.key, count: $0.value) }
                return .none
            case .loaded(.failure(let error)):
                return .none
            }
        }
    }
}
