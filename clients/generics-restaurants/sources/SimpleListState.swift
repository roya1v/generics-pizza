import ComposableArchitecture

@ObservableState
enum SimpleListState<Item: Identifiable & Equatable>: Equatable {
    case loading
    case loaded(IdentifiedArrayOf<Item>)
    case error(String)

    init() {
        self = .loaded([])
    }
}
