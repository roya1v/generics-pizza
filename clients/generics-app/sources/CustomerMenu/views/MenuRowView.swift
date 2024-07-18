//
//  MenuRowView.swift
//  GenericsApp
//
//  Created by Mike S. on 01/02/2023.
//

import SwiftUI
import SharedModels

struct MenuRowView: View {
    
    let item: MenuItem
    let imageUrl: URL?
    let action: () -> Void

    var body: some View {
        HStack {
            getImage(for: item)
            VStack(alignment: .leading) {
                Text(item.title)
                    .font(.headline)
                Text(item.description)
                    .font(.genericsCaption)
                    .foregroundStyle(.secondary)
                Button {
                    action()
                } label: {
                    Text(item.formattedPrice())
                        .font(.caption)
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
    
    func getImage(for item: MenuItem) -> some View {
        Group {
            if let imageUrl {
                AsyncImage(url: imageUrl) { phase in
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
    MenuRowView(
        item: MenuItem(id: nil,
                       title: "Super Pepperoni",
                       description: "Tomato souce, double mozzarela, double pepperoni",
                       price: 699),
        imageUrl: nil
    ) {
        
    }
}
