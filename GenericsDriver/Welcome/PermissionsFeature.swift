import ComposableArchitecture
import AuthLogic
import GenericsCore
import Factory
import CoreLocation

@Reducer
struct PermissionsFeature {
    @ObservableState
    struct State: Equatable {

    }

    enum Action {
        // View
        case appeared
        case grantTapped
        // Child
        // Internal
        case authorizationChanged(CLAuthorizationStatus)
    }

    @Injected(\.locationManager)
    private var locationManager

    var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .appeared:
                return .none
            case .grantTapped:
                locationManager.requestWhenInUseAuthorization()
                return .publisher {
                    locationManager
                        .authorizationStatusPublisher
                        .map { .authorizationChanged($0) }
                }
            case .authorizationChanged(_):
                return .none
            }
        }
    }
}
