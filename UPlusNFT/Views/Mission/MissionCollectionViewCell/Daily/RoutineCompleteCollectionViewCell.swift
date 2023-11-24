//
//  RoutineCompleteCollectionViewCell.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/16.
//

import UIKit
import Combine

protocol RoutineCompleteCollectionViewCellDelegate: AnyObject {
    func redeemButtonDidTap(sender: RoutineCompleteCollectionViewCell)
}

final class RoutineCompleteCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Delegate
    weak var delegate: RoutineCompleteCollectionViewCellDelegate?
    
    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    // MARK: - UI Elements
    let confettiImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let completeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: UPlusFont.body1, weight: .bold)
        label.text = MissionConstants.dailyMissionComplete
        label.textColor = UPlusColor.mint04
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let redeemButton: UIButton = {
        let button = UIButton()
        button.setTitle(MissionConstants.redeemReward, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: UPlusFont.h2, weight: .bold)
        button.backgroundColor = UPlusColor.mint05
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setUI()
        self.setLayout()
        self.bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension RoutineCompleteCollectionViewCell {
    private func bind() {
        self.redeemButton.tapPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let `self` = self else { return }
                self.delegate?.redeemButtonDidTap(sender: self)
            }
            .store(in: &bindings)
    }
}

extension RoutineCompleteCollectionViewCell {
    private func setUI() {
        self.contentView.backgroundColor = UPlusColor.mint01
        self.contentView.clipsToBounds = true
        self.contentView.layer.cornerRadius = 16.0
        self.contentView.layer.borderColor = UPlusColor.mint03.cgColor
        self.contentView.layer.borderWidth = 2.0
        
        self.contentView.addSubviews(self.completeLabel,
                                     self.redeemButton)
        
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.completeLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 5),
            self.completeLabel.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            
            self.redeemButton.topAnchor.constraint(equalToSystemSpacingBelow: self.completeLabel.bottomAnchor, multiplier: 3),
            self.redeemButton.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 6),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.redeemButton.trailingAnchor, multiplier: 6),
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.redeemButton.bottomAnchor, multiplier: 5)
        ])
        
        self.redeemButton.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
    
}

extension RoutineCompleteCollectionViewCell: RoutineCompleteViewControllerDelegate {
    func cancelButtonDidTap() {
        self.redeemButton.setTitle(MissionConstants.rewardRedeemed, for: .normal)
        self.redeemButton.isUserInteractionEnabled = false
        self.redeemButton.backgroundColor = UPlusColor.gray03
    }
}
