import SwiftUI
import Factory
import ComposableArchitecture

enum Items: String {
    case now
    case orderHistory
    case insights
    case menu
    case users
}

struct DashboardView: View {

    @State private var selected: Items = .now
    let store: StoreOf<DashboardFeature>

    var body: some View {
        WithPerceptionTracking {
            ZStack {
                NavigationSplitView {
                    List(selection: $selected) {
                        Section("Orders") {
                            NavigationLink("Current", value: Items.now)
                            NavigationLink("History", value: Items.orderHistory)
                            NavigationLink("Insights", value: Items.insights)
                        }
                        Section("Other") {
                            NavigationLink("Menu", value: Items.menu)
                            NavigationLink("Users", value: Items.users)
                        }
                    }
                } detail: {
                    switch selected {
                    case .now:
                        NowView(store: store.scope(state: \.now,
                                                   action: \.now))
                    case .orderHistory:
                        OrderHistoryView(store: store.scope(state: \.orderHistory,
                                                            action: \.orderHistory))
                    case .insights:
                        InsightsView(store: store.scope(state: \.insights,
                                                        action: \.insights))
                    case .menu:
                        MenuView(store: store.scope(state: \.menu,
                                                    action: \.menu))
                    case .users:
                        if let store = store.scope(state: \.users,
                                                   action: \.users) {
                            UsersView(store: store)
                        }
                    }
                }
                if store.isLoggingOut {
                    VStack {
                        ProgressView()
                        Text("Signing out")
                    }
                    .padding()
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 8.0))
                }
            }
        }
    }
}
