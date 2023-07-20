//
//  WelcomeBottomSheetViewController.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/07/19.
//

import UIKit

class WelcomeBottomSheetViewController: BottomSheetViewController {
    
    //MARK: - UI Elements
    private let greetingsLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.text = "서태호 홀더,\nsotitch 님만을 위한 특별 혜택"
        label.font = .systemFont(ofSize: UPlusFont.head5, weight: .heavy)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .systemGray2
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let levelLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "LEVEL 2 승급"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: UPlusFont.head2, weight: .heavy)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let benefitContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray3
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let benefitLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.textAlignment = .center
        label.text = "+ 추가 보상"
        label.font = .systemFont(ofSize: UPlusFont.subTitle2, weight: .heavy)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let benefitTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.text = "갓생 미션 1일 PASS권"
        label.font = .systemFont(ofSize: UPlusFont.head2, weight: .heavy)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var levelUpButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .black
        button.clipsToBounds = true
        button.setTitleColor(.white, for: .normal)
        button.setTitle(MissionConstants.levelUp, for: .normal)
        button.addTarget(self, action: #selector(levelUpDidTap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUI()
        self.setLayout()
        
    }
    
}

extension WelcomeBottomSheetViewController {
    
    private func setUI() {
        self.containerView.addSubviews(greetingsLabel,
                                       nftImageView,
                                       levelLabel,
                                       benefitContainerView,
                                       levelUpButton)
        
        self.benefitContainerView.addSubviews(benefitLabel,
                                              benefitTitleLabel)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.greetingsLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.containerView.topAnchor, multiplier: 8),
            self.greetingsLabel.centerXAnchor.constraint(equalTo: self.containerView.centerXAnchor),
            self.nftImageView.topAnchor.constraint(equalToSystemSpacingBelow: self.greetingsLabel.bottomAnchor, multiplier: 3),
            self.nftImageView.centerXAnchor.constraint(equalTo: self.containerView.centerXAnchor),
            self.nftImageView.widthAnchor.constraint(equalToConstant: 150),
            self.nftImageView.heightAnchor.constraint(equalToConstant: 150),
            self.levelLabel.topAnchor.constraint(equalToSystemSpacingBelow: nftImageView.bottomAnchor, multiplier: 2),
            self.levelLabel.centerXAnchor.constraint(equalTo: self.containerView.centerXAnchor),
            
            self.benefitContainerView.topAnchor.constraint(equalToSystemSpacingBelow: levelLabel.bottomAnchor, multiplier: 2),
            self.benefitContainerView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.containerView.leadingAnchor, multiplier: 2),
            self.containerView.trailingAnchor.constraint(equalToSystemSpacingAfter: benefitContainerView.trailingAnchor, multiplier: 2),
            
            self.benefitContainerView.heightAnchor.constraint(equalToConstant: 90),
            self.levelUpButton.topAnchor.constraint(equalToSystemSpacingBelow: self.benefitContainerView.bottomAnchor, multiplier: 3),
            self.levelUpButton.leadingAnchor.constraint(equalToSystemSpacingAfter: self.containerView.leadingAnchor, multiplier: 2),
            self.containerView.trailingAnchor.constraint(equalToSystemSpacingAfter:             self.levelUpButton.trailingAnchor, multiplier: 2),
            self.levelUpButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        NSLayoutConstraint.activate([
            self.benefitLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.benefitContainerView.topAnchor, multiplier: 2),
            self.benefitLabel.centerXAnchor.constraint(equalTo: self.benefitContainerView.centerXAnchor),
            self.benefitTitleLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.benefitLabel.bottomAnchor, multiplier: 1),
            self.benefitTitleLabel.centerXAnchor.constraint(equalTo: self.benefitContainerView.centerXAnchor),
            self.benefitContainerView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.benefitTitleLabel.bottomAnchor, multiplier: 2)
        ])
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.levelUpButton.layer.cornerRadius = self.levelUpButton.frame.height / 7
    }
}

extension WelcomeBottomSheetViewController {
    
    @objc private func levelUpDidTap() {
        
    }
    
}
