import ComposableArchitecture
import GenericsCore
import SharedModels

@Reducer
struct CartItemFeature {
    @ObservableState
    struct State: Equatable, Identifiable {
        let menuItem: MenuItem
        var count: Int
        var image: ImageData?

        var id: MenuItem.ID {
            menuItem.id
        }
    }

    enum Action {
        case increaseTapped
        case decreaseTapped
        case imageLoaded(Result<ImageData, Error>)
    }

    var body: some ReducerOf<Self> {
        EmptyReducer()
    }
}
