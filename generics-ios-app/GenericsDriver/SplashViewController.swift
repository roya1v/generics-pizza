//
//  SplashViewController.swift
//  GenericsDriver
//
//  Created by Mike S. on 16/08/2023.
//

import UIKit
import Factory

final class SplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        Container.shared.mainRouter().showApp()
    }
}

extension SplashViewController: CustomOutTransitinable {
    var transitionOutDuration: TimeInterval {
        0.0
    }

    func transitionOut(completion: (() -> Void)?) {
        completion?()
    }
}
