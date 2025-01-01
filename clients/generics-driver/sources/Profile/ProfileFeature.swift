import ComposableArchitecture
import Factory
import Foundation

@Reducer
struct ProfileFeature {
    @ObservableState
    struct State: Equatable {

        struct DayStatistic {
            let count: Int
            let date: Date
        }
    }

    enum Action {
        // View
        case signOutTapped

        // Child
        // Internal
        case loggedOut(Result<Void, Error>)
    }

    @Injected(\.authenticationRepository)
    private var repository

    var body: some ReducerOf<Self> {
        Reduce<State, Action> { _, action in
            switch action {
            case .signOutTapped:
                return .run { send in
                    await send(
                        .loggedOut(Result { try await repository.signOut() }))
                }
            case .loggedOut:
                return .none
            }
        }
    }
}

extension ProfileFeature.State.DayStatistic {
    static var mockData: [Self] {
        (-14...0)
            .map { daysBefore in
                ProfileFeature.State.DayStatistic(
                    count: Int.random(in: 4...20),
                    date: Calendar.current.date(
                        byAdding: .day,
                        value: daysBefore,
                        to: .now
                    )!
                )
            }
    }
}
