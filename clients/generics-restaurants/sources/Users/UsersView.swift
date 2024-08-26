//
//  UsersView.swift
//  GenericsRestaurants
//
//  Created by Mike S. on 19/03/2024.
//

import SwiftUI
import ComposableArchitecture
import SharedModels
import clients_libraries_GenericsCore

struct UsersView: View {

    let store: StoreOf<UsersFeature>
    @State private var selectedId: Set<UUID?> = []

    private var isShowingSheet: Binding<Bool> {
        Binding {
            !selectedId.isEmpty
        } set: { _ in

        }
    }

    var body: some View {
        WithPerceptionTracking {
            Group {
                switch store.state {
                case .loading:
                    ProgressView()
                case .loaded(let users):
                    Table(users, selection: $selectedId) {
                        TableColumn("Email", value: \.email)
                        TableColumn("Access", value: \.access.rawValue)
                    }
                case .error(let message):
                    Text(message)
                }
            }

            .onAppear {
                store.send(.shown)
            }
            .sheet(isPresented: isShowingSheet) {
                if let userId = selectedId.first,
                   case let .loaded(users) = store.state,
                   let userId,
                   let user = users[id: userId] {
                    VStack {
                        Text("User email: \(user.email)")
                            .font(.title)
                        HStack {
                            if store.state == .loading {
                                // TODO: Make it smaller
                                ProgressView()
                            }
                            Menu {
                                ForEach([UserModel.AccessLevel.admin, .employee], id: \.self) { accessLevel in
                                    Button("\(accessLevel)") {
                                        store.send(.newAccessSelected(forUser: user, newAccess: accessLevel))
                                    }
                                }
                            } label: {
                                Text("\(user.access)")
                            }
                            Button("Delete user") {
                                store.send(.deleteTapped(user: user))
                                selectedId = [] // Temporary solution
                            }
                        }
                        Button("Close") {
                            selectedId = []
                        }
                    }
                    .padding()
                    .frame(width: 300.0, height: 100.0, alignment: .center)
                }

            }
        }
    }
}
