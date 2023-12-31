//
//  TodayMissionCollectionViewCell.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/18.
//

import UIKit

final class TodayMissionCollectionViewCell: UICollectionViewCell {
    
    enum `Type` {
        case mission
        case event
    }
    
    var type: Type?
    
    // MARK: - UI Elements
    private let missionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: UPlusFont.head2, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let timeLabelcontainerView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.backgroundColor = UPlusColor.gray03
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.text = RewardsConstants.empty
        label.textColor = UPlusColor.gray06
        label.font = .systemFont(ofSize: UPlusFont.body2, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.backgroundColor = .systemGray6
        setUI()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func layoutSubviews() {
        super.layoutSubviews()
        
        DispatchQueue.main.async {
            self.timeLabelcontainerView.layer.cornerRadius = self.timeLabelcontainerView.frame.height / 8
        }
        
    }
    
}

// MARK: - Configuration
extension TodayMissionCollectionViewCell {
    
    func configure(with vm: UserProfileViewViewModel) {
        switch self.type {
        case .mission:
            self.missionLabel.text = MissionConstants.todayMission
            self.timeLabel.text = String(format: MissionConstants.timeLeftSuffix, vm.timeLeft)
            
        case .event:
            self.missionLabel.text = MissionConstants.availableEvent
            self.timeLabel.text = String(format: MissionConstants.eventLeftSuffix, vm.timeLeft)
            
        default:
            return
        }
    }
    
}

// MARK: - Set UI & Layout
extension TodayMissionCollectionViewCell {
    
    private func setUI() {
        self.contentView.addSubviews(
            missionLabel,
            timeLabelcontainerView
        )
        self.timeLabelcontainerView.addSubview(timeLabel)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.missionLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor,
                                              multiplier: 2.0),
            self.missionLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor,
                                                  multiplier: 3.0),
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.missionLabel.bottomAnchor,
                                         multiplier: 2.0),
            
            self.timeLabelcontainerView.centerYAnchor.constraint(equalTo: self.missionLabel.centerYAnchor),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.timeLabelcontainerView.trailingAnchor, multiplier: 2.0)
        ])
        
        NSLayoutConstraint.activate([
            self.timeLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.timeLabelcontainerView.topAnchor, multiplier: 1),
            self.timeLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.timeLabelcontainerView.leadingAnchor, multiplier: 1),
            self.timeLabelcontainerView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.timeLabel.trailingAnchor, multiplier: 1),
            self.timeLabelcontainerView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.timeLabel.bottomAnchor, multiplier: 1)
        ])
    }

}
