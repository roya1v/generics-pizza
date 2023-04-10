//
//  DashboardView.swift
//  GenericsRestaurants
//
//  Created by Mike S. on 13/03/2023.
//

import SwiftUI
import Factory

enum Items: String {
    case now
    case menu

    var label: String {
        switch self {
        case .now:
            return "Now"
        case .menu:
            return "Menu"
        }
    }
}

struct DashboardView: View {

    @State private var selected: Items = .now
    @Injected(Container.authenticationRepository) private var repository

    var body: some View {
        NavigationSplitView {
            List([Items.now, .menu], id: \.rawValue,
                 selection: $selected) { item in
                NavigationLink(item.label, value: item)
            }
            Button {
                Task {
                    try? await repository.signOut()
                }
            } label: {
                Text("Sign out")
            }
            .padding()

        } detail: {
            switch selected {
            case .now:
                NowView()
            case .menu:
                MenuView()
            }
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
