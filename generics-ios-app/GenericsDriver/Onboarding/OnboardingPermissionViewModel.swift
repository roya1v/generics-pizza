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

    @Injected(Container.locationRepository)
    private var repository

    init() {
        if Container.locationRepository.callAsFunction().currentState == .needLocationWhenInUse {
            mainButtonState = .grantPermission
        } else {
            mainButtonState = .openSettings
        }

        repository.state.map { if $0 == .needLocationWhenInUse { return MainButtonState.grantPermission} else { return MainButtonState.openSettings}}.assign(to: &$mainButtonState)
    }

    func mainButtonPressed() {
        if repository.currentState == .needLocationWhenInUse {
            repository.requestPermission()
        } else {
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
        }
    }
}
