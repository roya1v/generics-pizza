//
//  NowView.swift
//  GenericsRestaurants
//
//  Created by Mike S. on 13/03/2023.
//

import SwiftUI
import GenericsCore
import Factory
import SharedModels

struct NowView: View {

    @StateObject var model = NowViewModel()

    var body: some View {
        List {
            Section("Orders") {
                ForEach(model.orders) { order in
                    OrderListRowView(order: order) {
                        model.update(order, to: order.state!.next())
                    }
                    Divider()
                }
            }
        }
        .onAppear {
            model.fetch()
        }
    }
}

#Preview {
    NowView()
}
