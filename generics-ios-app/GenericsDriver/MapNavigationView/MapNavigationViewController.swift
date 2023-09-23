//
//  MapNavigationViewController.swift
//  GenericsDriver
//
//  Created by Mike S. on 23/07/2023.
//

import UIKit
import MapKit
import Combine

final class MapNavigationViewController: UIViewController {

    enum ViewState {
        case offer(OfferViewModel)
    }

    private var mapView: MKMapView = {
        let view = MKMapView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // Temporary mock
    private var qrView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .purple
        return view
    }()

    private var sheetView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // Almost ready views, might get moved

    private var almostReadyLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var orderStickerView: OrderStickerView = {
        let view = OrderStickerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var backButton: UIButton = {
        let view = UIButton(configuration: .plain())
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // And everything else

    private var state: ViewState?

    func set(state: ViewState) {
        switch state {
        case .offer(let offerViewModel):
            setupBindning(to: offerViewModel)
        }
    }

    private var cancellable = Set<AnyCancellable>()

    func setupBindning(to viewModel: OfferViewModel) {
        viewModel.$routeToClient.sink { route in
            if let route {
                let padding: CGFloat = 8
                self.mapView.addOverlay(route)
                self.mapView.setVisibleMapRect(
                    self.mapView.visibleMapRect.union(
                        route.boundingMapRect
                    ),
                    edgePadding: UIEdgeInsets(
                        top: 0,
                        left: padding,
                        bottom: padding,
                        right: padding
                    ),
                    animated: true
                )
            }
        }
        .store(in: &cancellable)
        
        viewModel.$routeToRestaurant.sink { route in
            if let route {
                let padding: CGFloat = 8
                self.mapView.addOverlay(route)
                self.mapView.setVisibleMapRect(
                    self.mapView.visibleMapRect.union(
                        route.boundingMapRect
                    ),
                    edgePadding: UIEdgeInsets(
                        top: 0,
                        left: padding,
                        bottom: padding,
                        right: padding
                    ),
                    animated: true
                )
            }
        }
        .store(in: &cancellable)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()

        mapView.delegate = self
    }

    private lazy var sheetHiddenConstraint = view.bottomAnchor.constraint(equalTo: sheetView.topAnchor)
    private lazy var sheetShownConstraint = view.bottomAnchor.constraint(equalTo: sheetView.bottomAnchor)
    private lazy var sheetFullscreenConstraint = view.topAnchor.constraint(equalTo: sheetView.topAnchor)
    private lazy var mapConstraint = mapView.topAnchor.constraint(equalTo: view.bottomAnchor)
    private lazy var qrShownConstraint = qrView.topAnchor.constraint(equalTo: view.topAnchor)
    private lazy var qrHiddenConstraint = qrView.heightAnchor.constraint(equalToConstant: 0.0)

    private func setupView() {
        view.addSubview(mapView)

        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapConstraint,
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        setAcceptOrderView()
        sheetView.backgroundColor = .systemBackground

        view.addSubview(sheetView)
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: sheetView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: sheetView.trailingAnchor),
            sheetHiddenConstraint
        ])
    }

    private func showSheet(completion: (() -> Void)?) {
        sheetHiddenConstraint.isActive = false
        sheetFullscreenConstraint.isActive = false
        sheetShownConstraint.isActive = true
        UIView.animate(withDuration: transitionInDuration, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0) {
            self.view.layoutIfNeeded()
        } completion: { _ in
            completion?()
        }
    }

    private func hideSheet(completion: (() -> Void)?) {
        sheetShownConstraint.isActive = false
        sheetFullscreenConstraint.isActive = false
        sheetHiddenConstraint.isActive = true
        UIView.animate(withDuration: transitionInDuration, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0) {
            self.view.layoutIfNeeded()
        } completion: { _ in
            completion?()
        }
    }

    private func setNavigateToPickUpView() {
        sheetView.subviews.forEach { $0.removeFromSuperview() }
        let navigateTo = NavigateView()
        navigateTo.translatesAutoresizingMaskIntoConstraints = false
        sheetView.addSubview(navigateTo)
        NSLayoutConstraint.activate([
            navigateTo.leadingAnchor.constraint(equalTo: sheetView.leadingAnchor),
            navigateTo.trailingAnchor.constraint(equalTo: sheetView.trailingAnchor),
            navigateTo.topAnchor.constraint(equalTo: sheetView.topAnchor),
            navigateTo.bottomAnchor.constraint(equalTo: sheetView.safeAreaLayoutGuide.bottomAnchor)
        ])

        navigateTo.actionButton.addAction(.init(handler: { _ in
            self.hideSheet {
                self.setAlmostReadyView()
            }
        }), for: .touchUpInside)
    }

    private func setAcceptOrderView() {
        sheetView.subviews.forEach { $0.removeFromSuperview() }
        let acceptOrder = AcceptOrderView()
        acceptOrder.translatesAutoresizingMaskIntoConstraints = false
        sheetView.addSubview(acceptOrder)
        NSLayoutConstraint.activate([
            acceptOrder.leadingAnchor.constraint(equalTo: sheetView.leadingAnchor),
            acceptOrder.trailingAnchor.constraint(equalTo: sheetView.trailingAnchor),
            acceptOrder.topAnchor.constraint(equalTo: sheetView.topAnchor),
            acceptOrder.bottomAnchor.constraint(equalTo: sheetView.safeAreaLayoutGuide.bottomAnchor)
        ])

        acceptOrder.actionSlider.onAction = {
            self.hideSheet {
//                self.setNavigateToPickUpView()
//                self.view.layoutIfNeeded()
//                self.showSheet(completion: nil)

                guard case let .offer(viewModel) = self.state else {
                    fatalError("Weird state: accepting offer when not in offer state")
                }
                viewModel.acceptOffer()
            }
        }

        acceptOrder.declineButton.addAction(.init(handler: { _ in
            // self.navigationController?.popViewController(animated: true)

            guard case let .offer(viewModel) = self.state else {
                fatalError("Weird state: declining offer when not in offer state")
            }
            viewModel.acceptOffer()
        }), for: .touchUpInside)
    }

    private func setAlmostReadyView() {
        sheetView.subviews.forEach { $0.removeFromSuperview() }

        orderStickerView.nameLabel.text = "Peperoni pizze"
        orderStickerView.orderNumberLabel.text = "Order #1234567890"

        sheetView.addSubview(orderStickerView)
        sheetView.addSubview(almostReadyLabel)
        sheetView.addSubview(backButton)

        almostReadyLabel.text = "Almost ready! 5 mins left..."
        backButton.setTitle("Back", for: .normal)

        backButton.addAction(.init(handler: { _ in
            self.hideSheet {
                self.setNavigateToPickUpView()
                self.view.layoutIfNeeded()
                self.showSheet(completion: nil)
            }
        }), for: .touchUpInside)

        NSLayoutConstraint.activate([
            orderStickerView.centerXAnchor.constraint(equalTo: sheetView.centerXAnchor),
            orderStickerView.centerYAnchor.constraint(equalTo: sheetView.centerYAnchor),
            almostReadyLabel.centerXAnchor.constraint(equalTo: sheetView.centerXAnchor),
            almostReadyLabel.bottomAnchor.constraint(equalTo: orderStickerView.topAnchor, constant: -.big),
            orderStickerView.topAnchor.constraint(greaterThanOrEqualTo: sheetView.topAnchor),
            orderStickerView.bottomAnchor.constraint(lessThanOrEqualTo: sheetView.safeAreaLayoutGuide.bottomAnchor),
            backButton.centerXAnchor.constraint(equalTo: sheetView.centerXAnchor),
            backButton.bottomAnchor.constraint(equalTo: sheetView.safeAreaLayoutGuide.bottomAnchor)
        ])

        view.layoutIfNeeded()
        sheetHiddenConstraint.isActive = false
        sheetShownConstraint.isActive = true
        sheetFullscreenConstraint.isActive = true
        UIView.animate(withDuration: transitionInDuration, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0) {
            self.view.layoutIfNeeded()
        } completion: { _ in
            //completion?()
        }

        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(trigger))
        gestureRecognizer.addTarget(self, action: #selector(trigger))

        orderStickerView.addGestureRecognizer(gestureRecognizer)
    }

    @objc func trigger() {
        showQrView()
    }

    private func showQrView() {
        view.insertSubview(qrView, aboveSubview: mapView)
        NSLayoutConstraint.activate([
            qrView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            qrView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            qrShownConstraint,
            qrView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        self.view.layoutIfNeeded()
        sheetHiddenConstraint.isActive = false
        sheetFullscreenConstraint.isActive = false
        sheetShownConstraint.isActive = true
        UIView.animate(withDuration: transitionInDuration, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0) {
            self.view.layoutIfNeeded()
            self.backButton.layer.opacity = 0.0
            self.almostReadyLabel.layer.opacity = 0.0
        } completion: { _ in
            self.backButton.removeFromSuperview()
            self.almostReadyLabel.removeFromSuperview()
        }

        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(trigger))
        gestureRecognizer.addTarget(self, action: #selector(trigger2))

        qrView.addGestureRecognizer(gestureRecognizer)

    }

    @objc func trigger2() {
        sheetShownConstraint.isActive = false
        sheetFullscreenConstraint.isActive = false
        sheetHiddenConstraint.isActive = true
        qrShownConstraint.isActive = false
        qrHiddenConstraint.isActive = true
        UIView.animate(withDuration: transitionInDuration, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0) {
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.setNavigateToDeliveryView()
            self.qrView.removeFromSuperview()
            self.view.layoutIfNeeded()
            self.showSheet {

            }
        }
    }

    private func setNavigateToDeliveryView() {
        sheetView.subviews.forEach { $0.removeFromSuperview() }
        let navigateTo = NavigateView()
        navigateTo.translatesAutoresizingMaskIntoConstraints = false
        sheetView.addSubview(navigateTo)
        NSLayoutConstraint.activate([
            navigateTo.leadingAnchor.constraint(equalTo: sheetView.leadingAnchor),
            navigateTo.trailingAnchor.constraint(equalTo: sheetView.trailingAnchor),
            navigateTo.topAnchor.constraint(equalTo: sheetView.topAnchor),
            navigateTo.bottomAnchor.constraint(equalTo: sheetView.safeAreaLayoutGuide.bottomAnchor)
        ])

        navigateTo.actionButton.addAction(.init(handler: { _ in
            self.navigationController?.popViewController(animated: true)
        }), for: .touchUpInside)
    }
}

extension MapNavigationViewController: CustomInTransitinable {
    var transitionInDuration: TimeInterval {
        0.5
    }

    func transitionIn(completion: (() -> Void)?) {
        sheetHiddenConstraint.isActive = false
        sheetShownConstraint.isActive = true

        mapConstraint.isActive = false
        mapView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true

        UIView.animate(withDuration: transitionInDuration, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0) {
            self.view.layoutIfNeeded()
        } completion: { _ in
            completion?()
        }
    }
}

extension MapNavigationViewController: CustomOutTransitinable {
    var transitionOutDuration: TimeInterval {
        0.5
    }

    func transitionOut(completion: (() -> Void)?) {
        hideSheet {
            completion?()
        }
    }
}

extension MapNavigationViewController: MKMapViewDelegate {
    func mapView(
        _ mapView: MKMapView,
        rendererFor overlay: MKOverlay
      ) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)

        renderer.strokeColor = .systemBlue
        renderer.lineWidth = 3

        return renderer
      }
}
