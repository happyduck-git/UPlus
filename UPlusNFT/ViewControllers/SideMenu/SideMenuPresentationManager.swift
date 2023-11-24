//
//  SideMenuPresentationManager.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/17.
//

import UIKit

final class SideMenuPresentationManager: NSObject {
    var direction: PresentationDirection = .left
}

extension SideMenuPresentationManager: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        let presentationController = MissionSideMenuPresentationController(
            presentedViewController: presented,
            presenting: presenting,
            direction: direction
        )
        
        return presentationController
    }
    
    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SideMenuPresentAnimator(direction: direction,
                                       isPresentation: true)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return SideMenuPresentAnimator(direction: direction,
                                isPresentation: false)
    }
}
