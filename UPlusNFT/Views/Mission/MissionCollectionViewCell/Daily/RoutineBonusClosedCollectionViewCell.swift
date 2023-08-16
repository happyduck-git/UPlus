//
//  RoutineBonusClosedCollectionViewCell.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/16.
//

import UIKit

final class RoutineBonusClosedCollectionViewCell: UICollectionViewCell {
    
    private let lockImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: ImageAsset.padlock)?.withTintColor(UPlusColor.mint05, renderingMode: .alwaysOriginal)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
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

extension RoutineBonusClosedCollectionViewCell {
    private func setUI() {
        self.contentView.backgroundColor = UPlusColor.mint01
        self.contentView.layer.borderColor = UPlusColor.mint03.cgColor
        self.contentView.layer.borderWidth = 2.0
        
        self.contentView.addSubviews(self.lockImage)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.lockImage.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            self.lockImage.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor)
        ])
    }
}
