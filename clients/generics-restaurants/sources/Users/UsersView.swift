//
//  UsersView.swift
//  GenericsRestaurants
//
//  Created by Mike S. on 19/03/2024.
//

import SwiftUI
import ComposableArchitecture
import SharedModels

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
            Table(store.users, selection: $selectedId) {
                TableColumn("Email", value: \.email)
                TableColumn("Access", value: \.access.rawValue)
            }
            .onAppear {
                store.send(.shown)
            }
            .sheet(isPresented: isShowingSheet) {
                if let userId = selectedId.first,
                   let userId,
                   let user = store.users.first(where: { $0.id == userId}) {
                    VStack {
                        Text("User email: \(user.email)")
                            .font(.title)
                        HStack {
                            if store.isLoading {
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

#Preview {
    UsersView(store: Store(initialState: UsersFeature.State(isLoading: false, users: [])) {
        UsersFeature()
    })
}
