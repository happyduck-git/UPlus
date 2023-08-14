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
        label.font = .systemFont(ofSize: UPlusFont.head6, weight: .bold)
        return label
    }()
    
    private let eventDescription: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: UPlusFont.subTitle2, weight: .medium)
        return label
    }()
    
    private let pointLabel: UILabel = {
        let label = UILabel()
        label.textColor = UPlusColor.blue03
        label.font = .systemFont(ofSize: UPlusFont.subTitle2, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
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
        self.pointLabel.textColor = UPlusColor.blue03
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
        case .participated:
            self.eventTitle.text = mission.missionContentTitle
            self.eventDescription.text = "참여 완료"
            self.pointLabel.textColor = .systemGray
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
                                     self.pointLabel)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.titleStack.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 1),
            self.titleStack.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 1),
            self.titleStack.bottomAnchor.constraint(equalToSystemSpacingBelow: self.contentView.bottomAnchor, multiplier: 1),
            
            self.pointLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.titleStack.trailingAnchor, multiplier: 2),
            self.pointLabel.topAnchor.constraint(equalTo: self.titleStack.topAnchor),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.pointLabel.trailingAnchor, multiplier: 2)
        ])
        self.pointLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }
}
