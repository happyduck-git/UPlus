//
//  RewardCollectionViewCell.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/14.
//

import UIKit
import Nuke
import OSLog

final class RewardCollectionViewCell: UICollectionViewCell {
    
    private let logger = Logger()
    
    private let frameImage: UIImageView = {
       let imageView = UIImageView()
        imageView.image = UIImage(named: ImageAssets.couponFrame)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 5.0
        stack.distribution = .fillProportionally
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let topTitle: UILabel = {
        let label = UILabel()
        label.textColor = UPlusColor.mint05
        label.font = .systemFont(ofSize: UPlusFont.caption1, weight: .bold)
        return label
    }()
    
    private let bottomTitle: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: UPlusFont.h5, weight: .bold)
        return label
    }()
    
    private let rewardImage: UIImageView = {
        let image = UIImageView()
        image.clipsToBounds = true
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private let rewardTypeLabel: UILabel = {
        let label = UILabel()
        label.textColor = UPlusColor.gray05
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: UPlusFont.caption1, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setUI()
        self.setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - Configure
extension RewardCollectionViewCell {
    
    func configure(with data: Reward) {
        self.topTitle.text = String(describing: data.rewardIndex)
        self.bottomTitle.text = String(describing: data.rewardName ?? "no-reward-name")
        self.rewardTypeLabel.text = String(describing: data.rewardType)
        Task {
            var image: UIImage?
            
            do {
                if let url = URL(string: data.rewardImagePath ?? "no-image"){
                    image = try await ImagePipeline.shared.image(for: url)
                } else {
                    image = UIImage(systemName: SFSymbol.heartFill)
                }
            }
            catch {
                logger.error("Error showing image -- \(error)")
                image = UIImage(systemName: SFSymbol.heartFill)
            }
            self.rewardImage.image = image
        }
    }
    
}

//MARK: - Set UI & Layout
extension RewardCollectionViewCell {
    private func setUI() {
        self.contentView.addSubviews(self.frameImage)
        
        self.titleStack.addArrangedSubviews(self.topTitle,
                                            self.bottomTitle)
        
        self.frameImage.addSubviews(self.titleStack,
                                    self.rewardImage,
                                    self.rewardTypeLabel)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.frameImage.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.frameImage.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.frameImage.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.frameImage.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            
            self.titleStack.topAnchor.constraint(equalToSystemSpacingBelow: self.frameImage.topAnchor, multiplier: 2),
            self.titleStack.leadingAnchor.constraint(equalToSystemSpacingAfter: self.frameImage.leadingAnchor, multiplier: 2),
            
            self.rewardImage.topAnchor.constraint(equalTo: self.titleStack.topAnchor),
            self.rewardImage.leadingAnchor.constraint(equalToSystemSpacingAfter: self.titleStack.trailingAnchor, multiplier: 2),
            self.frameImage.trailingAnchor.constraint(equalToSystemSpacingAfter: self.rewardImage.trailingAnchor, multiplier: 2),
            self.rewardImage.heightAnchor.constraint(equalTo: self.rewardImage.widthAnchor),
            
            self.rewardTypeLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.titleStack.bottomAnchor, multiplier: 1),
            self.rewardTypeLabel.leadingAnchor.constraint(equalTo: self.titleStack.leadingAnchor),
            self.frameImage.trailingAnchor.constraint(equalToSystemSpacingAfter: self.rewardTypeLabel.trailingAnchor, multiplier: 2),
            self.frameImage.bottomAnchor.constraint(equalToSystemSpacingBelow: self.rewardTypeLabel.bottomAnchor, multiplier: 2)
        ])
        
        self.titleStack.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
}
