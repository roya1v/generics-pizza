import Foundation
import ComposableArchitecture
import Factory
import SharedModels
import clients_libraries_GenericsCore

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
