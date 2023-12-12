//
//  NewMenuItemView.swift
//  GenericsRestaurants
//
//  Created by Mike S. on 14/03/2023.
//

import SwiftUI

struct NewMenuItemView: View {

    @StateObject var model = NewMenuItemViewModel()
    @State var isSelectingImage = false

    var body: some View {
        VStack {
            Text("New Item")
                .font(.title)
            HStack {
                form
                VStack {
                    if let url = model.imageUrl {
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
            }
        }
        .padding()
        .frame(width: 400.0, height: 200.0)
        .fileImporter(isPresented: $isSelectingImage, allowedContentTypes: [.jpeg]) { result in
            do {
                let fileURL = try result.get()
                if fileURL.startAccessingSecurityScopedResource() {
                    model.imageUrl = fileURL
                }
            } catch {
                print ("error reading")
                print (error.localizedDescription)
            }
        }
    }

    var form: some View {
        Form {
            TextField("Title", text: $model.title)
            TextField("Description", text: $model.description)
            TextField("Price", value: $model.price, format: .currency(code: "USD"))

            if model.state == .error {
                Text("Error occured!")
            }
            if model.state == .loading {
                ProgressView()
            } else {
                Button("Create") {
                    model.createMenuItem()
                }
            }
        }
    }
}

struct NewMenuItemView_Previews: PreviewProvider {
    static var previews: some View {
        NewMenuItemView()
    }
}
