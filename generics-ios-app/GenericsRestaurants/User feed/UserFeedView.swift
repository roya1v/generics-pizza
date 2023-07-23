//
//  UserFeedView.swift
//  GenericsRestaurants
//
//  Created by Mike S. on 23/07/2023.
//

import SwiftUI
import GenericsModels

struct UserFeedView: View {

    @State var library = FeedCardType.allCases
    @State var cards = [FeedCardType]()

    var body: some View {
        HStack {
            deviceView
                .frame(maxWidth: .infinity)
                .dropDestination(for: FeedCardType.self) { items, location in
                    cards += items
                    return true
                }
                .padding()
            libraryView
                .frame(maxWidth: .infinity)
                .padding()
        }
    }

    @ViewBuilder
    var libraryView: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Library")
                ForEach(library, id: \.self) { cardType in
                    getCardView(for: cardType)
                        .draggable(cardType)
                }
                Spacer()

            }
        }
    }

    @ViewBuilder
    var deviceView: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("On device")
                ForEach(cards, id: \.self) { cardType in
                    getCardView(for: cardType)
                        .contextMenu {
                            if let index = cards.firstIndex(of: cardType),
                               index > 0 {
                                Button("Move up") {
                                    let card = cards[index]
                                    cards.remove(at: index)
                                    cards.insert(card, at: index - 1)
                                }
                            }

                            if let index = cards.firstIndex(of: cardType),
                               index < cards.count - 1 {
                                Button("Move down") {
                                    let card = cards[index]
                                    cards.remove(at: index)
                                    cards.insert(card, at: index + 1)
                                }
                            }

                            Button("Edit") {
                                cards.removeAll { $0 == cardType }
                            }
                            Button("Delete") {
                                cards.removeAll { $0 == cardType }
                            }
                        }

                    Spacer()
                }
            }
        }
    }
}

struct UserFeedView_Previews: PreviewProvider {
    static var previews: some View {
        UserFeedView()
    }
}


func getCardView(for cardType: FeedCardType) -> some View {
    switch cardType {
    case let .bigImage(title, subtitle, imageSource, cta):
        if let cta {
            return AnyView(BigImageCardView(title: title, subtitle: subtitle, ctaTitle: cta.label) {
                if case let .local(imageName) = imageSource {
                    return Image(imageName)
                        .resizable()
                        .scaledToFit()
                } else {
                    fatalError()
                }
            } action: {

            })
        } else {
            return AnyView(BigImageCardView(title: title, subtitle: subtitle, ctaTitle: nil) {
                Image("pizza")
                    .resizable()
                    .scaledToFit()
            } action: {})
        }

    case .carousel:
        return AnyView(CarouselCardView())
    case let .cta(title, subtitle, cta):
        return AnyView(CtaCardView(title: title, subtitle: subtitle, ctaTitle: cta.label) {})
    }
}

extension FeedCardType: CaseIterable {
    public static var allCases: [FeedCardType] {
        [.carousel(title: "Lorem ipsum"),
         .bigImage(title: "Lorem ipsum",
                   subtitle: "Lorem ipsum dolor sit amet, consectetur adipiscing elit... ",
                   image: .local(name: "pizza"),
                   ctaDestination: .menu),
         .bigImage(title: "Lorem ipsum",
                   subtitle: "Lorem ipsum dolor sit amet, consectetur adipiscing elit... ",
                   image: .local(name: "pizza"),
                   ctaDestination: nil),
         .cta(title: "Lorem ipsum",
              subtitle: "Lorem ipsum dolor sit amet, consectetur adipiscing elit... ",
              ctaDestination: .menu)

        ]
    }
}

extension FeedCardType: Transferable {
    static public var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .json)
    }
}
