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
        var email = ""
        var password = ""
    }

    enum Action {
        case loginTapped
        case loginCompleted(Error?)
        case sendEmail(String)
        case sendPassword(String)
    }

    @Injected(\.authenticationRepository)
    var repository

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .loginTapped:
                guard !state.email.isEmpty && !state.password.isEmpty else {
                    state.errorMessage = "Fill out email and password!"
                    return .none
                }
                state.errorMessage = nil
                state.isLoading = true
                return .run { [state] send in
                    do {
                        try await repository.login(email: state.email, password: state.password)
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
            case .sendEmail(let email):
                state.email = email
                return .none
            case .sendPassword(let password):
                state.password = password
                return .none
            }
        }
    }
}
