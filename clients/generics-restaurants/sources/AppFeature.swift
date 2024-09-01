//
//  AppFeature.swift
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
        case auth(AuthFeature.State)
        case dashboard(DashboardFeature.State)
    }

    enum Action {
        case launched
        case stateUpdated(AuthenticationState)
        case auth(AuthFeature.Action)
        case dashboard(DashboardFeature.Action)
    }

    @Injected(\.authenticationRepository)
    var repository

    var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
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
                    state = .auth(.login(LoginFeature.State()))
                }
                return .none
            case .auth:
                return .none
            }
        }
        .ifCaseLet(\.auth, action: \.auth) {
            AuthFeature()
        }
        .ifCaseLet(\.dashboard, action: \.dashboard) {
            DashboardFeature()
        }
    }
}
