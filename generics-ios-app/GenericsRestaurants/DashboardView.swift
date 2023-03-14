//
//  DashboardView.swift
//  GenericsRestaurants
//
//  Created by Mike S. on 13/03/2023.
//

import SwiftUI

enum Items: String {
    case now
    case menu
}

struct DashboardView: View {

    @State private var selected: Items = .now


    var body: some View {
        NavigationSplitView {
            List([Items.now, .menu], id: \.rawValue,
                 selection: $selected) { item in
                NavigationLink(item.rawValue, value: item)
            }
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
