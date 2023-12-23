//
//  AppRouter.swift
//  GenericsHelpers
//
//  Created by Mike S. on 23/09/2023.
//

import UIKit
import Factory
import Combine
import GenericsUIKit

protocol Router {
    func start(on navigationController: UINavigationController)
}

final class AppRouter: NSObject {

    enum State {
        case onboarding
        case main
        case splash
    }

    @Injected(\.authenticationRepository)
    private var authRepository

    @Injected(\.locationRepository)
    private var locationRepository

    private let navigationController = UINavigationController()
    private var appState = State.splash
    private var cancellable = Set<AnyCancellable>()
    private var childRouter: Router? {
        didSet {
            childRouter?.start(on: navigationController)
        }
    }

    func start() -> UIViewController {
        navigationController.delegate = self
        navigationController.setViewControllers([SplashViewController()], animated: true)
        Task {
            await checkAppState()
        }

        return navigationController
    }

    private func checkAppState() async {
        authRepository
            .statePublisher
            .sink { state in
                switch state {
                case .unknown:
                    self.setSplashScreen()
                case .loggedIn:
                    if self.locationRepository.state == .ready {
                        self.setMainRouter()
                    } else {
                        fallthrough
                    }
                case .loggedOut:
                    self.setOnboardingRouter()
                }
            }
            .store(in: &cancellable)

        locationRepository
            .statePublisher
            .sink { state in
                switch state {
                case .unknown:
                    self.setSplashScreen()
                case .needLocationWhenInUse, .needPrecision, .needLocationAlways:
                    self.setOnboardingRouter()
                case .ready:
                    if self.authRepository.state == .loggedIn {
                        self.setMainRouter()
                    } else {
                        self.setOnboardingRouter()
                    }
                }
            }
            .store(in: &cancellable)
    }

    private func setSplashScreen() {
        if navigationController.topViewController is SplashViewController {
            return
        }
        navigationController.setViewControllers([SplashViewController()], animated: true)
        childRouter = nil
    }

    private func setMainRouter() {
        if childRouter is MainRouter {
            return
        }
        childRouter = MainRouter()
    }

    private func setOnboardingRouter() {
        if childRouter is OnboardingRouter {
            return
        }
        childRouter = OnboardingRouter()
    }
}

extension AppRouter: UINavigationControllerDelegate {

    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if toVC is CustomInTransitinable && fromVC is CustomOutTransitinable {
            return CustomInOutTransitinableController()
        } else if toVC is CustomInTransitinable {
            return CustomInTransitinableController()
        } else {
            return nil
        }
    }
}
