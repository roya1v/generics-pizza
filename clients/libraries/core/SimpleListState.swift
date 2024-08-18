import ComposableArchitecture

@ObservableState
public enum SimpleListState<Item: Identifiable & Equatable>: Equatable {
    case loading
    case loaded(IdentifiedArrayOf<Item>)
    case error(String)

    public init() {
        self = .loaded([])
    }
}
