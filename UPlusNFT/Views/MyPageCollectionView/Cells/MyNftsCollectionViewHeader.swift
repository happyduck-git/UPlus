//
//  MyNftsCollectionViewHeader.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/07/26.
//

import UIKit

final class MyNftsCollectionViewHeader: UICollectionViewCell {
    
    private let title: UILabel = {
        let label = UILabel()
        label.text = "My NFTs"
        label.textColor = .black
        label.font = .systemFont(ofSize: UPlusFont.head3, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nfts: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: UPlusFont.subTitle2, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setUI()
        self.setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension MyNftsCollectionViewHeader {
    func configure(with vm: MyPageViewViewModel) {
        self.nfts.text = String(describing: vm.user.userNfts?.count ?? 0)
    }
}

extension MyNftsCollectionViewHeader {
    private func setUI() {
        self.contentView.addSubviews(self.title,
                                     self.nfts)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.title.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 1),
            self.title.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 1),
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.title.bottomAnchor, multiplier: 1),
            
            self.nfts.centerYAnchor.constraint(equalTo: self.title.centerYAnchor),
            self.nfts.leadingAnchor.constraint(equalToSystemSpacingAfter: self.title.trailingAnchor, multiplier: 2)
        ])
    }
}
