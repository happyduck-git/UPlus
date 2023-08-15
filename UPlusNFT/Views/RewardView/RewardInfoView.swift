//
//  RewardInfoView.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/08/15.
//

import UIKit

final class RewardInfoView: UIView {

    private let image: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: ImageAsset.bellGray)
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()

    private let title: UILabel = {
        let label = UILabel()
        label.text = RewardsConstants.info
        label.textColor = UPlusColor.gray07
        label.font = .systemFont(ofSize: UPlusFont.h5, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let infoTitleStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let usageLabel: UILabel = {
        let label = UILabel()
        label.textColor = UPlusColor.gray05
        label.text = RewardsConstants.usage
        label.font = .systemFont(ofSize: UPlusFont.body2)
        return label
    }()
    
    private let periodLabel: UILabel = {
        let label = UILabel()
        label.textColor = UPlusColor.gray05
        label.text = RewardsConstants.period
        label.font = .systemFont(ofSize: UPlusFont.body2)
        return label
    }()
    
    private let descriptionStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let usageDetailLabel: UILabel = {
        let label = UILabel()
        label.textColor = UPlusColor.gray08
        label.text = RewardsConstants.empty
        label.font = .systemFont(ofSize: UPlusFont.body2)
        return label
    }()
    
    private let periodDetailLabel: UILabel = {
        let label = UILabel()
//        label.textColor = UPlusColor.gray08
        label.textColor = .systemRed
        label.text = RewardsConstants.empty
        label.font = .systemFont(ofSize: UPlusFont.body2)
        return label
    }()
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UPlusColor.grayBackground
        self.setUI()
        self.setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        NSLayoutConstraint.activate([
            self.infoTitleStack.heightAnchor.constraint(equalToConstant: self.frame.height / 2),
            self.descriptionStack.heightAnchor.constraint(equalToConstant: self.frame.height / 2),
            
            self.image.widthAnchor.constraint(equalToConstant: self.frame.height / 5),
            self.image.heightAnchor.constraint(equalTo: self.image.widthAnchor)
        ])
    }
}

//MARK: - Set UI & Layout
extension RewardInfoView {
 
    func configure(with data: Reward) {
        self.usageDetailLabel.text = data.rewardName ?? "no-reward-name"
        self.periodDetailLabel.text = "경품 사용 기간 명시 필요"
    }
    
}

//MARK: - Set UI & Layout
extension RewardInfoView {
    private func setUI() {

        self.infoTitleStack.addArrangedSubviews(self.usageLabel,
                                                self.periodLabel)
        
        self.descriptionStack.addArrangedSubviews(self.usageDetailLabel,
                                                  self.periodDetailLabel)
        
        self.addSubviews(self.image,
                         self.title,
                         self.infoTitleStack,
                         self.descriptionStack)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            
            self.image.leadingAnchor.constraint(equalToSystemSpacingAfter: self.leadingAnchor, multiplier: 2),
            self.image.centerYAnchor.constraint(equalTo: self.title.centerYAnchor),
            
            self.title.topAnchor.constraint(equalToSystemSpacingBelow: self.topAnchor, multiplier: 2),
            self.title.leadingAnchor.constraint(equalToSystemSpacingAfter: self.image.trailingAnchor, multiplier: 2),
            self.title.bottomAnchor.constraint(equalTo: self.infoTitleStack.topAnchor),
            
            self.infoTitleStack.leadingAnchor.constraint(equalTo: self.image.leadingAnchor),
            self.bottomAnchor.constraint(equalToSystemSpacingBelow: self.infoTitleStack.bottomAnchor, multiplier: 2),
            
            self.descriptionStack.leadingAnchor.constraint(equalToSystemSpacingAfter: self.infoTitleStack.trailingAnchor, multiplier: 3),
            self.descriptionStack.topAnchor.constraint(equalTo: self.infoTitleStack.topAnchor),
           
            self.descriptionStack.bottomAnchor.constraint(equalTo: self.infoTitleStack.bottomAnchor)
            
        ])
  
    }
}
