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
                VStack {
                    Text("User email: ")
                        .font(.title)
                    HStack {
                        Menu {
                            ForEach([UserModel.AccessLevel.admin, .employee], id: \.self) {
                                Text("\($0)")
                                Divider()
                            }
                        } label: {
                            Text("Admin")
                        }
                        Button("Delete user") {

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

#Preview {
    UsersView(store: Store(initialState: UsersFeature.State(isLoading: false, users: [])) {
        UsersFeature()
    })
}
