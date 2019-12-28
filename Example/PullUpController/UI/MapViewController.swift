//
//  MapViewController.swift
//  PullUpControllerDemo
//
//  Created by Mario on 03/11/2017.
//  Copyright © 2017 Mario. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var widthSlider: UISlider!
    @IBOutlet private weak var initialStateSegmentedControl: UISegmentedControl!
    @IBOutlet weak var animateShowSwitch: UISwitch!
    @IBOutlet weak var animateHideSwitch: UISwitch!

    @IBOutlet private weak var sizeSliderView: UIView! {
        didSet {
            sizeSliderView.layer.cornerRadius = 10
        }
    }

    private var originalPullUpControllerViewSize: CGSize = .zero

    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addPullUpController(animated: animateShowSwitch.isOn)
    }

    // MARK: - Actions
    @IBAction private func addButtonTapped() {
        guard children.first(where: { $0 is SearchViewController }) == nil else { return }
        addPullUpController(animated: animateShowSwitch.isOn)
    }

    @IBAction private func removeButtonTapped() {
        let pullUpController = makeSearchViewControllerIfNeeded()
        removePullUpController(pullUpController, animated: animateHideSwitch.isOn)
    }

    @IBAction private func widthSliderValueChanged(_ sender: UISlider) {
        let width = originalPullUpControllerViewSize.width * CGFloat(sender.value)

        let pullUpController = makeSearchViewControllerIfNeeded()
        pullUpController.portraitSize = CGSize(width: width, height: pullUpController.portraitSize.height)

        pullUpController.landscapeFrame = CGRect(
            origin: pullUpController.landscapeFrame.origin,
            size: CGSize(width: width, height: pullUpController.landscapeFrame.height)
        )

        pullUpController.updatePreferredFrameIfNeeded(animated: true)
    }

    // MARK: - Private Methods
    private func makeSearchViewControllerIfNeeded() -> SearchViewController {
        let currentPullUpController = children
            .filter({ $0 is SearchViewController })
            .first as? SearchViewController

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newController = storyboard
            .instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController

        let pullUpController = currentPullUpController ?? newController

        if initialStateSegmentedControl.selectedSegmentIndex == 0 {
            pullUpController.initialState = .contracted
        } else {
            pullUpController.initialState = .expanded
        }

        if originalPullUpControllerViewSize == .zero {
            originalPullUpControllerViewSize = pullUpController.view.bounds.size
        }

        return pullUpController
    }

    private func addPullUpController(animated: Bool) {
        let pullUpController = makeSearchViewControllerIfNeeded()
        _ = pullUpController.view

        addPullUpController(pullUpController,
                            initialStickyPointOffset: pullUpController.initialPointOffset,
                            animated: animated)
    }

    // MARK: - Public Methods
    func zoom(to location: CLLocationCoordinate2D) {
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
    }
}
