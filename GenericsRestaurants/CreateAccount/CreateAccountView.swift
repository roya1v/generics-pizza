import SwiftUI
import ComposableArchitecture
import AuthLogic

struct CreateAccountView: View {

    @Perception.Bindable var store: StoreOf<CreateAccountFeature>

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
                SecureField("Confirm password",
                            text: $store.confirmPassword)
                if let message = store.errorMessage {
                    Text(message)
                }
                if store.isLoading {
                    ProgressView()
                } else {
                    Button {
                        store.send(.createAccountTapped)
                    } label: {
                        Text("Create account")
                    }
                    Button {
                        store.send(.goToLoginTapped)
                    } label: {
                        Text("Return to login")
                    }
                    .buttonStyle(LinkButtonStyle())
                }
            }
            .padding()
            .frame(minWidth: 300.0, maxWidth: 300.0, minHeight: 300.0)
        }
    }
}
