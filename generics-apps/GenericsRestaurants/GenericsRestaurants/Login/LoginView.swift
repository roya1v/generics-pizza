//
//  LoginView.swift
//  GenericsRestaurants
//
//  Created by Mike S. on 15/02/2023.
//

import SwiftUI

struct LoginView: View {

    @StateObject var model = LoginViewModel()
    @State var email = ""
    @State var password = ""

    var body: some View {
        VStack {
            Image("generics-header")
                .resizable()
                .scaledToFit()
            TextField("Email", text: $model.email)
            SecureField("Password", text: $model.password)
            if model.state == .error {
                Text("Something went wrong!")
            }
            if model.state == .loading {
                ProgressView()
            } else {
                Button {
                    model.login()
                } label: {
                    Text("Login")
                }
            }
        }
        .padding()
        .frame(minWidth: 300.0, maxWidth: 300.0, minHeight: 300.0)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
