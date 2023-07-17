//
//  MissionMainViewController.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/17.
//

import UIKit

class MissionMainViewController: UIViewController {

    private lazy var slideInTransitioningDelegate = SideMenuPresentationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationItem()
        view.backgroundColor = .white
    }

}

extension MissionMainViewController {
    
    private func setNavigationItem() {
        let menuItem = UIBarButtonItem(image: UIImage(systemName: "list.bullet"),
                        style: .plain,
                        target: self,
                        action: #selector(openSideMenu))
        
        navigationItem.setLeftBarButton(menuItem, animated: true)
        navigationItem.ti
    }
    
    @objc func openSideMenu() {
        slideInTransitioningDelegate.direction = .left
        let sideMenuVC = SideMenuViewController()
        sideMenuVC.transitioningDelegate = slideInTransitioningDelegate
        sideMenuVC.modalPresentationStyle = .custom
        self.navigationController?.present(sideMenuVC, animated: true)
    }
}
