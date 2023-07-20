//
//  MissionCompleteViewController.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/20.
//

import UIKit

class MissionCompleteViewController: UIViewController {
    
    private let resultLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 40, weight: .bold)
        let attributedString = NSMutableAttributedString(string: MissionConstants.missionSuccess)
        attributedString.addAttributes([.font: UIFont.systemFont(ofSize: 82)], range: NSRange(location: 6, length: 2))
        label.attributedText = attributedString
        label.textAlignment = .center
        label.textColor = .black
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let missionCompleteIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .darkGray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let pointLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let confirmButton: UIButton = {
        let button = UIButton()
        button.setTitle(MissionConstants.confirm, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.setUI()
        self.setLayout()
    }
    
}

//MARK: - Configure with View Model
extension MissionCompleteViewController {
    func configure(with vm: DailyAttendanceMission) {
        self.pointLabel.text = String(describing: vm.missionRewardPoint) + MissionConstants.redeemPointSuffix
    }
}

//MARK: - Set UI & Layout
extension MissionCompleteViewController {
    private func setUI() {
        self.view.addSubviews(resultLabel,
                              missionCompleteIcon,
                              pointLabel,
                              confirmButton)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.resultLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.view.safeAreaLayoutGuide.topAnchor, multiplier: 3),
            self.resultLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.missionCompleteIcon.topAnchor.constraint(equalToSystemSpacingBelow: self.resultLabel.bottomAnchor, multiplier: 5),
            self.missionCompleteIcon.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.missionCompleteIcon.heightAnchor.constraint(equalToConstant: 100),
            self.missionCompleteIcon.widthAnchor.constraint(equalTo: self.missionCompleteIcon.heightAnchor),
            self.pointLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.missionCompleteIcon.bottomAnchor, multiplier: 3),
            self.pointLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            
            self.confirmButton.leadingAnchor.constraint(equalToSystemSpacingAfter: self.view.safeAreaLayoutGuide.leadingAnchor, multiplier: 3),
            self.confirmButton.heightAnchor.constraint(equalToConstant: self.view.frame.height / 15),
            self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: self.confirmButton.trailingAnchor, multiplier: 3),
            self.view.safeAreaLayoutGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: self.confirmButton.bottomAnchor, multiplier: 3)
        ])
    }
}
