//
//  MyPageCollectionViewHeader.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/21.
//

import UIKit

final class MyPageCollectionViewHeader: UICollectionViewCell {
    
    // MARK: - UI Elements
    private let profileImage: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UPlusColor.pointCirclePink.withAlphaComponent(0.5)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let shareNftButton: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.setTitle("NFT 자랑하기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UPlusColor.pointGagePink
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "username"
        label.textColor = .black
        label.font = .systemFont(ofSize: UPlusFont.main, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let levelLabel: UILabel = {
        let label = UILabel()
        label.text = "Lv.1"
        label.textColor = UPlusColor.pointGagePink
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let infoButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: SFSymbol.infoFill)?.withTintColor(.systemGray, renderingMode: .alwaysOriginal), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let userMissionDataView: UserMissionDataView = {
        let view = UserMissionDataView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setUI()
        self.setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension MyPageCollectionViewHeader {
    
    private func setUI() {
        self.contentView.addSubviews(profileImage,
                                     shareNftButton,
                                     usernameLabel,
                                     levelLabel,
                                     infoButton,
                                     userMissionDataView)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.profileImage.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 3),
            self.profileImage.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 3),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.profileImage.trailingAnchor, multiplier: 3),
            self.profileImage.heightAnchor.constraint(equalTo: self.profileImage.widthAnchor),
            
            self.shareNftButton.topAnchor.constraint(equalToSystemSpacingBelow: self.profileImage.bottomAnchor, multiplier: 2),
            self.shareNftButton.leadingAnchor.constraint(equalToSystemSpacingAfter: self.profileImage.leadingAnchor, multiplier: 3),
            self.profileImage.trailingAnchor.constraint(equalToSystemSpacingAfter: self.shareNftButton.trailingAnchor, multiplier: 3),
            
            self.usernameLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.shareNftButton.bottomAnchor, multiplier: 2),
            self.usernameLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 2),
            self.levelLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.usernameLabel.trailingAnchor, multiplier: 1),
            self.levelLabel.bottomAnchor.constraint(equalTo: self.usernameLabel.bottomAnchor),
            
            self.infoButton.centerYAnchor.constraint(equalTo: self.usernameLabel.centerYAnchor),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.infoButton.trailingAnchor, multiplier: 2),
            
            self.userMissionDataView.topAnchor.constraint(equalToSystemSpacingBelow: self.usernameLabel.bottomAnchor, multiplier: 2),
            self.userMissionDataView.leadingAnchor.constraint(equalTo: self.usernameLabel.leadingAnchor),
            self.userMissionDataView.trailingAnchor.constraint(equalTo: self.infoButton.trailingAnchor),
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.userMissionDataView.bottomAnchor, multiplier: 5)
        ])
    }
    
}
