//
//  MissionSideMenuPresentationController.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/17.
//

import UIKit

enum PresentationDirection {
    case left
    case bottom
}

final class MissionSideMenuPresentationController: UIPresentationController {

    private var dimmigView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        view.alpha = 0.0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var direction: PresentationDirection
    
    init(presentedViewController: UIViewController,
         presenting presentingViewController: UIViewController?,
         direction: PresentationDirection) {
        self.direction = direction
        
        super.init(presentedViewController: presentedViewController,
                   presenting: presentingViewController)
        
        self.addTapGesture()
    }
    
}

extension MissionSideMenuPresentationController {
    override func presentationTransitionWillBegin() {
        guard let containerView = containerView else { return }
        containerView.insertSubview(dimmigView, at: 0)
        
        NSLayoutConstraint.activate([
            dimmigView.topAnchor.constraint(equalTo: containerView.topAnchor),
            dimmigView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            dimmigView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            dimmigView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmigView.alpha = 1.0
            return
        }
        
        coordinator.animate { [weak self] _ in
            self?.dimmigView.alpha = 1.0
        }
    }
    
    override func dismissalTransitionWillBegin() {
        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmigView.alpha = 0.0
            return
        }
        
        coordinator.animate { [weak self] _ in
            self?.dimmigView.alpha = 0.0
        }
    }
    
    override func containerViewWillLayoutSubviews() {
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
    
    override func size(forChildContentContainer container: UIContentContainer,
                       withParentContainerSize parentSize: CGSize) -> CGSize {
        switch direction {
        case .left:
            return CGSize(width: parentSize.width*(2/3),
                          height: parentSize.height)
        case .bottom:
            return CGSize(width: parentSize.width,
                          height: parentSize.height*(2/3))
        }
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        var frame: CGRect = .zero
        if let containerView = containerView {
            frame.size = size(forChildContentContainer: presentedViewController,
                              withParentContainerSize: containerView.bounds.size)
            
            switch direction {
            case .left:
                frame.origin.x = .zero
            case .bottom:
                frame.origin.y = containerView.frame.height*(1/3)
            }
            return frame
        }
        return frame
    }
}

// MARK: - Tap Gesture Handler
extension MissionSideMenuPresentationController {
    
    private func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        dimmigView.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap(recognizer: UITapGestureRecognizer) {
        presentingViewController.dismiss(animated: true)
    }
    
}
