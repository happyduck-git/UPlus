//
//  WeeklyMissionCollectionViewCell.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/31.
//

import UIKit

enum WeeklyCellType {
    case before
    case open
    case close
}

final class WeeklyMissionCollectionViewCell: UICollectionViewCell {
    
    private let missionImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: ImageAssets.computer)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let missionTitle: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.lineBreakMode = .byTruncatingMiddle
        label.font = .systemFont(ofSize: UPlusFont.h5, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let clockImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: ImageAssets.clock)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let timeLeftLabel: UILabel = { //MissionConstants.timeLeft
        let label = UILabel()
        label.textColor = UPlusColor.gray06
        label.font = .systemFont(ofSize: UPlusFont.h5, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let pointContainerView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 10.0
        view.backgroundColor = UPlusColor.blue01
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let pointLabel: UILabel = {
        let label = UILabel()
        label.textColor = UPlusColor.blue03
        label.textAlignment = .center
        label.text = MissionConstants.weeklyPoints
        label.font = .systemFont(ofSize: UPlusFont.caption1, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let progressBar: UIProgressView = {
        let progressView = UIProgressView()
        progressView.translatesAutoresizingMaskIntoConstraints = false
        return progressView
    }()
    
    private let numberOfParticipation: UILabel = {
        let label = UILabel()
        label.textColor = UPlusColor.green
        label.textAlignment = .center
        label.font = .systemFont(ofSize: UPlusFont.caption1, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.backgroundColor = .white
        self.contentView.clipsToBounds = true
        self.contentView.layer.cornerRadius = 30
        self.setUI()
        self.setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func resetCell() {
        self.missionTitle.text = nil
        self.timeLeftLabel.text = nil
    }
}

// MARK: - Configure with View Model
extension WeeklyMissionCollectionViewCell {
    
    func configure(title: String,
                   period: String,
                   point: Int64) {
        
        self.missionTitle.text = title
        self.timeLeftLabel.text = period
        self.numberOfParticipation.text = MissionConstants.weeklyMissionProgress
        
    }
    
}

// MARK: - Set UI & Layout
extension WeeklyMissionCollectionViewCell {
    private func setUI() {
        self.contentView.addSubviews(self.missionImage,
                                     self.missionTitle,
                                     self.clockImage,
                                     self.timeLeftLabel,
                                     self.pointContainerView,
                                     self.progressBar,
                                     self.numberOfParticipation)
        
        self.pointContainerView.addSubviews(self.pointLabel)
    }
    
    private func setLayout() {
        
        NSLayoutConstraint.activate([
            self.missionImage.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 2),
            self.missionImage.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            self.missionTitle.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 2),
            self.missionTitle.leadingAnchor.constraint(equalToSystemSpacingAfter: self.missionImage.trailingAnchor, multiplier: 2),
            self.clockImage.topAnchor.constraint(equalToSystemSpacingBelow: self.missionTitle.bottomAnchor, multiplier: 1),
            self.clockImage.leadingAnchor.constraint(equalTo: self.missionTitle.leadingAnchor),
            
            self.timeLeftLabel.centerYAnchor.constraint(equalTo: self.clockImage.centerYAnchor),
            self.timeLeftLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.clockImage.trailingAnchor, multiplier: 1),
            
            self.pointContainerView.topAnchor.constraint(equalTo: self.missionTitle.topAnchor),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.pointContainerView.trailingAnchor, multiplier: 2),
            self.pointContainerView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.missionTitle.trailingAnchor, multiplier: 2),
            self.pointContainerView.heightAnchor.constraint(equalToConstant: 30),
            self.pointContainerView.widthAnchor.constraint(equalToConstant: 95),
            
            self.progressBar.leadingAnchor.constraint(equalTo: self.missionImage.leadingAnchor),
            self.progressBar.trailingAnchor.constraint(equalTo: self.pointContainerView.trailingAnchor),
            self.progressBar.topAnchor.constraint(equalToSystemSpacingBelow: self.timeLeftLabel.bottomAnchor, multiplier: 2),
            
            self.numberOfParticipation.topAnchor.constraint(equalToSystemSpacingBelow: self.progressBar.bottomAnchor, multiplier: 1),
            self.numberOfParticipation.trailingAnchor.constraint(equalTo: self.pointContainerView.trailingAnchor),
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.numberOfParticipation.bottomAnchor, multiplier: 2) 
        ])
        
        NSLayoutConstraint.activate([
            self.pointLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.pointContainerView.topAnchor, multiplier: 1),
            self.pointLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.pointContainerView.leadingAnchor, multiplier: 1),
            self.pointContainerView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.pointLabel.trailingAnchor, multiplier: 1),
            self.pointContainerView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.pointLabel.bottomAnchor, multiplier: 1)
        ])
        
    }
    
    private func addOpenDateLabel() {
        self.timeLeftLabel.isHidden = false
        self.contentView.addSubview(timeLeftLabel)
        NSLayoutConstraint.activate([
            self.timeLeftLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.timeLeftLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.timeLeftLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.timeLeftLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
        ])
    }
}
