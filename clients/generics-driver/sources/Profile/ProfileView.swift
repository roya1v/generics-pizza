import SwiftUI
import ComposableArchitecture

struct ProfileView: View {

    let store: StoreOf<ProfileFeature>

    var body: some View {
        List {
            Button("Sign out") {
                store.send(.signOutTapped)
            }
        }
    }
}
