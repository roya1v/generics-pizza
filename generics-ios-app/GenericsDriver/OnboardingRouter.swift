//
//  OnboardingRouter.swift
//  GenericsHelpers
//
//  Created by Mike S. on 23/09/2023.
//

import UIKit
import Factory

final class OnboardingRouter: Router {

    @Injected(\.authenticationRepository)
    var authRepository

    @Injected(\.locationRepository)
    var locationRepository

    func start(on navigationController: UINavigationController) {
        if authRepository.state == .loggedIn {
            if locationRepository.state != .ready {
                let vc = OnboardingPermissionViewController()
                navigationController.setViewControllers([vc], animated: true)
                vc.transitionIn(completion: nil) // Shitty solution but for some reason the nav vc delegate method isn't called
            }
        } else {
            let vc = LoginViewController()
            navigationController.setViewControllers([vc], animated: true)
        }
    }
}
