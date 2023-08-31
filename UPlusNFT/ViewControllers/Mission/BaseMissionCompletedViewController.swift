//
//  BaseMissionCompletedViewController.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/17.
//

import UIKit

protocol BaseMissionCompletedViewControllerDelegate: AnyObject {
    func redeemDidTap()
}

class BaseMissionCompletedViewController: UIViewController {

    //MARK: - Delegate
    weak var delegate: BaseMissionCompletedViewControllerDelegate?
    
    // MARK: - UI Elements
    let loadingVC = LoadingViewController()
    
    let backgroundConfetti: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: ImageAsset.confettiBackground)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let resultLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: UPlusFont.mainFont, size: UPlusFont.missionTitle)
        label.text = MissionConstants.questCompleted
        label.textAlignment = .center
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let missionCompleteIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: ImageAsset.pointBig)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let shadowIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: ImageAsset.pointShadow)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var confirmButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(UPlusColor.gray08, for: .normal)
        button.backgroundColor = UPlusColor.mint03
        button.titleLabel?.font = .systemFont(ofSize: UPlusFont.body1, weight: .bold)
        button.clipsToBounds = true
        button.layer.cornerRadius = 8.0
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setUI()
        self.setLayout()
        self.setNavigationBar()
    }

}

// MARK: - Set UI & Layout
extension BaseMissionCompletedViewController {
    private func setUI() {
        self.view.addSubviews(self.backgroundConfetti,
                              self.resultLabel,
                              self.missionCompleteIcon,
                              self.shadowIcon,
                              self.confirmButton)
    }
    
    private func setLayout() {
        self.backgroundConfetti.frame = view.bounds
        
        NSLayoutConstraint.activate([
            self.resultLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.view.safeAreaLayoutGuide.topAnchor, multiplier: 10),
            self.resultLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            
            self.missionCompleteIcon.topAnchor.constraint(equalToSystemSpacingBelow: self.resultLabel.bottomAnchor, multiplier: 5),
            self.missionCompleteIcon.leadingAnchor.constraint(equalToSystemSpacingAfter: self.view.safeAreaLayoutGuide.leadingAnchor, multiplier: 10),
            self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: self.missionCompleteIcon.trailingAnchor, multiplier: 10),
            
            self.shadowIcon.topAnchor.constraint(equalTo: self.missionCompleteIcon.bottomAnchor),
            self.shadowIcon.leadingAnchor.constraint(equalToSystemSpacingAfter: self.view.safeAreaLayoutGuide.leadingAnchor, multiplier: 2),
            self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: self.shadowIcon.trailingAnchor, multiplier: 2),
            
            self.confirmButton.topAnchor.constraint(equalToSystemSpacingBelow: self.shadowIcon.bottomAnchor, multiplier: 5),
            self.confirmButton.leadingAnchor.constraint(equalToSystemSpacingAfter: self.view.safeAreaLayoutGuide.leadingAnchor, multiplier: 3),
            self.confirmButton.heightAnchor.constraint(equalToConstant: LoginConstants.buttonHeight),
            self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: self.confirmButton.trailingAnchor, multiplier: 3),
            self.view.safeAreaLayoutGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: self.confirmButton.bottomAnchor, multiplier: 3)
        ])
        self.resultLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
    
    private func setNavigationBar() {
        self.navigationItem.hidesBackButton = true
    }
}
#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct BaseMissionCompletedViewController_Preview: PreviewProvider {
    static var previews: some View {
        
        BaseMissionCompletedViewController().toPreview()
    }
}
#endif
