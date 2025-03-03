import SwiftUI
import GenericsUI
import ComposableArchitecture
import AuthLogic

struct LoginView: View {

    @Bindable
    var store: StoreOf<LoginFeature>

    var body: some View {
        VStack {
            Text("Welcome Driver!")
                .font(.system(size: 32.0, weight: .bold))
            Text("Login in using your credentials to start delivering the most generic pizza!")
                .multilineTextAlignment(.center)
            TextField("Login", text: $store.email)
                .textFieldStyle(GPrimary())
            SecureField("Password", text: $store.password)
                .textFieldStyle(GPrimary())
            Button {
                store.send(.loginTapped)
            } label: {
                if store.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                } else {
                    Text("Login")
                }
            }
            .buttonStyle(GPrimaryButtonStyle())
            Button("Forgot password") {

            }
            .buttonStyle(GLinkButtonStyle())
        }
        .alert("Error!", isPresented: Binding($store.errorMessage)) {
            Button("Ok", role: .cancel) { }
        } message: {
            Text(store.errorMessage ?? "")
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
