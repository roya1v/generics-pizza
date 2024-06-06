//
//  LoginFeature.swift
//  GenericsRestaurants
//
//  Created by Mike S. on 06/06/2024.
//

import Foundation
import ComposableArchitecture
import Factory

@Reducer
struct LoginFeature {
    @ObservableState
    struct State: Equatable {
        var isLoading = false
        var errorMessage: String?
    }

    enum Action {
        case loginTapped(login: String, password: String)
        case loginCompleted(Error?)
    }

    @Injected(\.authenticationRepository)
    var repository

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .loginTapped(let login, let password):
                guard !login.isEmpty && !password.isEmpty else {
                    state.errorMessage = "Fill out email and password!"
                    return .none
                }
                state.errorMessage = nil
                state.isLoading = true
                return .run { send in
                    do {
                        try await repository.login(email: login, password: password)
                    } catch {
                        await send(.loginCompleted(error))
                    }
                    await send(.loginCompleted(nil))
                }
            case .loginCompleted(let error):
                state.isLoading = false
                if let error {
                    state.errorMessage = error.localizedDescription
                }
                return .none
            }
        }
    }
}
