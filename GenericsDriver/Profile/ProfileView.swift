import SwiftUI
import ComposableArchitecture
import Charts

struct ProfileView: View {

    let store: StoreOf<ProfileFeature>

    var body: some View {
        WithPerceptionTracking {
            List {
                Section {
                    if let details = store.driverDetails {
                        HStack {
                            AvatarView("\(details.name.first ?? Character(""))\(details.surname.first ?? Character(""))")
                                .frame(width: .g3XL)
                            VStack(alignment: .leading) {
                                Text("\(details.name) \(details.surname)")
                                    .font(.title)
                                Text("Driver #1234")
                                    .font(.caption)
                            }
                        }
                    } else {
                        ProgressView()
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
                                x: .value("Date", ordersInfo.date, unit: .day),
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
            .task {
                store.send(.appeared)
            }
        }
    }
}
