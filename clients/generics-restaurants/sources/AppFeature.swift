//
//  LoginFeature.swift
//  GenericsRestaurants
//
//  Created by Mike S. on 09/07/2024.
//

import Foundation
import ComposableArchitecture
import Factory
import clients_libraries_GenericsCore

@Reducer
struct AppFeature {
    @ObservableState
    enum State: Equatable {
        case loading
        case login(LoginFeature.State)
        case dashboard(DashboardFeature.State)
    }
    
    enum Action {
        case launched
        case stateUpdated(AuthenticationState)
        case logoutTapped
        case login(LoginFeature.Action)
        case dashboard(DashboardFeature.Action)
    }
    
    @Injected(\.authenticationRepository)
    var repository
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .dashboard:
                return .none
            case .launched:
                repository.reload()
                return .merge(
                    .send(.stateUpdated(repository.state)),
                    .publisher {
                        repository
                            .statePublisher
                            .map { state in
                                Action.stateUpdated(state)
                            }
                            .receive(on: DispatchQueue.main)
                    }
                )
            case .logoutTapped:
                return .run { send in
                    try! await repository.signOut()
                }
            case .stateUpdated(let newState):
                switch newState {
                case .unknown:
                    state = .loading
                case .loggedIn:
                    state = .dashboard(
                        DashboardFeature.State(now: NowFeature.State(),
                                               orderHistory: OrderHistoryFeature.State(),
                                               menu: MenuFeature.State(),
                                               users: UsersFeature.State())
                    )
                case .loggedOut:
                    state = .login(LoginFeature.State())
                }
                return .none
            case .login:
                return .none
            }
        }
        .ifCaseLet(\.login, action: \.login) {
            LoginFeature()
        }
        .ifCaseLet(\.dashboard, action: \.dashboard) {
            DashboardFeature()
        }
    }
}

