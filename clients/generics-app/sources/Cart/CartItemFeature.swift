import ComposableArchitecture
import SharedModels

@Reducer
struct CartItemFeature {
    @ObservableState
    struct State: Equatable, Identifiable {
        let menuItem: MenuItem
        var count: Int

        var id: MenuItem.ID {
            menuItem.id
        }
    }

    enum Action {
        case increaseTapped
        case decreaseTapped
    }

    var body: some ReducerOf<Self> {
        EmptyReducer()
    }
}
