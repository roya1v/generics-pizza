import Testing
import ComposableArchitecture
import Factory

import SharedModels

@testable import GenericsDriver
@testable import GenericsCore

@MainActor
struct ProfileFeatureTests {

    @Test
    func testAppearing() async {
        
        let driverRepository = DriverRepositorySpy()
        Container.shared.driverRepository.register { driverRepository }

        let mockDetails = DriverDetails(name: "Test", surname: "Testowicz")
        driverRepository.getDetailsReturnValue = mockDetails

        let store = TestStore(initialState: ProfileFeature.State()) {
            ProfileFeature()
        }

        await store.send(.appeared)

        await store.receive(\.detailsLoaded) {
            $0.driverDetails = mockDetails
        }
    }
}

