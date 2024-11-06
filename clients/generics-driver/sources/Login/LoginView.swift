import SwiftUI
import GenericsUI
import ComposableArchitecture

struct LoginView: View {

    @Perception.Bindable
    var store: StoreOf<LoginFeature>

    var body: some View {
        WithPerceptionTracking {
            VStack {
                Text("Welcome Driver!")
                    .font(.largeTitle)
                TextField("Login", text: .constant(""))
                    .textFieldStyle(.roundedBorder)
                SecureField("Password", text: .constant(""))
                    .textFieldStyle(.roundedBorder)
                Spacer()
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
            }
            .padding()
        }
    }
}
