import AppKit
import ComposableArchitecture
import Factory
import Foundation
import GenericsCore
import SharedModels

@Reducer
struct MenuItemFormFeature {
    @ObservableState
    struct State: Equatable {
        var id: MenuItem.ID
        var title = ""
        var description = ""
        var price = 0.0
        var image: ImageData?
        var hasNewImage = false
        var isLoading = false
        var errorMessage: String?
        var isHidden = true
        var categories = IdentifiedArrayOf<MenuItem.Category>()
        var category: MenuItem.Category?
        @Presents var newCategory: NewCategoryFeature.State?

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
            isLoading: Bool = false,
            errorMessage: String? = nil,
            categories: IdentifiedArrayOf<MenuItem.Category> = IdentifiedArrayOf<MenuItem.Category>()
        ) {
            self.id = id
            self.title = title
            self.description = description
            self.price = price
            self.isLoading = isLoading
            self.errorMessage = errorMessage
            self.categories = categories
        }
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case appeared
        case submitTapped
        case cancelTapped
        case imageSelected(ImageData)
        case existingImageLoaded(Result<ImageData, Error>)
        case existingCategoriesLoaded(Result<[MenuItem.Category], Error>)
        case createdNewItem(Result<MenuItem, Error>)
        case newCategoryTapped
        case newCategory(PresentationAction<NewCategoryFeature.Action>)
    }

    @Injected(\.menuRepository)
    private var repository

    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce<State, Action> { state, action in
            switch action {
            case .appeared:
                return .merge(
                    loadExistingItem(state: state),
                    .run { send in
                        await send(
                            .existingCategoriesLoaded(
                                Result { try await repository.fetchCategories() }
                            )
                        )
                    }
                )
            case .existingImageLoaded(.success(let image)):
                state.image = image
                return .none
            case .existingImageLoaded(.failure):
                return .none
            case .existingCategoriesLoaded(.success(let categories)):
                state.categories = IdentifiedArray(uniqueElements: categories)
                return .none
            case .existingCategoriesLoaded(.failure):
                return .none
            case .imageSelected(let image):
                state.image = image
                state.hasNewImage = true
                return .none
            case .newCategoryTapped:
                state.newCategory = NewCategoryFeature.State()
                return .none
            case .newCategory(.presented(.cancelTapped)):
                state.newCategory = nil
                return .none
            case .submitTapped:
                let item = MenuItem(
                    id: state.id,
                    title: state.title,
                    description: state.description,
                    price: Int(state.price * 100),
                    isHidden: state.isHidden,
                    category: nil)
                let imageData = state.image?.tiffRepresentation
                state.isLoading = true
                return .run { [item, imageData, hasNewImage = state.hasNewImage] send in
                    await send(
                        .createdNewItem(
                            Result {
                                let menuItem: MenuItem
                                if item.id != nil {
                                    menuItem = try await repository.update(item: item)
                                } else {
                                    menuItem = try await repository.create(item: item)
                                }
                                if let imageData,
                                    hasNewImage,
                                    let bitmapData = NSBitmapImageRep(data: imageData),
                                    let pngData = bitmapData.representation(
                                        using: .png, properties: [:]) {
                                    try await repository.setImage(
                                        withPngData: pngData, for: menuItem)
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
            case .newCategory:
                return .none
            }
        }
        .ifLet(\.$newCategory, action: \.newCategory) {
            NewCategoryFeature()
        }
    }

    private func loadExistingItem(state: State) -> Effect<Action> {
        if let id = state.id {
            return .run { [id] send in
                await send(
                    .existingImageLoaded(
                        Result { try await repository.getImage(forItemId: id) }
                    )
                )
            }
        } else {
            return .none
        }
    }
}
