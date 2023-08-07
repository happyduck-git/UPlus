//
//  WalletCollectionViewCell.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/07.
//

import UIKit
import Nuke

final class WalletCollectionViewCell: UICollectionViewCell {
    
    private var nftImageViewHeight: NSLayoutConstraint?
    
    private let nftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nftTitle: UILabel = {
       let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setUI()
        self.setLayout()
        
        self.contentView.layer.borderColor = UPlusColor.mint.cgColor
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
    }
}

// MARK: - Configure
extension WalletCollectionViewCell {
    func configure(with data: UPlusNft) {
        Task {
            do {
                if let url = URL(string: data.nftContentImageUrl) {
                    self.nftImageView.image = try await ImagePipeline.shared.image(for: url)
                }
            }
            catch {
                print("Error fetching nft image -- \(error)")
            }
            self.nftTitle.text = data.nftDetailType
        }
    }
}

// MARK: - Set UI & Layout
extension WalletCollectionViewCell {
    private func setUI() {
        self.contentView.addSubviews(self.nftImageView,
                                     self.nftTitle)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.nftImageView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.nftImageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.nftImageView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            
            self.nftTitle.topAnchor.constraint(equalToSystemSpacingBelow: self.nftImageView.bottomAnchor, multiplier: 1),
            self.nftTitle.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 1),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.nftTitle.trailingAnchor, multiplier: 1),
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.nftTitle.bottomAnchor, multiplier: 1)
        ])
    }
}
