//
//  AuthFeature.swift
//  GenericsRestaurants
//
//  Created by Mike S. on 09/07/2024.
//

import Foundation
import ComposableArchitecture
import Factory
import clients_libraries_GenericsCore

@Reducer
struct AuthFeature {
    @ObservableState
    enum State: Equatable {
        case login(LoginFeature.State)
        case createAccount(CreateAccountFeature.State)
    }
    
    enum Action {
        case login(LoginFeature.Action)
        case createAccount(CreateAccountFeature.Action)
    }
    
    @Injected(\.authenticationRepository)
    var repository
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .login(.goToCreateAccountTapped):
                state = .createAccount(CreateAccountFeature.State())
                return .none
            case .createAccount(.goToLoginTapped):
                state = .login(LoginFeature.State())
                return .none
            default:
                return .none
            }
        }
        .ifCaseLet(\.login, action: \.login) {
            LoginFeature()
        }
        .ifCaseLet(\.createAccount, action: \.createAccount) {
            CreateAccountFeature()
        }
    }
}


