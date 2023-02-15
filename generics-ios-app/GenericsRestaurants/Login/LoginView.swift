//
//  LoginView.swift
//  GenericsRestaurants
//
//  Created by Mike Shevelinsky on 15/02/2023.
//

import SwiftUI

struct LoginView: View {

    @State var email = ""
    @State var password = ""
    @ObservedObject var model = LoginViewModel()

    var body: some View {
        VStack {
            Image("generics-header")
                .resizable()
                .scaledToFit()
            TextField("Email", text: $email)
            TextField("Password", text: $password)
            if model.isLoading {
                ProgressView()
            } else {
                Button {
                    model.login(email: email, password: password)
                } label: {
                    Text("Login")
                }
            }
        }
        .padding()
        .frame(minWidth: 600.0, minHeight: 300.0)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
