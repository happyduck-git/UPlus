//
//  CampaignView.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/07/03.
//

import UIKit

final class CampaignView: UIView {
    
    enum CampainJoin {
        case notJoined
        case joined
    }
    
    //MARK: - UI Element
    private let labelContent: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray3
        view.clipsToBounds = true
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 13, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let joinLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let campaignPeriodLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let numberOfParticipantsLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let isEligibleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 13, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let isRedeemedLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 13, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        
        setUI()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Set UI & Layout
    private func setUI() {
        labelContent.addSubview(statusLabel)
        self.addSubviews(
            labelContent,
            joinLabel,
            campaignPeriodLabel,
            numberOfParticipantsLabel,
            isEligibleLabel,
            isRedeemedLabel
        )
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            labelContent.topAnchor.constraint(equalToSystemSpacingBelow: self.topAnchor, multiplier: 1),
            labelContent.leadingAnchor.constraint(equalToSystemSpacingAfter: self.leadingAnchor, multiplier: 1),
            
            statusLabel.topAnchor.constraint(equalToSystemSpacingBelow: labelContent.topAnchor, multiplier: 1),
            statusLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: labelContent.leadingAnchor, multiplier: 1),
            labelContent.trailingAnchor.constraint(equalToSystemSpacingAfter: statusLabel.trailingAnchor, multiplier: 1),
            labelContent.bottomAnchor.constraint(equalToSystemSpacingBelow: statusLabel.bottomAnchor, multiplier: 1),
            
            joinLabel.centerYAnchor.constraint(equalTo: labelContent.centerYAnchor),
            self.trailingAnchor.constraint(equalToSystemSpacingAfter: joinLabel.trailingAnchor, multiplier: 1),
            
            campaignPeriodLabel.topAnchor.constraint(equalToSystemSpacingBelow: labelContent.bottomAnchor, multiplier: 1),
            campaignPeriodLabel.leadingAnchor.constraint(equalTo: labelContent.leadingAnchor),
            numberOfParticipantsLabel.topAnchor.constraint(equalToSystemSpacingBelow: campaignPeriodLabel.bottomAnchor, multiplier: 1),
            numberOfParticipantsLabel.leadingAnchor.constraint(equalTo: labelContent.leadingAnchor),
            
            isEligibleLabel.topAnchor.constraint(equalToSystemSpacingBelow: numberOfParticipantsLabel.bottomAnchor, multiplier: 1),
            isEligibleLabel.leadingAnchor.constraint(equalTo: labelContent.leadingAnchor),
            
            isRedeemedLabel.topAnchor.constraint(equalTo: isEligibleLabel.topAnchor),
            isRedeemedLabel.trailingAnchor.constraint(equalTo: joinLabel.trailingAnchor)
        ])
    }
    
    //MARK: - Internal
    
    func configure(with vm: CampaignCollectionViewCellViewModel) {
        self.campaignPeriodLabel.text = "캠페인 참여 기간: " + vm.campaignPeriod
        self.numberOfParticipantsLabel.text = "캠페인 참여자 수: " + vm.numberOfParticipants
        let eligible = vm.isEligable ? "보상 대상" : "보상 비대상"
        let redeem = vm.isRewarded ? "보상 획득 완료" : "보상 미획득"
        self.isEligibleLabel.text = eligible
        self.isRedeemedLabel.text = redeem
        
        let join: CampainJoin = vm.hasJoined ? .joined : .notJoined
        self.markJoin(join)
        
        let campaignStatus = vm.isExpired ? "캠페인 종료" : "캠페인 진행 중"
        self.statusLabel.text = campaignStatus
    }
    
    /// Mark if the user has participated the campaign or not.
    /// - Parameter status: Participation status.
    /// - Returns: NSMutableAttributedString.
    func markJoin(_ status: CampainJoin) {
        let icon = NSTextAttachment()
        icon.image = UIImage(systemName: "checkmark.circle")
        
        let attributedString = NSMutableAttributedString(string: "")
        let imageAttributedString = NSAttributedString(attachment: icon)
        attributedString.append(imageAttributedString)
        
        var string = ""
        var stringAttributes: [NSAttributedString.Key: Any] = [:]
        
        switch status {
        case .notJoined:
            string  = "미참여"
            stringAttributes = [
                .foregroundColor: UIColor.systemGray
            ]
        case .joined:
            string  = "참여완료"
            stringAttributes = [
                .foregroundColor: UIColor.systemPink
            ]
        }
        
        let stringRange = NSRange(location: attributedString.length, length: string.count)
        let stringAttributedString = NSAttributedString(string: string, attributes: stringAttributes)
        attributedString.append(stringAttributedString)
        attributedString.addAttributes(stringAttributes, range: stringRange)
        
        joinLabel.attributedText = attributedString
    }
}
