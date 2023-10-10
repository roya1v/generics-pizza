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
                    .print()
                    .sink(receiveCompletion: { _ in }, receiveValue: {message in
                        switch message {
                        case let .offerOrder(fromAddress, toAddress, reward):
                            Task {
                                let vc = await MapNavigationViewController()
                                await self.navigationController.pushViewController(vc, animated: true)
                                await vc.set(state: .offer(.init(restaurantAddress: fromAddress,
                                                           customerAddress: toAddress,
                                                           reward: reward)))
                            }

                        }
                    })
                    .store(in: &self.cancellable)
            } catch {
                print(error)
            }

        }
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
