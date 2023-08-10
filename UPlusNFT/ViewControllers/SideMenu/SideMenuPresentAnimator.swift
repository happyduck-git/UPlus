//
//  SideMenuPresentAnimator.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/17.
//

import UIKit


/// Custom Animatior.
final class SideMenuPresentAnimator: NSObject {
    let direction: PresentationDirection
    
    let isPresentation: Bool
    
    init(direction: PresentationDirection, isPresentation: Bool) {
        self.direction = direction
        self.isPresentation = isPresentation
    }
}

extension SideMenuPresentAnimator: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(
        using transitionContext: UIViewControllerContextTransitioning) {

      let key: UITransitionContextViewControllerKey = isPresentation ? .to : .from

      guard let controller = transitionContext.viewController(forKey: key)
        else { return }
        

      if isPresentation {
        transitionContext.containerView.addSubview(controller.view)
      }

      let presentedFrame = transitionContext.finalFrame(for: controller)
      var dismissedFrame = presentedFrame
      switch direction {
      case .left:
        dismissedFrame.origin.x = -presentedFrame.width
      case .bottom:
        dismissedFrame.origin.y = transitionContext.containerView.frame.size.height
      }
        
      let initialFrame = isPresentation ? dismissedFrame : presentedFrame
      let finalFrame = isPresentation ? presentedFrame : dismissedFrame
        
      let animationDuration = transitionDuration(using: transitionContext)
      controller.view.frame = initialFrame
      UIView.animate(
        withDuration: animationDuration,
        animations: {
          controller.view.frame = finalFrame
      }, completion: { finished in
        if !self.isPresentation {
          controller.view.removeFromSuperview()
        }
        transitionContext.completeTransition(finished)
      })
    }

}
