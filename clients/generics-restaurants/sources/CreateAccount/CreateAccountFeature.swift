//
//  CreateAccountFeature.swift
//  GenericsRestaurants
//
//  Created by Mike S. on 15/07/2024.
//

import Foundation
import ComposableArchitecture
import Factory

@Reducer
struct CreateAccountFeature {
    @ObservableState
    struct State: Equatable {
        var isLoading = false
        var errorMessage: String?
        var email = ""
        var password = ""
        var confirmPassword = ""
    }

    enum Action: BindableAction {
        case createAccountTapped
        case createAccountCompleted(Error?)
        case goToLoginTapped
        case binding(BindingAction<State>)
    }

    @Injected(\.authenticationRepository)
    var repository

    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .createAccountTapped:
                guard !state.email.isEmpty && !state.password.isEmpty else {
                    state.errorMessage = "Fill out email and password!"
                    return .none
                }
                state.errorMessage = nil
                state.isLoading = true
                return .run { [state] send in
                    do {
                        try await repository.createAccount(email: state.email,
                                                           password: state.password,
                                                           confirmPassword: state.confirmPassword)
                    } catch {
                        await send(.createAccountCompleted(error))
                    }
                    await send(.createAccountCompleted(nil))
                }
            case .createAccountCompleted(let error):
                state.isLoading = false
                if let error {
                    state.errorMessage = error.localizedDescription
                }
                return .none
            case .binding, .goToLoginTapped:
                return .none
            }
        }
    }
}
