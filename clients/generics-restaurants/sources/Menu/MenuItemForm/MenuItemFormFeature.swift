import Foundation
import ComposableArchitecture
import SharedModels
import Factory

@Reducer
struct MenuItemFormFeature {
    @ObservableState
    struct State: Equatable {
        var id: MenuItem.ID
        var title = ""
        var description = ""
        var price = 0.0
        var imageUrl: URL?
        var isLoading = false
        var errorMessage: String?
        var isHidden = true

        init(menuItem: MenuItem) {
            id = menuItem.id
            title = menuItem.title
            description = menuItem.description
            isHidden = menuItem.isHidden
            price = Double(menuItem.price) / 100.0
        }

        init(
            id: MenuItem.ID = nil,
            title: String = "",
            description: String = "",
            price: Double = 0.0,
            imageUrl: URL? = nil,
            isLoading: Bool = false,
            errorMessage: String? = nil) {
                self.id = id
                self.title = title
                self.description = description
                self.price = price
                self.imageUrl = imageUrl
                self.isLoading = isLoading
                self.errorMessage = errorMessage
            }
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case submitTapped
        case cancelTapped
        case imageSelected(URL)
        case createdNewItem(Result<MenuItem, Error>)
    }

    @Injected(\.menuRepository)
    var repository

    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .imageSelected(let url):
                state.imageUrl = url
                return .none
            case .submitTapped:
                let item = MenuItem(id: state.id,
                                    title: state.title,
                                    description: state.description,
                                    price: Int(state.price * 100),
                                    isHidden: state.isHidden)
                let imageUrl = state.imageUrl
                state.isLoading = true
                return .run { [item, imageUrl] send in
                    await send(
                        .createdNewItem(
                            Result {
                                let menuItem: MenuItem
                                if item.id != nil {
                                    menuItem = try await repository.update(item: item)
                                } else {
                                    menuItem = try await repository.create(item: item)
                                }
                                if let imageUrl {
                                    try await repository.setImage(from: imageUrl, for: menuItem)
                                }

                                return menuItem
                            }
                        )
                    )
                }
            case .createdNewItem(.failure(let error)):
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                return .none
            case .createdNewItem:
                return .none
            case .cancelTapped:
                return .none
            case .binding:
                return .none
            }
        }
    }
}
