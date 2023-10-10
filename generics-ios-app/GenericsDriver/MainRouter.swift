//
//  MainRouter.swift
//  GenericsDriver
//
//  Created by Mike S. on 16/08/2023.
//

import UIKit
import Factory
import Combine
import CoreLocation
import SharedModels

final class MainRouter: Router {

    @Injected(\.driverRepository)
    var driverRepository

    @Injected(\.locationRepository)
    var locationRepository

    private var cancellable = Set<AnyCancellable>()

    private var navigationController: UINavigationController!

    func start(on navigationController: UINavigationController) {
        self.navigationController = navigationController
        let vc = IdleViewController()
        navigationController.setViewControllers([vc], animated: true)
        vc.transitionIn(completion: nil) // Shitty solution but for some reason the nav vc delegate method isn't called
        self.setupWork()
    }

    private func setupWork() {
        Task {
            do {
                try await self.driverRepository
                    .getFeed()
                    .receive(on: DispatchQueue.main)
                    .sink { completion in
                        fatalError("Didn't expect a completion: \(completion)")
                    } receiveValue: { message in
                        Task {
                            switch message {
                            case let .offerOrder(fromAddress, toAddress, reward):
                                await self.showNewOffer(fromAddress:fromAddress, toAddress: toAddress, reward: reward)
                            }
                        }
                    }
                    .store(in: &cancellable)
            } catch {
                fatalError("Should add error handling here. Error: \(error)")
            }
        }
    }

    @MainActor
    private func showNewOffer(fromAddress: AddressModel, toAddress: AddressModel, reward: Int) {
        let vc = MapNavigationViewController()
        navigationController.pushViewController(vc, animated: true)
        vc.set(state: .offer(.init(restaurantAddress: fromAddress,
                                   customerAddress: toAddress,
                                   reward: reward)))
    }

    private func setLoggedInFlow() {
        if locationRepository.state == .ready {
            setViewController(IdleViewController())
            setupWork()
        } else {
            setViewController(OnboardingPermissionViewController())
        }
    }

    private func setViewController( _ vc: UIViewController) {
        navigationController.setViewControllers([vc], animated: true)
    }
}
