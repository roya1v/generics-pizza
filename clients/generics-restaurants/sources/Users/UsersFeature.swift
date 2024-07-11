//
//  UsersFeature.swift
//  GenericsRestaurants
//
//  Created by Mike S. on 19/03/2024.
//

import Foundation
import ComposableArchitecture
import SharedModels
import Factory

@Reducer
struct UsersFeature {
    @ObservableState
    struct State: Equatable {
        var isLoading = false
        var users = [UserModel]()
    }

    enum Action {
        case shown
        case loaded([UserModel]?)
        case deleteTapped(user: UserModel)
        case newAccessSelected(forUser: UserModel, newAccess: UserModel.AccessLevel)
    }

    @Injected(\.usersRepository)
    var repository

    @Injected(\.authenticationRepository)
    var authRepository

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .shown:
                state.isLoading = true
                return .run { send in
                    let items = try! await repository.getAll()
                    await send(.loaded(items))
                }
            case .loaded(let items):
                state.users = items ?? state.users
                state.isLoading = false
                return .none
            case .deleteTapped(let user):
                state.isLoading = true
                return .run { send in
                    try! await repository.delete(user: user)
                    await send(.shown)
                }
            case .newAccessSelected(let user, let newAccess):
                state.isLoading = true
                return .run { send in
                    try! await repository.updateAccessLevel(for: user, to: newAccess)
                    await send(.loaded(nil))
                }
            }
        }
    }
}

