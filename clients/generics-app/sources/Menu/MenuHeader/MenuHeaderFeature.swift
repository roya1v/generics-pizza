import ComposableArchitecture
import SharedModels

@Reducer
struct MenuHeaderFeature {

    @ObservableState
    struct State: Equatable {
        var categories = IdentifiedArrayOf<MenuItem.Category>()
        var selected: MenuItem.Category?
    }

    enum Action {
        // View
        case categorySelected(MenuItem.Category.ID)

        // Internal
        case loaded(Result<[MenuItem.Category], Error>)
    }
}
