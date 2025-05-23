import SwiftUI
import ComposableArchitecture
import AuthLogic

struct LoginView: View {

    @Bindable var store: StoreOf<LoginFeature>

    var body: some View {
        WithPerceptionTracking {
            VStack {
                Image("generics-header")
                    .resizable()
                    .scaledToFit()
                TextField("Email",
                          text: $store.email)
                SecureField("Password",
                            text: $store.password)
                if let message = store.errorMessage {
                    Text(message)
                }
                if store.isLoading {
                    ProgressView()
                } else {
                    Button {
                        store.send(.loginTapped)
                    } label: {
                        Text("Login")
                    }
                    Button {
                        store.send(.goToCreateAccountTapped)
                    } label: {
                        Text("Create account")
                    }
                    .buttonStyle(LinkButtonStyle())
                }
            }
            .padding()
            .frame(minWidth: 300.0, maxWidth: 300.0, minHeight: 300.0)
        }
    }
}
