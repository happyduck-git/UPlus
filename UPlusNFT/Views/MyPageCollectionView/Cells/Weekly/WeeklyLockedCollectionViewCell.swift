//
//  WeeklyLockedCollectionViewCell.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/23.
//

import UIKit

final class WeeklyLockedCollectionViewCell: UICollectionViewCell {
    
    
    // MARK: - UI Elements
    private let iconImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: ImageAsset.lock)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .leading
        stack.distribution = .fillProportionally
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let missionTitle: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = UPlusColor.gray05
        label.font = .systemFont(ofSize: UPlusFont.h5, weight: .bold)
        return label
    }()
    
    private let openDateLabel: UILabel = {
        let label = UILabel()
        label.textColor = UPlusColor.gray05
        label.font = .systemFont(ofSize: UPlusFont.body2, weight: .regular)
        return label
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.backgroundColor = UPlusColor.gray02
        self.contentView.clipsToBounds = true
        self.contentView.layer.cornerRadius = 16
        
        self.setUI()
        self.setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        
    }
    
}

// MARK: - Configure
extension WeeklyLockedCollectionViewCell {
    
    func configure(title: String,
                   openDate: String) {
        
        self.missionTitle.text = title
        self.openDateLabel.text = openDate
   
    }
    
}

// MARK: - Set UI & Layout
extension WeeklyLockedCollectionViewCell {
    private func setUI() {
        self.titleStack.addArrangedSubviews(self.missionTitle,
                                            self.openDateLabel)
        
        self.contentView.addSubviews(self.iconImage,
                                     self.titleStack)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.iconImage.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 2),
            self.iconImage.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            
            self.titleStack.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 2),
            self.titleStack.leadingAnchor.constraint(equalToSystemSpacingAfter: self.iconImage.trailingAnchor, multiplier: 2),
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.titleStack.bottomAnchor, multiplier: 2),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.titleStack.trailingAnchor, multiplier: 2)
        ])

    }
}
