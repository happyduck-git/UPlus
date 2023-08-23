//
//  WeeklyCompletedCollectionViewCell.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/23.
//

import UIKit

final class WeeklyCompletedCollectionViewCell: UICollectionViewCell {
    
    // MARK: - UI Elements
    private let iconImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: ImageAsset.hand)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let missionTitle: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: UPlusFont.h5, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let missionDescription: UILabel = {
        let label = UILabel()
        label.textColor = UPlusColor.blue04
        label.text = "미션 완료 시 description..."
        label.font = .systemFont(ofSize: UPlusFont.body2, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let pointContainerView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 10.0
        view.backgroundColor = UPlusColor.gray04
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let pointLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = MissionConstants.missionTerminated
        label.textColor = UPlusColor.gray06
        label.font = .systemFont(ofSize: UPlusFont.body2, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
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
extension WeeklyCompletedCollectionViewCell {
    func configure(title: String) {
        self.missionTitle.text = title
    }
    
    func resetCell() {
        self.missionTitle.text = nil
        self.missionDescription.text = nil
        self.pointLabel.text = nil
    }
}

// MARK: - Set UI & Layout
extension WeeklyCompletedCollectionViewCell {
    private func setUI() {
        self.contentView.addSubviews(self.missionTitle,
                                     self.missionDescription,
                                     self.iconImage,
                                     self.pointContainerView)
        
        self.pointContainerView.addSubview(self.pointLabel)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.iconImage.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 2),
            self.iconImage.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            
            self.missionTitle.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 2),
            self.missionTitle.leadingAnchor.constraint(equalToSystemSpacingAfter: self.iconImage.trailingAnchor, multiplier: 2),
            self.pointContainerView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.missionTitle.trailingAnchor, multiplier: 1),
            
            self.missionDescription.topAnchor.constraint(equalToSystemSpacingBelow: self.missionTitle.bottomAnchor, multiplier: 1),
            self.missionDescription.leadingAnchor.constraint(equalTo: self.missionTitle.leadingAnchor),
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.missionDescription.bottomAnchor, multiplier: 2),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.missionDescription.trailingAnchor, multiplier: 2),
            
            self.pointContainerView.topAnchor.constraint(equalTo: self.missionTitle.topAnchor),
            self.pointContainerView.widthAnchor.constraint(equalToConstant: 52),
            self.pointContainerView.bottomAnchor.constraint(equalTo: self.missionTitle.bottomAnchor),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.pointContainerView.trailingAnchor, multiplier: 1)
        ])
        
        NSLayoutConstraint.activate([
            self.pointLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.pointContainerView.topAnchor, multiplier: 1),
            self.pointLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.pointContainerView.leadingAnchor, multiplier: 1),
            self.pointContainerView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.pointLabel.trailingAnchor, multiplier: 1),
            self.pointContainerView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.pointLabel.bottomAnchor, multiplier: 1)
        ])
    }
}
