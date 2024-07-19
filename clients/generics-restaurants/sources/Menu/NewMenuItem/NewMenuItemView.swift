//
//  NewMenuItemView.swift
//  GenericsRestaurants
//
//  Created by Mike S. on 14/03/2023.
//

import SwiftUI
import ComposableArchitecture

struct NewMenuItemView: View {

    @Perception.Bindable var store: StoreOf<NewMenuItemFeature>
    @State var isSelectingImage = false

    var body: some View {
        WithPerceptionTracking {
            VStack {
                Text("New Item")
                    .font(.title)
                HStack {
                    form
                    imageSelection
                }
                if store.hasError {
                    Text("Error occured!")
                }
                if store.isLoading {
                    ProgressView()
                } else {
                    HStack {
                        Button {
                            store.send(.createTapped)
                        } label: {
                            Text("Create")
                        }
                        Button(role: .cancel) {
                            store.send(.cancelTapped)
                        } label: {
                            Text("Cancel")
                        }
                    }
                }
            }
            .padding()
            .frame(width: 400, height: 200)
        }
    }

    var form: some View {
        Form {
            TextField("Title", text: $store.title)
            TextField("Description", text: $store.description)
            TextField("Price", value: $store.price, format: .currency(code: "USD"))
            Spacer()
        }
    }

    var imageSelection: some View {
        VStack {
            if let url = store.imageUrl {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                    case .failure, .empty:
                        Image("pizzza_placeholder")
                            .resizable()
                            .scaledToFit()
                    @unknown default:
                        fatalError()
                    }
                }
                .frame(width: 75.0)
            } else {
                ZStack {
                    Color.gray
                        .aspectRatio(1.0, contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 8.0))
                    Image("pizzza_placeholder")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 35.0)
                }

            }
            Button {
                isSelectingImage = true
            } label: {
                Text("Select image")
            }
        }
        .fileImporter(isPresented: $isSelectingImage, allowedContentTypes: [.jpeg]) { result in
            do {
                let fileURL = try result.get()
                if fileURL.startAccessingSecurityScopedResource() {
                    store.send(.imageSelected(fileURL))
                }
            } catch {
                print("error reading")
                print(error.localizedDescription)
            }
        }
    }
}

#Preview {
    NewMenuItemView(store: Store(initialState: NewMenuItemFeature.State(), reducer: {
        NewMenuItemFeature()
    }))
}
