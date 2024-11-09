import SwiftUI
import GenericsUI
import ComposableArchitecture

struct LoginView: View {

    @Perception.Bindable
    var store: StoreOf<LoginFeature>

    var body: some View {
        WithPerceptionTracking {
            ZStack {
                GradientBackgroundView()
                    .ignoresSafeArea()
                VStack {
                    Text("Welcome Driver!")
                        .font(.system(size: 32.0, weight: .bold))

                    VStack {
                        TextField("Login", text: $store.email)
                            .textFieldStyle(GPrimary())
                        SecureField("Password", text: $store.password)
                            .textFieldStyle(GPrimary())
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
                    .background(.thinMaterial)
                }
            }
        }
    }
}
