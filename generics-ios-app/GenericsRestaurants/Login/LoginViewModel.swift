//
//  LoginViewModel.swift
//  GenericsRestaurants
//
//  Created by Mike S. on 15/02/2023.
//

import Foundation
import Factory
import GenericsUI

@MainActor
final class LoginViewModel: ObservableObject {

    @Published private(set) var state: ViewState = .ready
    @Published var email: String = ""
    @Published var password: String = ""

    @Injected(\.authenticationRepository)
    private var repository

    func login() {
        state = .loading
        guard !email.isEmpty, !password.isEmpty else {
            state = .error
            return
        }
        Task {
            do {
                try await repository.login(email: email, password: password)
                state = .ready
            } catch {
                state = .error
            }
        }
    }
}
