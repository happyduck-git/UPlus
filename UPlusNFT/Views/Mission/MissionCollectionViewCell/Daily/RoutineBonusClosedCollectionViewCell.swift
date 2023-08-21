//
//  RoutineBonusClosedCollectionViewCell.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/16.
//

import UIKit

final class RoutineBonusClosedCollectionViewCell: UICollectionViewCell {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = UPlusColor.mint04
        label.text = MissionConstants.bonusStage
        label.font = .systemFont(ofSize: UPlusFont.body1, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let subTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = UPlusColor.mint05
        label.text = MissionConstants.bonusStageInfo
        label.font = .systemFont(ofSize: UPlusFont.h2, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let lockImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: ImageAsset.padlock)?.withTintColor(UPlusColor.mint05, renderingMode: .alwaysOriginal)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setUI()
        self.setLayout()
        self.configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension RoutineBonusClosedCollectionViewCell {
    private func setUI() {
        self.contentView.addSubviews(self.titleLabel,
                                     self.subTitleLabel,
                                     self.lockImage)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 5),
            self.titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 2),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.titleLabel.trailingAnchor, multiplier: 2),
            self.subTitleLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.titleLabel.bottomAnchor, multiplier: 1),
            self.subTitleLabel.leadingAnchor.constraint(equalTo: self.titleLabel.leadingAnchor),
            self.subTitleLabel.trailingAnchor.constraint(equalTo: self.titleLabel.trailingAnchor),
            self.lockImage.topAnchor.constraint(equalToSystemSpacingBelow: self.subTitleLabel.bottomAnchor, multiplier: 2),
            self.lockImage.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor)
        ])
    }
}

extension RoutineBonusClosedCollectionViewCell {
    private func configure() {
        self.contentView.backgroundColor = UPlusColor.mint01
        self.contentView.layer.borderColor = UPlusColor.mint03.cgColor
        self.contentView.layer.borderWidth = 2.0
        self.contentView.clipsToBounds = true
        self.contentView.layer.cornerRadius = 16
    }
}
