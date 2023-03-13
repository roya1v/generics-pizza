//
//  DashboardView.swift
//  GenericsRestaurants
//
//  Created by Mike S. on 13/03/2023.
//

import SwiftUI

struct DashboardView: View {
    var body: some View {
        TabView {
            NowView()
                .tabItem {
                    Text("Now")
                }
            MenuView()
                .tabItem {
                    Text("Menu")
                }
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
