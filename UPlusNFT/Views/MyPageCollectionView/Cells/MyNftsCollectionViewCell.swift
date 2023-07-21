//
//  MyNftsCollectionViewCell.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/21.
//

import UIKit

final class MyNftsCollectionViewCell: UICollectionViewCell {
    
    private let nftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UPlusColor.pointCirclePink
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let goToMissionButton: UIButton = {
        let button = UIButton()
        button.setTitle(MyPageConstants.goToMission, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UPlusColor.pointGagePink
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.backgroundColor = .systemBlue
        self.setUI()
        self.setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension MyNftsCollectionViewCell {
    private func setUI() {
        self.contentView.addSubviews(nftImageView,
                                     goToMissionButton)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.nftImageView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.nftImageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.nftImageView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.nftImageView.heightAnchor.constraint(equalToConstant: self.contentView.frame.height * (2/3)),
            
            self.goToMissionButton.topAnchor.constraint(equalToSystemSpacingBelow: self.nftImageView.bottomAnchor, multiplier: 2),
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.goToMissionButton.bottomAnchor, multiplier: 2),
            self.goToMissionButton.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 2),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.goToMissionButton.trailingAnchor, multiplier: 2)
        ])
    }
}
