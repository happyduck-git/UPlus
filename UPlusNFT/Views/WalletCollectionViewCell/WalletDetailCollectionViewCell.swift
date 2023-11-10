//
//  WalletDetailCollectionViewCell.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/14.
//

import UIKit
import Nuke
import Gifu

final class WalletDetailCollectionViewCell: UICollectionViewCell {
    
    private let nftImageView: GIFImageView = {
        let gifView = GIFImageView()
        gifView.clipsToBounds = true
        gifView.layer.cornerRadius = 8.0
        gifView.translatesAutoresizingMaskIntoConstraints = false
        return gifView
    }()
    
    private let nftType: UILabel = {
        let label = UILabel()
        label.textColor = UPlusColor.gray06
        label.textAlignment = .left
        label.font = .systemFont(ofSize: UPlusFont.caption1, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nftTitle: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .left
        label.font = .systemFont(ofSize: UPlusFont.body1, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setUI()
        self.setLayout()

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
}
// MARK: - Configure
extension WalletDetailCollectionViewCell {
    func configure(with data: UPlusNft) {
        Task {
            if let url = URL(string: data.nftContentImageUrl) {
                
                self.nftImageView.animate(withGIFURL: url)
                self.nftImageView.prepareForAnimation(withGIFURL: url)
                
            }
            self.nftType.text = data.nftType
            self.nftTitle.text = data.nftName ?? data.nftType
        }
    }
}

// MARK: - Set UI & Layout
extension WalletDetailCollectionViewCell {
    private func setUI() {
        self.contentView.addSubviews(self.nftImageView,
                                     self.nftTitle,
                                     self.nftType)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.nftImageView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.nftImageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.nftImageView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.nftImageView.heightAnchor.constraint(equalTo: self.nftImageView.widthAnchor),
            
            self.nftType.topAnchor.constraint(equalToSystemSpacingBelow: self.nftImageView.bottomAnchor, multiplier: 2),
            self.nftType.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 1),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.nftType.trailingAnchor, multiplier: 1),
            
            self.nftTitle.topAnchor.constraint(equalToSystemSpacingBelow: self.nftType.bottomAnchor, multiplier: 1),
            self.nftTitle.leadingAnchor.constraint(equalTo: self.nftType.leadingAnchor),
            self.nftTitle.trailingAnchor.constraint(equalTo: self.nftType.trailingAnchor),
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.nftTitle.bottomAnchor, multiplier: 1)
        ])
        self.nftType.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
}
