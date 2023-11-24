//
//  WalletCollectionHeaderReusableView.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/14.
//

import UIKit

final class WalletCollectionHeaderReusableView: UICollectionReusableView {
    
    private let myNftsLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = WalletConstants.myNfts
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let numberOfNftsLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UPlusColor.gray05
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let showAllButton: UIButton = {
       let button = UIButton()
        button.setTitleColor(UPlusColor.mint04, for: .normal)
        button.setTitle(WalletConstants.showAll, for: .normal)
        return button
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

extension WalletCollectionHeaderReusableView {

    func configure(ownedNftNumber: Int) {
        self.numberOfNftsLabel.text = String(describing: ownedNftNumber) + RewardsConstants.rewardsUnit
    }
    
}

extension WalletCollectionHeaderReusableView {
    private func setUI() {
        self.addSubviews(self.myNftsLabel,
                         self.numberOfNftsLabel,
                         self.showAllButton)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.myNftsLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.topAnchor, multiplier: 1),
            self.myNftsLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.leadingAnchor, multiplier: 2),
            self.bottomAnchor.constraint(equalToSystemSpacingBelow: self.myNftsLabel.bottomAnchor, multiplier: 1),
            
            self.numberOfNftsLabel.bottomAnchor.constraint(equalTo: self.myNftsLabel.bottomAnchor),
            self.numberOfNftsLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.myNftsLabel.trailingAnchor, multiplier: 2),
            
            self.showAllButton.centerYAnchor.constraint(equalTo: self.myNftsLabel.centerYAnchor),
            self.trailingAnchor.constraint(equalToSystemSpacingAfter: self.showAllButton.trailingAnchor, multiplier: 2),
        ])
    }
}
