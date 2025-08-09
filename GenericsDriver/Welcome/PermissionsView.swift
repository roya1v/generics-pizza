import SwiftUI
import GenericsUI
import ComposableArchitecture
import AuthLogic

struct PermissionsView: View {

    @Bindable
    var store: StoreOf<PermissionsFeature>

    var body: some View {
        VStack {
            Text("Almost there!")
                .font(.system(size: 32.0, weight: .bold))
            Text("In order to start accepting orders you need to grant the app access to your location")
                .multilineTextAlignment(.center)
            Button {
                store.send(.grantTapped)
            } label: {
                Text("Grant permission")
            }
            .buttonStyle(GPrimaryButtonStyle(isWide: true))
            Button("Skip") {

            }
            .buttonStyle(GLinkButtonStyle())
        }
    }
}

#Preview {
    WelcomePage(
        store: Store(
            initialState: WelcomeFeature.State.permissions(PermissionsFeature.State())
        ) {
        EmptyReducer()
    })
}
