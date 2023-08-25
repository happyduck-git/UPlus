//
//  WalletCollectionViewCell.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/07.
//

import UIKit
import Nuke
import Gifu

final class WalletCollectionViewCell: UICollectionViewCell {
    
    private var nftImageViewHeight: NSLayoutConstraint?

    private let nftImageView: GIFImageView = {
        let gifView = GIFImageView()
        gifView.translatesAutoresizingMaskIntoConstraints = false
        return gifView
    }()
    
    private let nftTypeView: InsetLabelView = {
        let view = InsetLabelView()
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let nftTitle: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: UPlusFont.h2, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let levelTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UPlusColor.gray05
        label.textAlignment = .center
        label.text = WalletConstants.level
        label.font = .systemFont(ofSize: UPlusFont.caption1, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
     }()
    
    private let levelLabel: UILabel = {
        let label = UILabel()
        label.textColor = UPlusColor.gray09
        label.textAlignment = .center
        label.font = .systemFont(ofSize: UPlusFont.caption1, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
     }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.clipsToBounds = true
        self.contentView.layer.cornerRadius = 8.0
        
        self.setUI()
        self.setLayout()
        
        self.contentView.layer.borderColor = UPlusColor.gray01.cgColor
        self.contentView.layer.borderWidth = 1.0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.nftImageViewHeight = self.nftImageView.heightAnchor.constraint(equalToConstant: self.contentView.frame.height / 1.5)
        self.nftImageViewHeight?.isActive = true
        
        
        DispatchQueue.main.async {
            self.nftTypeView.layer.cornerRadius = self.nftTypeView.frame.height / 2
        }
        
    }

}

extension WalletCollectionViewCell {
    
    func resetCell() {
        self.nftImageView.image = nil
        self.levelLabel.text = nil
        self.nftTitle.text = nil
    }
    
}

// MARK: - Configure
extension WalletCollectionViewCell {
    func configure(with data: UPlusNft) {
        Task {
            
            if let url = URL(string: data.nftContentImageUrl) {
                self.nftImageView.animate(withGIFURL: url)
                self.nftImageView.prepareForAnimation(withGIFURL: url)
            }

            self.nftTypeView.setNameTitle(text: data.nftDetailType)
            self.nftTitle.text = data.nftDetailType
        
            let level = NftLevel.level(tokenId: data.nftTokenId)
            if Range(0...5).contains(level) {
                self.levelLabel.text = String(describing: level)
            }
            
        }
    }
    
}

// MARK: - Set UI & Layout
extension WalletCollectionViewCell {
    private func setUI() {
        self.contentView.addSubviews(self.nftImageView,
                                     self.nftTypeView,
                                     self.nftTitle,
                                     self.levelTitleLabel,
                                     self.levelLabel)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.nftImageView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.nftImageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.nftImageView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            
            self.nftTypeView.topAnchor.constraint(equalToSystemSpacingBelow: self.nftImageView.bottomAnchor, multiplier: 4),
            self.nftTypeView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 3),
            
            self.nftTitle.topAnchor.constraint(equalToSystemSpacingBelow: self.nftTypeView.bottomAnchor, multiplier: 1),
            self.nftTitle.leadingAnchor.constraint(equalTo: self.nftTypeView.leadingAnchor),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.nftTitle.trailingAnchor, multiplier: 2),
            
            self.levelTitleLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.nftTitle.bottomAnchor, multiplier: 1),
            self.levelTitleLabel.leadingAnchor.constraint(equalTo: self.nftTypeView.leadingAnchor),
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.levelTitleLabel.bottomAnchor, multiplier: 3),
            
            self.levelLabel.topAnchor.constraint(equalTo: self.levelTitleLabel.topAnchor),
            self.levelLabel.trailingAnchor.constraint(equalTo: self.nftTitle.trailingAnchor),
            self.levelLabel.bottomAnchor.constraint(equalTo: self.levelTitleLabel.bottomAnchor)
        ])
        
        self.nftTypeView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        self.levelTitleLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        self.levelLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
}
