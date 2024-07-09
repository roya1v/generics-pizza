//
//  LoginView.swift
//  GenericsRestaurants
//
//  Created by Mike S. on 15/02/2023.
//

import SwiftUI
import ComposableArchitecture

struct LoginView: View {

    @Perception.Bindable var store: StoreOf<LoginFeature>

    var body: some View {
        WithPerceptionTracking {
            VStack {
                Image("generics-header")
                    .resizable()
                    .scaledToFit()
                TextField("Email",
                          text: $store.email.sending(\.sendEmail))
                SecureField("Password",
                            text: $store.password.sending(\.sendPassword))
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
                }
            }
            .padding()
            .frame(minWidth: 300.0, maxWidth: 300.0, minHeight: 300.0)
        }
    }
}

#Preview {
    LoginView(store: Store(initialState: LoginFeature.State()){
        LoginFeature()
    })
}
