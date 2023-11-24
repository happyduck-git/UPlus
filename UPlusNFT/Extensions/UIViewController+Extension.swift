//
//  UIViewController+Extension.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/06/22.
//

import UIKit

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension UIViewController {
    
    /// Extention: Add a view controller as a child to view controller.
    /// - Parameter child: A view controller to be its child view controller.
    func addChildViewController(_ child: UIViewController) {
        self.addChild(child)
        self.view.addSubview(child.view)
        child.didMove(toParent: self)
    }
    
    /// Extension: Remove a view controller from its parent view controller.
    func removeViewController() {
        guard parent != nil else {
            return
        }
        
        self.willMove(toParent: nil)
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
}
