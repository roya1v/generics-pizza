//
//  LoginViewModel.swift
//  GenericsRestaurants
//
//  Created by Mike Shevelinsky on 15/02/2023.
//

import Foundation
import Factory

@MainActor
final class LoginViewModel: ObservableObject {

    @Injected(Container.authenticationRepository) private var repository

    @Published var isLoading = false

    func login(email: String, password: String) {
        isLoading = true
        Task {
            try! await repository.login(email: email, password: password)
            await MainActor.run {
                isLoading = false
            }
        }
    }
}
