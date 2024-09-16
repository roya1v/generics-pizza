import ComposableArchitecture

@ObservableState
public enum SimpleListState<Item: Identifiable & Equatable>: Equatable {
    case loading
    case loaded(IdentifiedArrayOf<Item>)
    case error(String)

    public init() {
        self = .loaded([])
    }

    public var items: IdentifiedArrayOf<Item> {
        get {
            if case let .loaded(items) = self {
                return items
            } else {
                return []
            }
        }
        set {
            self = .loaded(newValue)
        }
    }
}
