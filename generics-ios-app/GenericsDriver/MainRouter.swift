//
//  MainRouter.swift
//  GenericsDriver
//
//  Created by Mike S. on 16/08/2023.
//

import UIKit
import Factory
import Combine

final class MainRouter: NSObject {

    private let navigationController = UINavigationController()

    @Injected(Container.authenticationRepository)
    var authRepository

    private var cancellable = Set<AnyCancellable>()

    override init() {
        super.init()

        navigationController.delegate = self
    }

    func start() -> UIViewController {
        authRepository
            .state
            .receive(on: DispatchQueue.main)
            .sink { state in
                switch state {
                case .loggedOut:
                    self.navigationController.setViewControllers([LoginViewController()], animated: false)
                case .loggedIn:
                    self.navigationController.setViewControllers([OnboardingPermissionViewController()], animated: false)
                }
            }
            .store(in: &cancellable)
        authRepository.reload()

        return navigationController
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
