import SwiftUI
import clients_libraries_GenericsUI
import ComposableArchitecture

struct MainHeaderView: View {

    let store: StoreOf<AppFeature>

    public var body: some View {
        HStack {
            Circle()
                .fill(Color.white)
                .frame(width: 40.0, height: 40.0)
            VStack {
                HStack {
                    Text("New York, Bakers str. 123")
                    Image(systemName: "chevron.down")
                        .foregroundStyle(Color.gAccent)

                }
                Text("Free delivery in 35 min")
                    .font(.gCaption)
            }
            .onTapGesture {
                store.send(.showOrderDestination)
            }
            Spacer()
            Circle()
                .fill(Color.white)
                .frame(width: 40.0, height: 40.0)
        }
    }
}
