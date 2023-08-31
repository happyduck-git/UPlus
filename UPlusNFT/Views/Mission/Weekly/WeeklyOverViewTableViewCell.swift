//
//  WeeklyOverViewTableViewCell.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/18.
//

import UIKit

enum MissionPointLevel: Int64 {
    case easy = 50
    case medium = 100
    case hard = 150
    
    var description: String {
        switch self {
        case .easy:
            return "쉬움"
        case .medium:
            return "보통"
        case .hard:
            return "어려움"
        }
    }
    
}

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
        label.textColor = UPlusColor.gray06
        label.font = .systemFont(ofSize: UPlusFont.body2, weight: .bold)
        return label
    }()
    
    private var star1: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: ImageAsset.stageStar)
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private var star2: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: ImageAsset.stageStar)
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private var star3: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: ImageAsset.stageStar)
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
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
    
    //MARK: - Life Cycle
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.contentView.frame = self.contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10))
    }
}

// MARK: - Configure
extension WeeklyOverViewTableViewCell {
    func configure(type: WeeklyMissionStatus,
                   mission: any Mission) {
        switch type {
        case .open:
            self.missionTitle.text = mission.missionContentTitle
            self.levelStack.isHidden = false
            self.completedLabel.isHidden = true
            
        case .participated:
            self.missionTitle.text = mission.missionContentTitle
            self.completedLabel.text = MissionConstants.participated
            self.pointContainerView.backgroundColor = UPlusColor.gray02
            self.pointLabel.textColor = UPlusColor.gray05
            self.levelStack.isHidden = true
            self.completedLabel.isHidden = false
        }
        
        self.pointLabel.text = String(format: MissionConstants.missionPointSuffix, mission.missionRewardPoint)
        let missionLevel = MissionPointLevel(rawValue: mission.missionRewardPoint) ?? .easy
        levelDetail.text = missionLevel.description
        
        switch missionLevel {
        case .easy:
            star2.isHidden = true
            star3.isHidden = true
        case .medium:
            star3.isHidden = true
        case .hard:
            break
        }
        
    }
    
    func resetCell() {
        self.missionTitle.text = nil
        self.completedLabel.text = nil
        self.pointLabel.text = nil
        self.pointLabel.textColor = UPlusColor.blue03
        self.pointContainerView.backgroundColor = UPlusColor.blue01
    }
    
    override func prepareForReuse() {
        self.levelStack.isHidden = false
        self.completedLabel.isHidden = true
        self.star1.isHidden = false
        self.star2.isHidden = false
        self.star3.isHidden = false
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
                                            self.levelDetail,
                                            self.star1,
                                            self.star2,
                                            self.star3)
        
        self.pointContainerView.addSubview(self.pointLabel)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.missionTitle.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 2),
            self.missionTitle.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 2),
            self.pointContainerView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.missionTitle.trailingAnchor, multiplier: 2),
            
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
