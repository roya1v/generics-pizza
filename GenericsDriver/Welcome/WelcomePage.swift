import SwiftUI
import GenericsUI
import ComposableArchitecture
import AuthLogic

@Reducer
struct WelcomeFeature {
    @ObservableState
    enum State: Equatable {
        case auth(LoginFeature.State)
        case permissions(PermissionsFeature.State)
    }

    enum Action {
        case auth(LoginFeature.Action)
        case permissions(PermissionsFeature.Action)
    }

    var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .auth(.loginCompleted(nil)):
                state = .permissions(PermissionsFeature.State())
                return .none
            case .auth:
                return .none
            case .permissions:
                return .none
            }
        }
        .ifLet(\.auth, action: \.auth) {
            LoginFeature()
        }
        .ifLet(\.permissions, action: \.permissions) {
            PermissionsFeature()
        }
    }
}

struct WelcomePage: View {

    @Bindable
    var store: StoreOf<WelcomeFeature>

    var body: some View {
        ZStack {
            GradientBackgroundView()
                .ignoresSafeArea()
            VStack {
                switch store.state {
                case .auth:
                    if let store = store.scope(
                        state: \.auth,
                        action: \.auth
                    ) {
                        LoginView(store: store)
                    }
                case .permissions:
                    if let store = store.scope(
                        state: \.permissions,
                        action: \.permissions
                    ) {
                        PermissionsView(store: store)
                    }
                }

            }
            .padding()
            .background(
                RoundedRectangle(
                    cornerRadius: 32.0)
                .fill(.thinMaterial)
            )
            .padding()

        }
    }
}

#Preview {
    WelcomePage(
        store: Store(
            initialState: WelcomeFeature.State.auth(LoginFeature.State())
        ) {
            EmptyReducer()
        })
}
