import SwiftUI
import clients_libraries_GenericsUI
import ComposableArchitecture

struct MainHeaderView: View {

    let store: StoreOf<AppFeature>

    public var body: some View {
        HStack {
            VStack {
                HStack {
                    Spacer()
                    Text("Generic's restaurant #1")
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundStyle(Color.gAccent)

                }
                Text("Self pick up")
                    .font(.gCaption)
            }
            .onTapGesture {
                store.send(.showOrderDestination)
            }
            // This will be used later
            // Circle()
            //     .fill(Color.white)
            //     .frame(width: 40.0, height: 40.0)
        }
    }
}
