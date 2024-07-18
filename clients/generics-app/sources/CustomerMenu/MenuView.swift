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
            Group {
                switch model.state {
                case .loading:
                    ProgressView()
                case .ready:
                    menu
                case .error:
                    Text("Something didn't work out :(")
                }
            }
            .navigationTitle("Menu")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                model.fetch()
            }
        }
    }

    var menu: some View {
        List(model.items) { item in
            getMenuItem(for: item)
        }
    }

    func getMenuItem(for item: MenuItem) -> some View {
        HStack {
            getImage(for: item)
            VStack(alignment: .leading) {
                Text(item.title)
                    .font(.headline)
                Text(item.description)
                    .font(.genericsCaption)
                    .foregroundStyle(.secondary)

            }
            Spacer()
            Button {
                model.add(item: item)
            } label: {
                Text(item.formattedPrice())
            }
            .buttonStyle(.borderedProminent)
        }
    }

    func getImage(for item: MenuItem) -> some View {
        Group {
            if let url = model.imageUrl(for: item) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                    case .failure(_), .empty:
                        Image("pizzza_placeholder")
                            .resizable()
                            .scaledToFit()
                    @unknown default:
                        fatalError()
                    }
                }
                .frame(width: 75.0)
            } else {
                Image("pizzza_placeholder")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 75.0)
            }
        }
    }
}

#Preview {
    MenuView()
}
