import SwiftUI
import ComposableArchitecture
import Charts

struct ProfileView: View {

    let store: StoreOf<ProfileFeature>

    var body: some View {
        List {
            Section {
                NavigationLink {
                    Text("Hello, world!")
                } label: {
                    HStack {
                        AvatarView("JK")
                            .frame(width: .g3XL)
                        VStack(alignment: .leading) {
                            Text("Jan Kowalski")
                                .font(.title)
                            Text("Profile details")
                                .font(.caption)
                        }
                    }
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

struct AvatarView: View {

    let content: String

    init(_ content: String = "") {
        self.content = content
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(.blue)
            Text(content)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.white)
        }

    }
}
