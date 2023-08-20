//
//  RightArrowButton.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/08/19.
//

import UIKit

final class RightArrowButton: UIButton {
    
    private let title: UILabel = {
        let label = UILabel()
        label.text = WalletConstants.ownedReward
        label.textColor = UPlusColor.gray08
        label.font = .systemFont(ofSize: UPlusFont.body1, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subTitle: UILabel = {
        let label = UILabel()
        label.textColor = UPlusColor.gray05
        label.font = .systemFont(ofSize: UPlusFont.body2, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let buttonImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: ImageAsset.arrowRight)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UPlusColor.grayBackground
        
        self.setUI()
        self.setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension RightArrowButton {
    
    func setSubTitle(_ text: String) {
        self.subTitle.text = String(format: WalletConstants.rewardsUnit, text)
    }

}

//MARK: - Set UI & Layout
extension RightArrowButton {
    
    private func setUI() {
        self.addSubviews(self.title,
                         self.subTitle,
                         self.buttonImage)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.title.topAnchor.constraint(equalToSystemSpacingBelow: self.topAnchor, multiplier: 1),
            self.title.leadingAnchor.constraint(equalToSystemSpacingAfter: self.leadingAnchor, multiplier: 3),
            self.bottomAnchor.constraint(equalToSystemSpacingBelow: self.title.bottomAnchor, multiplier: 1),
            
            self.subTitle.topAnchor.constraint(equalTo: self.title.topAnchor),
            self.subTitle.leadingAnchor.constraint(equalToSystemSpacingAfter: self.title.trailingAnchor, multiplier: 2),
            self.subTitle.bottomAnchor.constraint(equalTo: self.title.bottomAnchor),
            
            self.buttonImage.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.trailingAnchor.constraint(equalToSystemSpacingAfter: self.buttonImage.trailingAnchor, multiplier: 3)
        ])
    }
    
}
