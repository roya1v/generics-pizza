//
//  MenuItemView.swift
//  GenericsApp
//
//  Created by Mike Shevelinsky on 01/02/2023.
//

import SwiftUI
import Factory
import GenericsUI
import GenericsRepositories

struct MenuItemView: View {
    let name: String
    let description: String
    let imageURL: URL?

    var body: some View {
        CardView {
            VStack {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .empty:
                        Image("pizzza_placeholder")
                            .resizable()
                            .scaledToFit()
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                    case .failure(_):
                        Image("pizzza_placeholder")
                            .resizable()
                            .scaledToFit()
                    @unknown default:
                        fatalError()
                    }
                }
                Spacer()
                VStack(alignment: .leading) {
                    Text(name)
                    Text(description)
                        .font(.genericsCaption)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                    Text("13.99$")
                        .font(.system(size: 16.0, weight: .bold))
                        .padding(4.0)
                }
                .frame(maxHeight: 100.0)
            }
            .padding()
        }
    }
}

struct MenuItemView_Previews: PreviewProvider {
    static var previews: some View {
        Container.menuRepository.register { mockMenuRepository() }
        return MenuView()
    }
}
