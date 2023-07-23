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
            Spacer()
            deviceView
                .dropDestination(for: FeedCardType.self) { items, location in
                    cards += items
                    return true
                }
                .padding()
            Spacer()
            libraryView
                .padding()
            Spacer()
        }
    }

    @ViewBuilder
    var libraryView: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Library")
                VStack {
                    ForEach(library, id: \.self) { cardType in
                        getCardView(for: cardType)
                            .draggable(cardType)
                    }
                    Spacer()
                }
            }
        }
        .frame(width: 200.0)
    }

    @ViewBuilder
    var deviceView: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("On device")
                VStack {
                    ForEach(cards, id: \.self) { cardType in
                        getCardView(for: cardType)
                            .contextMenu {
                                Button("Delete") {
                                    cards.removeAll { $0 == cardType }
                                }
                            }
                    }
                    Spacer()
                }
            }
        }
        .frame(width: 200.0)
    }
}

struct UserFeedView_Previews: PreviewProvider {
    static var previews: some View {
        UserFeedView()
    }
}


func getCardView(for cardType: FeedCardType) -> some View {
    switch cardType {
    case let .bigImage(title, subtitle, _):
        return AnyView(BigImageCardView(title: title, subtitle: subtitle, ctaTitle: "CTA") {
            Image("pizza")
                .resizable()
                .scaledToFit()
        } action: {

        })
    case .carousel:
        return AnyView(CarouselCardView())
    case let .cta(title, subtitle, _):
        return AnyView(CtaCardView(title: title, subtitle: subtitle, ctaTitle: "CTA") {

        })
    }
}

extension FeedCardType: CaseIterable {
    public static var allCases: [FeedCardType] {
        [.carousel(title: "Lorem ipsum"),
         .bigImage(title: "Lorem ipsum", subtitle: "Lorem ipsum", ctaDestination: .menu),
         .cta(title: "Lorem ipsum", subtitle: "Lorem ipsum", ctaDestination: .menu)

        ]
    }
}

extension FeedCardType: Transferable {
    static public var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .json)
    }
}
