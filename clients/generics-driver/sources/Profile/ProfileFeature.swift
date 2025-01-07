import ComposableArchitecture
import Factory
import Foundation
import SharedModels

@Reducer
struct ProfileFeature {
    @ObservableState
    struct State: Equatable {
        var driverDetails: DriverDetails?

        struct DayStatistic {
            let count: Int
            let date: Date
        }
    }

    enum Action {
        // View
        case appeared
        case signOutTapped

        // Child
        // Internal
        case loggedOut(Result<Void, Error>)
        case detailsLoaded(Result<DriverDetails, Error>)
    }

    @Injected(\.authenticationRepository)
    private var repository

    @Injected(\.driverRepository)
    private var driverRepository

    var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .appeared:
                return .run { send in
                    await send(
                        .detailsLoaded(
                            Result { try await driverRepository.getDetails() }
                        )
                    )
                }
            case .signOutTapped:
                return .run { send in
                    await send(
                        .loggedOut(Result { try await repository.signOut() }))
                }
            case .detailsLoaded(.success(let details)):
                state.driverDetails = details
                return .none
            case .detailsLoaded(.failure(let error)):
                // TODO: Add error handling
                return .none
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
