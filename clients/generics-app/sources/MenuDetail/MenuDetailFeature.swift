import ComposableArchitecture
import Factory
import Foundation
import GenericsCore
import SharedModels

struct MenuDetailFeature {
    @ObservableState
    struct State: Equatable {
        var image: ImageData?
        let item: MenuItem
    }

    enum Action {
        case addTapped
        case dismissTapped
    }
}
