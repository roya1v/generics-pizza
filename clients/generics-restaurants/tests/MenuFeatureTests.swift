import XCTest
@testable import clients_generics_restaurants_generics_restaurants
import ComposableArchitecture
import Factory
@testable import clients_libraries_GenericsCore
import SharedModels

class MenuFeatureTests: XCTestCase {

    var menuRepositorySpy: MenuRepositorySpy!
    var store: TestStoreOf<MenuFeature>!

    override func setUp() async throws {
        menuRepositorySpy = MenuRepositorySpy()
        Container.shared.menuRepository.register {
            self.menuRepositorySpy
        }

        store = await TestStore(initialState: MenuFeature.State()) {
            MenuFeature()
        }
    }

    func testLoadingWithSuccess() async {
        menuRepositorySpy.fetchMenuShowHiddenReturnValue = []

        await store.send(.shown) {
            $0.menuState = .loading
        }

        await store.receive(\.loaded) {
            $0.menuState = .loaded([])
        }
    }

    func testLoadingWithFailure() async {
        menuRepositorySpy.fetchMenuShowHiddenThrowableError = MockError()

        await store.send(.shown) {
            $0.menuState = .loading
        }

        await store.receive(\.loaded) {
            $0.menuState = .error("mock-error")
        }
    }

    func testNewItem() async {
        await store.send(.newItemButtonTapped) {
            $0.itemForm = MenuItemFormFeature.State(
                id: nil,
                title: "",
                description: "",
                price: 0.0,
                isLoading: false,
                errorMessage: nil
            )
        }
    }

    @MainActor
    func testEditItem() async {
        menuRepositorySpy.getImageForItemIdReturnValue = NSImage()
        store.exhaustivity = .off(showSkippedAssertions: true)
        let mockItem = MenuItem(id: UUID(), title: "mock", description: "mock", price: 123, isHidden: false)

        await store.send(.loaded(.success([mockItem]))) {
            $0.menuState = .loaded([MenuItemFeature.State(item: mockItem)])
        }

        await store.send(.item(.element(id: mockItem.id, action: .editTapped))) {
            $0.itemForm = MenuItemFormFeature.State(menuItem: mockItem)
        }
    }
}
