//
//  EventCollectionViewCell.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/08.
//

import UIKit

final class MypageEventCollectionViewCell: UICollectionViewCell {
    enum EventStatus {
        case open
        case close
        case participated
    }
    
    private let titleStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .leading
        stack.distribution = .fillProportionally
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let eventTitle: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: UPlusFont.h5, weight: .bold)
        return label
    }()
    
    private let eventDescription: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: UPlusFont.body2, weight: .medium)
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
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.backgroundColor = .white
        self.contentView.clipsToBounds = true
        self.contentView.layer.cornerRadius = 20
        
        self.setUI()
        self.setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    override func prepareForReuse() {
        self.pointLabel.textColor = UPlusColor.blue03
        self.pointContainerView.backgroundColor = UPlusColor.blue01
        self.pointContainerView.isHidden = false
        self.contentView.backgroundColor = .white
    }
}

// MARK: - Configure
extension MypageEventCollectionViewCell {
    func configure(type: EventStatus,
                   mission: any Mission) {
        switch type {
        case .open:
            self.eventTitle.text = mission.missionContentTitle
            self.eventDescription.text = mission.missionContentText
            self.pointLabel.text = String(describing: mission.missionRewardPoint) + "P"
        
        case .close:
            self.eventTitle.text = "레벨 \(mission.missionPermitAvatarLevel)에 오픈"
            self.pointContainerView.isHidden = true
            
        case .participated:
            self.contentView.backgroundColor = UPlusColor.gray02
            self.pointLabel.textColor = UPlusColor.gray06
            self.pointContainerView.backgroundColor = UPlusColor.gray04
            self.eventTitle.text = mission.missionContentTitle
            self.pointLabel.text = String(describing: MissionConstants.participated)
        }
    }
    
    func resetCell() {
        self.eventTitle.text = nil
        self.eventDescription.text = nil
        self.pointLabel.text = nil
    }
}

// MARK: - Set UI & Layout
extension MypageEventCollectionViewCell {
    private func setUI() {
        self.titleStack.addArrangedSubviews(self.eventTitle,
                                            self.eventDescription)
        
        self.contentView.addSubviews(self.titleStack,
                                     self.pointContainerView)
        
        self.pointContainerView.addSubview(self.pointLabel)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.titleStack.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 2),
            self.titleStack.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 2),
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.titleStack.bottomAnchor, multiplier: 2),
            
            self.pointContainerView.topAnchor.constraint(equalTo: self.eventTitle.topAnchor),
            self.pointContainerView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.titleStack.trailingAnchor, multiplier: 1),
            self.pointContainerView.widthAnchor.constraint(equalToConstant: 70),
            self.pointContainerView.heightAnchor.constraint(equalToConstant: 30),
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
