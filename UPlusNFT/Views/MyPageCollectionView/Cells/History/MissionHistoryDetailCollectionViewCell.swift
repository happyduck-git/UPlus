//
//  MissionHistoryCollectionViewCell.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/08/10.
//

import UIKit

final class MissionHistoryDetailCollectionViewCell: UICollectionViewCell {
    
    private let missionImage: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: ImageAsset.routineImage)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let missionTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = UPlusColor.gray08
        label.font = .systemFont(ofSize: UPlusFont.h5, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let pointLabel: UILabel = {
        let label = UILabel()
        label.textColor = UPlusColor.blue03
        label.font = .systemFont(ofSize: UPlusFont.body2, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setUI()
        self.setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension MissionHistoryDetailCollectionViewCell {
    func configure(title: String, point: Int64) {
        self.missionTitleLabel.text = "\(title)"
        self.pointLabel.text = String(format: MyPageConstants.missionPoint, point)
    }
}

extension MissionHistoryDetailCollectionViewCell {
    
    private func setUI() {
        self.contentView.addSubviews(self.missionImage,
                                     self.missionTitleLabel,
                                     self.pointLabel)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.missionImage.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 1),
            self.missionImage.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 2),
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.missionImage.bottomAnchor, multiplier: 1),
            
            self.missionTitleLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            self.missionTitleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.missionImage.trailingAnchor, multiplier: 2),
            
            self.pointLabel.topAnchor.constraint(equalTo: self.missionImage.topAnchor),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.pointLabel.trailingAnchor, multiplier: 2)
            ]
        )
    }
}
 
