//
//  CampainPostViewController.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/07/03.
//

import UIKit

final class CampaignPostViewController: UIViewController {
    
    //MARK: - Property
    private let campaignView: CampaignView = {
        let view = CampaignView()
        view.markJoin(.joined)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        setLayout()
    }
 
    //MARK: - Set UI & Layout
    private func setUI() {
        view.addSubview(campaignView)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            campaignView.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 2),
            campaignView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 1),
            view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: campaignView.trailingAnchor, multiplier: 1),
            campaignView.heightAnchor.constraint(equalToConstant: view.frame.height / 4)
        ])
    }
    
}
