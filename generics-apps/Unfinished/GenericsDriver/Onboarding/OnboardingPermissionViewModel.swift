//
//  OnboardingPermissionViewModel.swift
//  GenericsDriver
//
//  Created by Mike S. on 16/08/2023.
//

import Foundation
import Factory
import UIKit

final class OnboardingPermissionViewModel: ObservableObject {

    enum MainButtonState {
        case grantPermission
        case openSettings
    }

    @Published var mainButtonState: MainButtonState

    @Injected(\.locationRepository)
    private var repository

    init() {
        if Container.shared.locationRepository.callAsFunction().state == .needLocationWhenInUse {
            mainButtonState = .grantPermission
        } else {
            mainButtonState = .openSettings
        }

        repository
            .statePublisher
            .map {
                if $0 == .needLocationWhenInUse {
                    return .grantPermission
                } else {
                    return .openSettings
                }
            }
            .assign(to: &$mainButtonState)
    }

    func mainButtonPressed() {
        if repository.state == .needLocationWhenInUse {
            repository.requestPermission()
        } else {
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
        }
    }
}
