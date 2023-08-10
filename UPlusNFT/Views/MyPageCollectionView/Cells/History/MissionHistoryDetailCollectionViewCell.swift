//
//  MissionHistoryCollectionViewCell.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/08/10.
//

import UIKit

final class MissionHistoryDetailCollectionViewCell: UICollectionViewCell {
    
    //TODO: Mission type에 따라서 cell design 다르게 적용.
    
    private let missionTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .black
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
    func configure(title: String) {
        self.missionTitleLabel.text = "\(title)"
    }
}

extension MissionHistoryDetailCollectionViewCell {
    
    private func setUI() {
        self.contentView.addSubviews(self.missionTitleLabel)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.missionTitleLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 1),
            self.missionTitleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 1),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.missionTitleLabel.trailingAnchor, multiplier: 1),
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.missionTitleLabel.bottomAnchor, multiplier: 1)
            ]
        )
    }
}
 
