import XCTest
@testable import clients_generics_restaurants_generics_restaurants
import ComposableArchitecture
import Factory
@testable import clients_libraries_GenericsCore

class MenuFeatureTests: XCTestCase {

    var menuRepositorySpy: MenuRepositorySpy!
    var store: TestStoreOf<MenuFeature>!

    @MainActor
    override func setUp() async throws {
        menuRepositorySpy = MenuRepositorySpy()
        Container.shared.menuRepository.register {
            self.menuRepositorySpy
        }

        store = TestStore(initialState: MenuFeature.State()) {
            MenuFeature()
        }
    }

    @MainActor
    func testLoading() async {
        menuRepositorySpy.fetchMenuShowHiddenReturnValue = []

        await store.send(.shown) {
            $0.menuState = .loading
        }

        await store.receive(\.loaded) {
            $0.menuState = .loaded([])
        }
    }
}
