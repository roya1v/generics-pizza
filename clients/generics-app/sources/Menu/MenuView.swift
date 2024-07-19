//
//  MenuView.swift
//  GenericsApp
//
//  Created by Mike S. on 01/02/2023.
//

import SwiftUI
import Factory
import SharedModels
import clients_libraries_GenericsCore

struct MenuView: View {
    
    @StateObject var model = MenuViewModel()
    @State var detailItem: MenuItem? = nil
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(uiColor: .systemGray6)
                    .ignoresSafeArea()
                VStack {
                    MainHeaderView()
                        .padding()
                    ZStack {
                        RoundedRectangle(cornerRadius: 16.0)
                            .fill(Color.white)
                            .ignoresSafeArea()
                        VStack {
                            MenuHeaderView()
                            switch model.state {
                            case .loading:
                                ProgressView()
                            case .ready:
                                menu
                            case .error:
                                Text("Something didn't work out :(")
                            }
                        }
                    }
                    .task {
                        model.fetch()
                    }
                }
            }
            .fullScreenCover(item: $detailItem) { item in
                NavigationView { // So we see the nav title
                    MenuDetailView(item: item)
                }
            }
        }
    }
    
    var menu: some View {
        List(model.items) { item in
            MenuRowView(
                item: item,
                imageUrl: model.imageUrl(for: item)
            ) {
                detailItem = item
            }
            .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        
    }
}

#Preview {
    MenuView()
}
