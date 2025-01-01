import SwiftUI
import ComposableArchitecture
import Charts

struct ProfileView: View {

    let store: StoreOf<ProfileFeature>

    var body: some View {
        List {
            Section {
                HStack {
                    AvatarView("JK")
                        .frame(width: .g3XL)
                    VStack(alignment: .leading) {
                        Text("Jan Kowalski")
                            .font(.title)
                        Text("Driver #1234")
                            .font(.caption)
                    }
                }
                NavigationLink {
                    Text("Hello, world!")
                } label: {
                    Text("Contact support")
                }
            }
            Section("Order History") {
                Chart {
                    ForEach(ProfileFeature.State.DayStatistic.mockData, id: \.date) { ordersInfo in
                      BarMark(
                        x: .value("Date", ordersInfo.date),
                        y: .value("Orders", ordersInfo.count)
                      )
                    }
                }
                .padding([.top])
                Button("All orders...") {

                }
            }
            Button("Sign out") {
                store.send(.signOutTapped)
            }
        }
    }
}


