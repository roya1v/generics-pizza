import Foundation
import UIKit
import ComposableArchitecture
import SharedModels

@Reducer
struct MenuListFeature {
    @ObservableState
    struct State: Equatable {
        var items = IdentifiedArrayOf<MenuRowFeature.State>()

        var scrolledTo: MenuRowFeature.State?
    }

    enum Action {
        case updatedScroll

        // Internal
        case loaded(Result<[MenuItem], Error>)

        // Child
        case row(IdentifiedActionOf<MenuRowFeature>)
    }
}
