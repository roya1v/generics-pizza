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

final class MainRouter: NSObject {

    enum AppState {
        case login
        case onboarding
        case idle
        case etc
    }

    private let navigationController = UINavigationController()

    @Injected(\.authenticationRepository)
    var authRepository

    @Injected(\.locationRepository)
    var locationRepository

    @Injected(\.driverRepository)
    var driverRepository

    private var cancellable = Set<AnyCancellable>()

    override init() {
        super.init()

        navigationController.delegate = self
    }

    func start() -> UIViewController {
        setViewController(SplashViewController())
        return navigationController
    }

    func showApp() {
        authRepository
            .state
            .receive(on: DispatchQueue.main)
            .sink { state in
                switch state {
                case .loggedOut:
                    self.setViewController(LoginViewController())
                case .loggedIn:
                    self.setLoggedInFlow()
                }
            }
            .store(in: &cancellable)

        locationRepository
            .state
            .sink { state in
                switch state {
                case .ready:
                    self.setViewController(IdleViewController())
                    self.setupWork()
                default:
                    self.setViewController(OnboardingPermissionViewController())
                }
            }
            .store(in: &cancellable)

        authRepository.reload()
    }

    private func setupWork() {
        Task {
            try? await self.driverRepository
                .getFeed()
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: {_ in }, receiveValue: {message in
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
        }
    }

    private func setLoggedInFlow() {
        if locationRepository.currentState == .ready {
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

extension MainRouter: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard fromVC is CustomOutTransitinable,
              toVC is CustomInTransitinable else {
            return nil
        }
        return CustomInOutTransitinableController()
    }
}
