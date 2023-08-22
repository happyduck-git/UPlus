//
//  WeeklyOverViewTableViewCell.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/18.
//

import UIKit

enum WeeklyMissionStatus {
    case open
    case participated
}

final class WeeklyOverViewTableViewCell: UITableViewCell {

    private let missionTitle: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: UPlusFont.h5, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let levelStack: UIStackView = {
        let stack = UIStackView()
        stack.distribution = .fillProportionally
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let levelTitle: UILabel = {
        let label = UILabel()
        label.text = MissionConstants.difficulty
        label.textColor = UPlusColor.gray06
        label.font = .systemFont(ofSize: UPlusFont.body2, weight: .regular)
        return label
    }()
    
    private let levelDetail: UILabel = {
        let label = UILabel()
        label.text = "어려움"
        label.textColor = UPlusColor.gray06
        label.font = .systemFont(ofSize: UPlusFont.body2, weight: .bold)
        return label
    }()
    
    private let completedLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.textColor = UPlusColor.blue03
        label.font = .systemFont(ofSize: UPlusFont.body2, weight: .regular)
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
        label.textAlignment = .center
        label.textColor = UPlusColor.blue03
        label.font = .systemFont(ofSize: UPlusFont.body2, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.setUI()
        self.setLayout()
        
        self.contentView.backgroundColor = UPlusColor.grayBackground
        self.contentView.layer.cornerRadius = 10.0
        
        self.contentView.clipsToBounds = true
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Configure
extension WeeklyOverViewTableViewCell {
    func configure(type: WeeklyMissionStatus,
                   mission: any Mission) {
        switch type {
        case .open:
            self.missionTitle.text = mission.missionContentTitle
            self.pointLabel.text = String(describing: mission.missionRewardPoint) + "P"

        case .participated:
            self.missionTitle.text = mission.missionContentTitle
            self.completedLabel.text = MissionConstants.participated
            self.pointContainerView.backgroundColor = UPlusColor.gray02
            self.pointLabel.textColor = UPlusColor.gray05
            self.levelStack.isHidden = true
            self.completedLabel.isHidden = false
        }
    }
    
    func resetCell() {
        self.missionTitle.text = nil
        self.completedLabel.text = nil
        self.pointLabel.text = nil
    }
    
    override func prepareForReuse() {
        self.levelStack.isHidden = false
        self.completedLabel.isHidden = true
    }
}

// MARK: - Set UI & Layout
extension WeeklyOverViewTableViewCell {
    private func setUI() {
        self.contentView.addSubviews(self.missionTitle,
                                     self.levelStack,
                                     self.completedLabel,
                                     self.pointContainerView)
        
        self.levelStack.addArrangedSubviews(self.levelTitle,
                                            self.levelDetail)
        
        self.pointContainerView.addSubview(self.pointLabel)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.missionTitle.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 2),
            self.missionTitle.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 2),
            self.missionTitle.trailingAnchor.constraint(equalToSystemSpacingAfter: self.pointContainerView.leadingAnchor, multiplier: 2),
            
            self.levelStack.topAnchor.constraint(equalToSystemSpacingBelow: self.missionTitle.bottomAnchor, multiplier: 1),
            self.levelStack.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 2),
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.levelStack.bottomAnchor, multiplier: 2),
            
            self.completedLabel.topAnchor.constraint(equalTo: self.levelStack.topAnchor),
            self.completedLabel.leadingAnchor.constraint(equalTo: self.levelStack.leadingAnchor),
            self.completedLabel.bottomAnchor.constraint(equalTo: self.levelStack.bottomAnchor),
            
            self.pointContainerView.topAnchor.constraint(equalTo: self.missionTitle.topAnchor),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.pointContainerView.trailingAnchor, multiplier: 2),
            self.pointContainerView.heightAnchor.constraint(equalToConstant: 30),
            self.pointContainerView.widthAnchor.constraint(equalToConstant: 52)
        ])
        
        NSLayoutConstraint.activate([
            self.pointLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.pointContainerView.topAnchor, multiplier: 1),
            self.pointLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.pointContainerView.leadingAnchor, multiplier: 1),
            self.pointContainerView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.pointLabel.trailingAnchor, multiplier: 1),
            self.pointContainerView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.pointLabel.bottomAnchor, multiplier: 1)
        ])
    }
}
