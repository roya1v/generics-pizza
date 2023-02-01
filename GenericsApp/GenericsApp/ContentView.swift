//
//  ContentView.swift
//  GenericsApp
//
//  Created by Mike Shevelinsky on 01/02/2023.
//

import SwiftUI

struct ContentView: View {

    @State var isShowing = false

    @Namespace var heroAnimation: Namespace.ID

    var body: some View {
        if isShowing {
            ScrollView(.vertical) {
                ZStack(alignment: .topTrailing) {
                    Image("pizza")
                        .resizable()
                        .scaledToFit()
                        .transition(.scale)
                        .matchedGeometryEffect(id: "image", in: heroAnimation)
                    Button {
                        withAnimation(.spring()) {
                                        isShowing.toggle()
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24.0))
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.white, .black.opacity(0.5))

                    }
                    .offset(x: -30, y: 25)
                }

                VStack(alignment: .leading) {
                    Text("OFFER")
                        .font(.system(size: 16.0, weight: .medium))
                        .foregroundColor(.gray)
                        .matchedGeometryEffect(id: "headline", in: heroAnimation)
                    Text("Enjoy the rustic taste of countryside")
                        .font(.system(size: 28.0, weight: .bold))
                        .matchedGeometryEffect(id: "title", in: heroAnimation)
                    Text("Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?"
                        )
                    .font(.system(size: 16.0, weight: .regular))
                    .foregroundColor(.gray)
                }
                .padding()
                Spacer()
            }
            .statusBarHidden(isShowing)
            .ignoresSafeArea()
        } else {
            ScrollView(.vertical) {
                VStack(alignment: .leading) {
                    Image("pizza")
                        .resizable()
                        .scaledToFit()
                        .transition(.scale)
                        .matchedGeometryEffect(id: "image", in: heroAnimation)
                    VStack(alignment: .leading) {
                        Text("OFFER")
                            .font(.system(size: 16.0, weight: .medium))
                            .foregroundColor(.gray)
                            .matchedGeometryEffect(id: "headline", in: heroAnimation)
                        Text("Enjoy the rustic taste of countryside")
                            .font(.system(size: 28.0, weight: .bold))
                            .matchedGeometryEffect(id: "title", in: heroAnimation)
                        Text("The mushroom pizza will give you the enjoyment of fresh air. Order now."
                            )
                        .font(.system(size: 16.0, weight: .regular))
                        .foregroundColor(.gray)
                    }
                    //.background(.blue)
                    .padding()
                }
                .background(.white)
                .compositingGroup()
                .cornerRadius(16.0)
                .shadow(radius: 8.0)
                .padding()
                .onTapGesture {
                    withAnimation(.spring()) {
                                    isShowing.toggle()
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
