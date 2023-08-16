//
//  LoginViewModel.swift
//  GenericsDriver
//
//  Created by Mike S. on 16/08/2023.
//

import Foundation
import Factory
import GenericsUI

@MainActor
final class LoginViewModel: ObservableObject {

    @Published private(set) var state: ViewState = .ready

    @Injected(Container.authenticationRepository)
    private var repository

    func login(email: String, password: String) {
        state = .loading
        Task {
            do {
                try await repository.login(email: email, password: password)
                await MainActor.run {
                    state = .ready
                }
            } catch {
                state = .ready
            }
        }
    }
}
