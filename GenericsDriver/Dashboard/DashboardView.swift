import SwiftUI
import ComposableArchitecture
import MapKit

struct DashboardView: View {

    @Bindable
    var store: StoreOf<DashboardFeature>

    var body: some View {
        NavigationStack {
                ZStack(alignment: .topTrailing) {
                    ZStack(alignment: .bottom) {
                        map
                        .ignoresSafeArea()
                        DetailsTile(store: store.scope(state: \.detailsTile, action: \.detailsTile))
                            .padding()
                    }
                    Button {
                        store.send(.profileTapped)
                    } label: {
                        AvatarView("JK", size: .compact)
                            .frame(width: .g2XL)
                            .padding()
                    }
                }
            .navigationDestination(item: $store.scope(state: \.profile, action: \.profile)) { childStore in
                ProfileView(store: childStore)
            }
            .task {
                store.send(.appeared)
            }
            .toolbar(.hidden)
        }
    }

    private var map: some View {
        Map(position: $store.mapPosition.sending(\.mapMoved)) {
            Marker(coordinate: store.restaurant) {
                Image(systemName: "fork.knife")
            }
            UserAnnotation()

            if let client = store.client {
                Marker(coordinate: client) {
                    Image(systemName: "flag.pattern.checkered")
                }
                .tint(.black)
            }
            if let route = store.route {
                MapPolyline(route.polyline)
                    .stroke(.blue, lineWidth: 5)
            }
        }
    }
}

#Preview {
    DashboardView(
        store: Store(
            initialState: DashboardFeature.State(
                profile: nil,
                mapPosition: .region(
                    .init(
                        center: .restaurant,
                        latitudinalMeters: 1000.0,
                        longitudinalMeters: 1000.0
                    )
                ),
                restaurant: .restaurant,
                client: .client,
                route: nil,
                detailsTile: DetailsTileFeature.State.offerOrder(
                    details: "Hello, World!"
                ),
                order: nil
            )
        ) {
            Reduce<DashboardFeature.State, DashboardFeature.Action> { state, action in
                switch action {
                case .appeared:
                    return .run { send in
                        let request = MKDirections.Request()
                        request.source = .init(placemark: .init(coordinate: .restaurant))
                        request.destination = .init(placemark: .init(coordinate: .client))
                        request.transportType = .any
                        let directions = MKDirections(request: request)
                        let response = try? await directions.calculate()
                        let route = response!.routes.first!
                        await send(
                            .newOrder(
                                details: "Hello, World!",
                                client: .client,
                                route: route
                            )
                        )
                    }
                case .newOrder(let details, let client, let route):
                    state.route = route
                    return .none
                default:
                    return .none
                }
            }
    })
}
