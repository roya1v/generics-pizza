//
//  CustomInOutTransitinableController.swift
//  GenericsDriver
//
//  Created by Mike S. on 31/07/2023.
//

import UIKit

// This this the best way thought?

protocol CustomOutTransitinable: UIViewController {
    var transitionOutDuration: TimeInterval { get }
    func transitionOut(completion: (() -> Void)?)
}

protocol CustomInTransitinable: UIViewController {
    var transitionInDuration: TimeInterval { get }
    func transitionIn(completion: (() -> Void)?)
}

final class CustomInOutTransitinableController: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        guard let fromVC = transitionContext?.viewController(forKey: .from) as? CustomOutTransitinable,
              let toVC = transitionContext?.viewController(forKey: .to) as? CustomInTransitinable else {
            fatalError("'CustomInOutTransitinableController' should be only used with appropriate 'to' and 'from' VCs")
        }
        return fromVC.transitionOutDuration + toVC.transitionInDuration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from) as? CustomOutTransitinable,
              let toVC = transitionContext.viewController(forKey: .to) as? CustomInTransitinable else {
            fatalError("'CustomInOutTransitinableController' should be only used with appropriate 'to' and 'from' VCs")
        }
        let containerView = transitionContext.containerView

        fromVC.transitionOut {
            containerView.addSubview(toVC.view)
            containerView.layoutIfNeeded()
            toVC.transitionIn {
                transitionContext.completeTransition(true)
            }
        }
    }
}
