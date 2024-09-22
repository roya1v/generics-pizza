import SwiftUI
import ComposableArchitecture
import clients_libraries_GenericsCore

struct MenuItemFormView: View {

    @Perception.Bindable var store: StoreOf<MenuItemFormFeature>
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
                if let error = store.errorMessage {
                    Text(error)
                }
                if store.isLoading {
                    ProgressView()
                } else {
                    HStack {
                        Button {
                            store.send(.submitTapped)
                        } label: {
                            if store.state.id != nil {
                                Text("Update")
                            } else {
                                Text("Create")
                            }
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
        .task {
            store.send(.appeared)
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
            if let image = store.image {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFit()
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
        .fileImporter(isPresented: $isSelectingImage, allowedContentTypes: [.jpeg, .png]) { result in
            do {
                let fileURL = try result.get()
                if fileURL.startAccessingSecurityScopedResource(),
                   let image =  ImageData(contentsOf: fileURL) {
                    store.send(.imageSelected(image))
                }
            } catch {
                print("error reading")
                print(error.localizedDescription)
            }
        }
    }
}
