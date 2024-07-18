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

public struct MenuView: View {
    
    @StateObject var model = MenuViewModel()
    
    public init() { }
    
    public var body: some View {
        NavigationView {
            ZStack {
                Color(uiColor: .systemGray6)
                    .ignoresSafeArea()
                VStack {
                    HStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 40.0, height: 40.0)
                        VStack {
                            Text("New York, Bakers str. 123")
                        }
                        Spacer()
                        Circle()
                            .fill(Color.white)
                            .frame(width: 40.0, height: 40.0)
                    }
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
        }
    }
    
    var menu: some View {
        List(model.items) { item in
            MenuRowView(
                item: item,
                imageUrl: model.imageUrl(for: item)
            ) {
                model.add(item: item)
            }
        }
        .listStyle(.plain)
        
    }
}

#Preview {
    MenuView()
}
